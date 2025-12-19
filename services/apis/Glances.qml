pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

import qs.common

Singleton {
    id: root
    property bool glancesNotInstalledNotified: false
    property bool isServerRunning: false
    property bool sensorsInitialized: false
    property bool quicklookInitialized: false
    property string glancesVersion: ""

    readonly property CPU cpu: CPU {}
    readonly property GPU gpu: GPU {}
    readonly property STORAGE storage: STORAGE {}
    readonly property RAM ram: RAM {}

    component CPU: QtObject {
        readonly property real packageTemp: cpuPackageTemp
        readonly property real totalUtilization: cpuTotal
        readonly property real currentFrequency: cpuCurrentFrequency
        readonly property real maxFrequency: cpuMaxFrequency
        readonly property real frequencyPercentage: cpuCurrentFrequency * 100 / cpuMaxFrequency
    }

    component GPU: QtObject {
        readonly property real temp: gpuTemp
    }

    component STORAGE: QtObject {
        readonly property real temp: storageTemp
    }

    component RAM: QtObject {
        readonly property real temp: memoryTemp
    }

    property real cpuPackageTemp: 0
    property real cpuTotal: 0
    property real cpuCurrentFrequency: 0
    property real cpuMaxFrequency: 0
    property real gpuTemp: 0
    property real storageTemp: 0
    property real memoryTemp: 0

    function onError(status, error) {
        console.warn("Glances Server Error: ", status, error);
    }

    ApiClient {
        id: glances
        baseUrl: "http://0.0.0.0:61208/api/4/"
    }

    function _initialize() {
        glances.get("status", function (data) {
            glancesVersion = data.version;
            isServerRunning = true;

            // initial run after verifying the server is running
            getSensors();
            getQuicklook();
        }, function (status, error) {
            onError(status, error);

            isServerRunning = false;

            // notify send the first time to prevent looping
            //
            if (!root.glancesNotInstalledNotified) {
                notifyGlancesMissing.running = true;
                glancesNotInstalledNotified = true;
            }
        });
    }

    Process {
        id: notifyGlancesMissing
        running: false
        command: ["notify-send", '-a', 'System Shell', "SysInfo Not Initialized", "Unable to communicate with Glances. Please install glances or start a daemon", '--urgency', "critical"]
    }

    function getSensors() {
        if (isServerRunning)
            glances.get("sensors", function (data) {
                for (const item of data) {
                    if (item) {
                        const label = item.label;
                        switch (label) {
                        case "CPU":
                            root.cpuPackageTemp = item.value;
                            break;
                        case "Video":
                            root.gpuTemp = item.value;
                            break;
                        case "SODIMM":
                        case "DIMM":
                            root.memoryTemp = item.value;
                            break;
                        case "HDD":
                            root.storageTemp = item.value;
                            break;
                        }
                    }
                }
                if (!sensorsInitialized)
                    sensorsInitialized = true;
            }, onError);
    }

    Timer {
        id: getSensorsTimer
        interval: 1500
        repeat: true
        running: sensorsInitialized
        onTriggered: function () {
            getSensors();
        }
    }

    function getQuicklook() {
        if (isServerRunning) {
            glances.get("quicklook", function (data) {
                cpuTotal = data.cpu;
                cpuCurrentFrequency = data.cpu_hz_current ?? "0";
                cpuMaxFrequency = data.cpu_hz ?? "0";
                if (!root.quicklookInitialized) {
                    root.quicklookInitialized = true;
                }
            }, onError);
        }
    }

    Timer {
        id: getQuicklookTimer
        interval: 1500
        repeat: true
        running: quicklookInitialized
        onTriggered: function () {
            getQuicklook();
        }
    }

    Component.onDestruction: {
        getSensorsTimer.destroy();
        getQuicklookTimer.destroy();
    }

    Component.onCompleted: {
        root._initialize();
        console.info("Glances services initialized");
    }
}
