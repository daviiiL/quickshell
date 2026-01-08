pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property string osName: ""
    property string osVersion: ""
    property string osPrettyName: ""

    property string hostName: ""
    property string hostModel: ""
    property string hostVendor: ""

    property string kernelVersion: ""
    property string kernelArchitecture: ""

    property string cpuModel: ""
    property int cpuCores: 0
    property int cpuThreads: 0
    property real cpuBaseFrequency: 0
    property real cpuMaxFrequency: 0

    property var gpus: []

    property real memoryTotal: 0
    property real memoryUsed: 0
    property real memoryPercentage: 0

    property real diskTotal: 0
    property real diskUsed: 0
    property real diskAvailable: 0
    property real diskPercentage: 0

    property real uptimeSeconds: 0

    property bool loaded: false

    readonly property string configPath: Quickshell.env("HOME") + "/.config/quickshell/assets/fastfetch-system-info.jsonc"
    readonly property string cacheFilePath: Quickshell.env("HOME") + "/.cache/quickshell_sysinfo.json"

    Component.onCompleted: {
        fastfetchProc.exec(["fastfetch", "--json", "--config", root.configPath]);
    }

    function formatBytes(bytes) {
        if (bytes === 0) return "0 B";
        const k = 1024;
        const sizes = ["B", "KB", "MB", "GB", "TB"];
        const i = Math.floor(Math.log(bytes) / Math.log(k));
        return (bytes / Math.pow(k, i)).toFixed(2) + " " + sizes[i];
    }

    function formatUptime(seconds) {
        const days = Math.floor(seconds / 86400);
        const hours = Math.floor((seconds % 86400) / 3600);
        const minutes = Math.floor((seconds % 3600) / 60);

        if (days > 0) {
            return `${days}d ${hours}h ${minutes}m`;
        } else if (hours > 0) {
            return `${hours}h ${minutes}m`;
        } else {
            return `${minutes}m`;
        }
    }

    Process {
        id: fastfetchProc

        property string jsonBuffer: ""

        stdout: SplitParser {
            onRead: data => {
                fastfetchProc.jsonBuffer += data;
            }
        }

        onExited: (exitCode, exitStatus) => {
            // console.debug("SystemInfo: fastfetch process exited with code:", exitCode);
            if (exitCode === 0) {
                try {
                    const jsonData = JSON.parse(fastfetchProc.jsonBuffer);
                    root.parseData(jsonData);
                    root.loaded = true;
                    // console.debug("SystemInfo: Data parsed successfully, loaded =", root.loaded);
                    // console.debug("SystemInfo: Memory used:", root.memoryUsed, "Disk used:", root.diskUsed);

                    saveCacheProc.exec(["bash", "-c", `cat > "${root.cacheFilePath}" <<'EOF'\n${fastfetchProc.jsonBuffer}\nEOF`]);
                } catch (e) {
                    console.error("Failed to parse fastfetch JSON:", e);
                }
            } else {
                console.error("Fastfetch failed with exit code:", exitCode);
            }
            fastfetchProc.jsonBuffer = "";
        }
    }

    Process {
        id: saveCacheProc
    }

    function parseData(jsonArray) {
        for (let i = 0; i < jsonArray.length; i++) {
            const item = jsonArray[i];

            switch (item.type) {
                case "OS":
                    root.osName = item.result.name || "";
                    root.osVersion = item.result.version || "";
                    root.osPrettyName = item.result.prettyName || "";
                    break;

                case "Host":
                    root.hostName = item.result.name || "";
                    root.hostModel = item.result.name || "";
                    root.hostVendor = item.result.vendor || "";
                    break;

                case "Kernel":
                    root.kernelVersion = item.result.release || "";
                    root.kernelArchitecture = item.result.architecture || "";
                    break;

                case "CPU":
                    root.cpuModel = item.result.cpu || "";
                    root.cpuCores = item.result.cores?.physical || 0;
                    root.cpuThreads = item.result.cores?.logical || 0;
                    root.cpuBaseFrequency = item.result.frequency?.base || 0;
                    root.cpuMaxFrequency = item.result.frequency?.max || 0;
                    break;

                case "GPU":
                    if (Array.isArray(item.result)) {
                        root.gpus = item.result.map(gpu => ({
                            name: gpu.name || "",
                            vendor: gpu.vendor || "",
                            driver: gpu.driver || "",
                            type: gpu.type || ""
                        }));
                    }
                    break;

                case "Memory":
                    root.memoryTotal = item.result.total || 0;
                    root.memoryUsed = item.result.used || 0;
                    root.memoryPercentage = root.memoryTotal > 0 ? (root.memoryUsed / root.memoryTotal) : 0;
                    break;

                case "Disk":
                    if (Array.isArray(item.result) && item.result.length > 0) {
                        const rootDisk = item.result.find(disk => disk.mountpoint === "/") || item.result[0];
                        root.diskTotal = rootDisk.bytes?.total || 0;
                        root.diskUsed = rootDisk.bytes?.used || 0;
                        root.diskAvailable = rootDisk.bytes?.available || 0;
                        root.diskPercentage = root.diskTotal > 0 ? (root.diskUsed / root.diskTotal) : 0;
                    }
                    break;

                case "Uptime":
                    root.uptimeSeconds = (item.result.uptime || 0) / 1000;
                    break;
            }
        }
    }

    function refresh() {
        // console.debug("SystemInfo: refresh() called");
        fastfetchProc.jsonBuffer = "";
        fastfetchProc.exec(["fastfetch", "--json", "--config", root.configPath]);
        // console.debug("SystemInfo: fastfetch process started");
    }
}
