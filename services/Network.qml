pragma Singleton
pragma ComponentBehavior: Bound

// Took many bits from https://github.com/caelestia-dots/shell (GPLv3)

import Quickshell
import Quickshell.Io
import QtQuick
import qs.services.network

/**
 * Network service with nmcli.
 */
Singleton {
    id: root

    property bool wifi: true
    property bool ethernet: false
    property string ethernetDevice: ""
    property string ethernetSpeed: ""
    property bool ethernetConnected: false

    property bool wifiEnabled: false
    property bool wifiScanning: false
    property bool wifiConnecting: connectProc.running
    property WifiAccessPoint wifiConnectTarget
    readonly property list<WifiAccessPoint> wifiNetworks: []
    readonly property WifiAccessPoint active: wifiNetworks.find(n => n.active) ?? null
    readonly property list<var> friendlyWifiNetworks: [...wifiNetworks].sort((a, b) => {
        if (a.active && !b.active)
            return -1;
        if (!a.active && b.active)
            return 1;
        return b.strength - a.strength;
    })
    property list<string> knownNetworks: []
    property string wifiStatus: "disconnected"

    property string networkName: ""
    property int networkStrength
    property string materialSymbol: root.ethernet ? "lan" : root.wifiEnabled ? (Network.networkStrength > 83 ? "signal_wifi_4_bar" : Network.networkStrength > 67 ? "network_wifi" : Network.networkStrength > 50 ? "network_wifi_3_bar" : Network.networkStrength > 33 ? "network_wifi_2_bar" : Network.networkStrength > 17 ? "network_wifi_1_bar" : "signal_wifi_0_bar") : (root.wifiStatus === "connecting") ? "signal_wifi_statusbar_not_connected" : (root.wifiStatus === "disconnected") ? "wifi_find" : (root.wifiStatus === "disabled") ? "signal_wifi_off" : "signal_wifi_bad"

    function enableWifi(enabled = true): void {
        const cmd = enabled ? "on" : "off";
        enableWifiProc.exec(["nmcli", "radio", "wifi", cmd]);
    }

    function toggleWifi(): void {
        enableWifi(!wifiEnabled);
    }

    function toggleEthernet(): void {
        if (ethernetDevice) {
            if (ethernetConnected) {
                disconnectEthernetProc.exec(["nmcli", "device", "disconnect", ethernetDevice]);
            } else {
                connectEthernetProc.exec(["nmcli", "device", "connect", ethernetDevice]);
            }
        }
    }

    function rescanWifi(): void {
        wifiScanning = true;
        rescanProcess.running = true;
    }

    function connectToWifiNetwork(accessPoint: WifiAccessPoint): void {
        accessPoint.askingPassword = false;
        root.wifiConnectTarget = accessPoint;
        // We use this instead of `nmcli connection up SSID` because this also creates a connection profile
        connectProc.exec(["nmcli", "dev", "wifi", "connect", accessPoint.ssid]);
    }

    function disconnectWifiNetwork(): void {
        if (active)
            disconnectProc.exec(["nmcli", "connection", "down", active.ssid]);
    }

    function openPublicWifiPortal() {
        Quickshell.execDetached(["xdg-open", "https://nmcheck.gnome.org/"]); // From some StackExchange thread, seems to work
    }

    function changePassword(network: WifiAccessPoint, password: string, username = ""): void {
        // TODO: enterprise wifi with username
        network.askingPassword = false;
        changePasswordProc.exec({
            "environment": {
                "PASSWORD": password
            },
            "command": ["bash", "-c", `nmcli connection modify ${network.ssid} wifi-sec.psk "$PASSWORD"`]
        });
    }

    Process {
        id: enableWifiProc
    }

    Process {
        id: connectProc
        environment: ({
                LANG: "C",
                LC_ALL: "C"
            })
        stdout: SplitParser {
            onRead: line => {
                getNetworks.running = true;
            }
        }
        stderr: SplitParser {
            onRead: line => {
                if (line.includes("Secrets were required")) {
                    root.wifiConnectTarget.askingPassword = true;
                }
            }
        }
        onExited: (exitCode, exitStatus) => {
            root.wifiConnectTarget.askingPassword = (exitCode !== 0);
            root.wifiConnectTarget = null;
        }
    }

    Process {
        id: disconnectProc
        stdout: SplitParser {
            onRead: getNetworks.running = true
        }
    }

    Process {
        id: changePasswordProc
        onExited: { // Re-attempt connection after changing password
            connectProc.running = false;
            connectProc.running = true;
        }
    }

    Process {
        id: rescanProcess
        command: ["nmcli", "dev", "wifi", "list", "--rescan", "yes"]
        stdout: SplitParser {
            onRead: {
                wifiScanning = false;
                getNetworks.running = true;
            }
        }
    }

    function update() {
        updateConnectionType.startCheck();
        wifiStatusProcess.running = true;
        updateNetworkName.running = true;
        updateNetworkStrength.running = true;
        getKnownNetworks.running = true;
        updateEthernetInfo.running = true;
    }

    function forgetNetwork(ssid: string): void {
        forgetNetworkProc.exec(["nmcli", "connection", "delete", ssid]);
    }

    Process {
        id: subscriber
        running: true
        command: ["nmcli", "monitor"]
        stdout: SplitParser {
            onRead: root.update()
        }
    }

    Process {
        id: updateConnectionType
        property string buffer
        command: ["sh", "-c", "nmcli -t -f TYPE,STATE d status && nmcli -t -f CONNECTIVITY g"]
        running: true
        function startCheck() {
            buffer = "";
            updateConnectionType.running = true;
        }
        stdout: SplitParser {
            onRead: data => {
                updateConnectionType.buffer += data + "\n";
            }
        }
        onExited: (exitCode, exitStatus) => {
            const lines = updateConnectionType.buffer.trim().split('\n');
            const connectivity = lines.pop(); // none, limited, full
            let hasEthernet = false;
            let hasWifi = false;
            let wifiStatus = "disconnected";
            lines.forEach(line => {
                if (line.includes("ethernet") && line.includes("connected"))
                    hasEthernet = true;
                else if (line.includes("wifi:")) {
                    if (line.includes("disconnected")) {
                        wifiStatus = "disconnected";
                    } else if (line.includes("connected")) {
                        hasWifi = true;
                        wifiStatus = "connected";

                        if (connectivity === "limited") {
                            hasWifi = false;
                            wifiStatus = "limited";
                        }
                    } else if (line.includes("connecting")) {
                        wifiStatus = "connecting";
                    } else if (line.includes("unavailable")) {
                        wifiStatus = "disabled";
                    }
                }
            });
            root.wifiStatus = wifiStatus;
            root.ethernet = hasEthernet;
            root.wifi = hasWifi;
        }
    }

    Process {
        id: updateNetworkName
        command: ["sh", "-c", "nmcli -t -f NAME c show --active | head -1"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                root.networkName = data;
            }
        }
    }

    Process {
        id: updateNetworkStrength
        running: true
        command: ["sh", "-c", "nmcli -f IN-USE,SIGNAL,SSID device wifi | awk '/^\*/{if (NR!=1) {print $2}}'"]
        stdout: SplitParser {
            onRead: data => {
                root.networkStrength = parseInt(data);
            }
        }
    }

    Process {
        id: wifiStatusProcess
        command: ["nmcli", "radio", "wifi"]
        Component.onCompleted: running = true
        environment: ({
                LANG: "C",
                LC_ALL: "C"
            })
        stdout: StdioCollector {
            onStreamFinished: {
                root.wifiEnabled = text.trim() === "enabled";
            }
        }
    }

    Process {
        id: getNetworks
        running: true
        command: ["nmcli", "-g", "ACTIVE,SIGNAL,FREQ,SSID,BSSID,SECURITY", "d", "w"]
        environment: ({
                LANG: "C",
                LC_ALL: "C"
            })
        stdout: StdioCollector {
            onStreamFinished: {
                const PLACEHOLDER = "STRINGWHICHHOPEFULLYWONTBEUSED";
                const rep = new RegExp("\\\\:", "g");
                const rep2 = new RegExp(PLACEHOLDER, "g");

                const allNetworks = text.trim().split("\n").map(n => {
                    const net = n.replace(rep, PLACEHOLDER).split(":");
                    return {
                        active: net[0] === "yes",
                        strength: parseInt(net[1]),
                        frequency: parseInt(net[2]),
                        ssid: net[3],
                        bssid: net[4]?.replace(rep2, ":") ?? "",
                        security: net[5] || ""
                    };
                }).filter(n => n.ssid && n.ssid.length > 0);

                // Group networks by SSID and prioritize connected ones
                const networkMap = new Map();
                for (const network of allNetworks) {
                    const existing = networkMap.get(network.ssid);
                    if (!existing) {
                        networkMap.set(network.ssid, network);
                    } else {
                        // Prioritize active/connected networks
                        if (network.active && !existing.active) {
                            networkMap.set(network.ssid, network);
                        } else if (!network.active && !existing.active) {
                            // If both are inactive, keep the one with better signal
                            if (network.strength > existing.strength) {
                                networkMap.set(network.ssid, network);
                            }
                        }
                        // If existing is active and new is not, keep existing
                    }
                }

                const wifiNetworks = Array.from(networkMap.values());

                const rNetworks = root.wifiNetworks;

                const destroyed = rNetworks.filter(rn => !wifiNetworks.find(n => n.frequency === rn.frequency && n.ssid === rn.ssid && n.bssid === rn.bssid));
                for (const network of destroyed)
                    rNetworks.splice(rNetworks.indexOf(network), 1).forEach(n => n.destroy());

                for (const network of wifiNetworks) {
                    const match = rNetworks.find(n => n.frequency === network.frequency && n.ssid === network.ssid && n.bssid === network.bssid);
                    if (match) {
                        match.lastIpcObject = network;
                    } else {
                        rNetworks.push(apComp.createObject(root, {
                            lastIpcObject: network
                        }));
                    }
                }
            }
        }
    }

    Process {
        id: forgetNetworkProc
        onExited: {
            getKnownNetworks.running = true;
            getNetworks.running = true;
        }
    }

    Process {
        id: connectEthernetProc
        onExited: {
            updateEthernetInfo.running = true;
        }
    }

    Process {
        id: disconnectEthernetProc
        onExited: {
            updateEthernetInfo.running = true;
        }
    }

    Process {
        id: updateEthernetInfo
        running: true
        command: ["sh", "-c", "nmcli -t -f DEVICE,TYPE,STATE device status | grep ':ethernet:' && nmcli -t -f GENERAL.DEVICE,WIRED-PROPERTIES.SPEED device show $(nmcli -t -f DEVICE,TYPE device status | grep ':ethernet$' | head -1 | cut -d: -f1) 2>/dev/null || true"]
        environment: ({
            LANG: "C",
            LC_ALL: "C"
        })
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.trim().split("\n");
                if (lines.length > 0 && lines[0].length > 0) {
                    const deviceLine = lines[0];
                    const parts = deviceLine.split(":");
                    if (parts.length >= 3) {
                        root.ethernetDevice = parts[0];
                        root.ethernetConnected = parts[2] === "connected";

                        // Parse speed from remaining lines
                        const speedLine = lines.find(l => l.includes("WIRED-PROPERTIES.SPEED:"));
                        if (speedLine) {
                            const speed = speedLine.split(":")[1];
                            root.ethernetSpeed = speed ? `${speed} Mb/s` : "";
                        } else {
                            root.ethernetSpeed = "";
                        }
                    }
                } else {
                    root.ethernetDevice = "";
                    root.ethernetSpeed = "";
                    root.ethernetConnected = false;
                }
            }
        }
    }

    Process {
        id: getKnownNetworks
        running: true
        command: ["nmcli", "-t", "-f", "NAME,TYPE", "connection", "show"]
        environment: ({
                LANG: "C",
                LC_ALL: "C"
            })
        stdout: StdioCollector {
            onStreamFinished: {
                const connections = text.trim().split("\n");
                const wifiConnections = connections.filter(line => line.includes(":802-11-wireless")).map(line => line.split(":")[0]).filter(name => name.length > 0);
                root.knownNetworks = wifiConnections;
            }
        }
    }

    Component {
        id: apComp

        WifiAccessPoint {}
    }
}
