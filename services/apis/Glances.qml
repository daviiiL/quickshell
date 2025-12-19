pragma Singleton

import Quickshell
import QtQuick

import qs.common

Singleton {
    id: root
    property bool isServerRunning: false
    property bool sensorsInitialized: false
    property string glancesVersion: ""

    readonly property CPU cpu: CPU {}
    readonly property GPU gpu: GPU {}
    readonly property STORAGE storage: STORAGE {}
    readonly property RAM ram: RAM {}

    component CPU: QtObject {
        readonly property real packageTemp: cpuPackageTemp
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
        }, function (status, error) {
            onError(status, error);
            isServerRunning = false;
        });
    }

    function getSensors() {
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

    Component.onDestruction: {
        getSensorsTimer.destroy();
    }

    Component.onCompleted: {
        root._initialize();
        console.log("Glances services initialized");
    }
}
