pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.common
import qs.services
import qs.modules.controlcenter.atoms

Flickable {
    id: root

    Component.onCompleted: console.log("[ControlCenter.network] loaded")
    Component.onDestruction: console.log("[ControlCenter.network] unloaded")

    contentWidth: width
    contentHeight: column.implicitHeight + column.anchors.topMargin + column.anchors.bottomMargin
    boundsBehavior: Flickable.StopAtBounds
    clip: true

    function isKnown(ssid: string): bool {
        if (!ssid || !Network.knownNetworks) return false;
        return Network.knownNetworks.indexOf(ssid) !== -1;
    }

    function tryConnect(ap: var): void {
        if (!ap) return;
        if (ap.active) {
            Network.disconnectWifiNetwork();
            return;
        }
        if (root.isKnown(ap.ssid) || !ap.isSecure) Network.connectToWifiNetwork(ap);
    }

    function apMeta(ap: var): string {
        if (!ap) return "";
        const parts = [ap.security || "Open"];
        if (typeof ap.strength === "number") parts.push(`${ap.strength}%`);
        return parts.join(" · ");
    }

    ColumnLayout {
        id: column
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.leftMargin: 26
        anchors.rightMargin: 26
        anchors.topMargin: 22
        anchors.bottomMargin: 24
        spacing: 0

        Text {
            text: "Network"
            color: Colors.fgSurface
            font.family: Theme.font.family.inter_medium
            font.pixelSize: Theme.font.size.xxl
            font.weight: Font.Medium
        }

        Text {
            Layout.topMargin: 4
            Layout.bottomMargin: 18
            text: "WI-FI · ETHERNET · CONNECTIONS"
            color: Colors.inkDimmer
            font.family: Theme.font.family.inter_medium
            font.pixelSize: Theme.font.size.xs
            font.letterSpacing: 2.4
        }

        GroupLabel { text: "WI-FI" }

        GroupBox {
            DeviceRow {
                icon: "wifi"
                name: {
                    if (!Network.wifiEnabled) return "Wi-Fi off";
                    const a = Network.active;
                    if (a && a.ssid) return a.ssid;
                    return "Not connected";
                }
                meta: {
                    if (!Network.wifiEnabled) return "Toggle to enable";
                    const a = Network.active;
                    if (!a) return Network.wifiScanning ? "Scanning…" : "";
                    return root.apMeta(a);
                }
                chipText: {
                    if (!Network.wifiEnabled) return "";
                    if (Network.wifiConnecting) return "Connecting";
                    if (Network.active) return "Connected";
                    return "";
                }
                chipVariant: Network.wifiConnecting ? "default" : "live"
                showSeparator: true
            }

            ToggleRow {
                label: "Wi-Fi"
                checked: Network.wifiEnabled
                onToggled: Network.toggleWifi()
            }
        }

        Loader {
            Layout.fillWidth: true
            active: Network.wifiEnabled
            visible: active

            sourceComponent: Component {
                ColumnLayout {
                    spacing: 0

                    GroupLabel {
                        text: Network.wifiScanning ? "NETWORKS · SCANNING…" : "NETWORKS"
                    }

                    GroupBox {
                        Repeater {
                            id: networksRepeater
                            model: Network.friendlyWifiNetworks

                            delegate: DeviceRow {
                                id: apRow
                                required property var modelData
                                required property int index

                                readonly property bool isActive: !!modelData && !!modelData.active
                                readonly property bool isKnown: root.isKnown(modelData?.ssid ?? "")
                                readonly property bool isOpen: !(modelData?.isSecure ?? true)

                                icon: "wifi"
                                name: modelData?.ssid || "Unknown"
                                meta: root.apMeta(modelData)
                                secure: !!modelData?.isSecure
                                trailingText: (!apRow.isActive && typeof modelData?.strength === "number")
                                    ? `${modelData.strength}` : ""
                                chipText: apRow.isActive ? "Connected" : ""
                                chipVariant: "live"
                                clickable: apRow.isActive || apRow.isKnown || apRow.isOpen
                                showSeparator: index < networksRepeater.count - 1
                                onActivated: root.tryConnect(modelData)
                            }
                        }

                        DeviceRow {
                            visible: Network.friendlyWifiNetworks.length === 0
                            icon: "search"
                            name: Network.wifiScanning ? "Scanning…" : "No networks found"
                            meta: Network.wifiScanning ? "" : "Tap to refresh"
                            clickable: !Network.wifiScanning
                            onActivated: Network.rescanWifi()
                        }
                    }
                }
            }
        }

        GroupLabel { text: "ETHERNET" }

        GroupBox {
            DeviceRow {
                icon: "settings_ethernet"
                name: Network.ethernetDevice || "Ethernet"
                meta: Network.ethernetConnected
                    ? (Network.ethernetSpeed ? `Connected · ${Network.ethernetSpeed}` : "Connected")
                    : "Cable not connected"
                chipText: Network.ethernetConnected ? "Connected" : "Idle"
                chipVariant: Network.ethernetConnected ? "live" : "default"
            }
        }
    }
}
