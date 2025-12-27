pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

import qs.common

Singleton {
    id: root

    property bool glancesNotInstalledNotified: false
    property bool isServerRunning: false
    property bool readDGPU: false

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
        readonly property real vramUtilization: gpuVRAM
        readonly property real utilization: gpuUtilization
    }

    component STORAGE: QtObject {
        readonly property real temp: storageTemp
    }

    component RAM: QtObject {
        readonly property real temp: memoryTemp
        readonly property real utilization: memoryUsePercentage
    }

    property real cpuPackageTemp: 0
    property real cpuTotal: 0
    property real cpuCurrentFrequency: 0
    property real cpuMaxFrequency: 0
    property real gpuTemp: 0
    property real gpuVRAM: 0
    property real gpuUtilization: 0
    property real storageTemp: 0
    property real memoryTemp: 0
    property real memoryUsePercentage: 0

    ApiClient {
        id: glances
        baseUrl: "http://0.0.0.0:61208/api/4/"
    }

    Process {
        id: laptopModeNotification
        command: ["notify-send", "-a", "System Shell", "Laptop Mode Enabled", "dGPU reading disabled to extend battery life on laptops", "--urgency", "critical"]
    }

    Process {
        id: glancesErrorNotification
        command: ["notify-send", "-a", "System Shell", "SysInfo Not Initialized", "Unable to communicate with Glances. Please install glances or start a daemon", "--urgency", "critical"]
    }

    Timer {
        interval: 2500
        repeat: true
        running: isServerRunning
        onTriggered: {
            getSensors();
            getQuicklook();
            if (!GlobalStates.isLaptop && readDGPU) {
                getGpu();
            }
        }
    }

    Timer {
        id: initializationTimer
        interval: 2000
        repeat: true
        running: true
        onTriggered: initialize()
    }

    function initialize() {
        glances.get("status", function (data) {
            isServerRunning = true;
            console.info("Glances services initialized");

            getSensors();
            getQuicklook();

            if (!GlobalStates.isLaptop) {
                readDGPU = true;
                getGpu();
            } else {
                laptopModeNotification.running = true;
            }

            initializationTimer.repeat = false;
            initializationTimer.stop();
        }, function (status, error) {
            console.warn("Glances Server Error:", status, error);
            isServerRunning = false;

            if (!glancesNotInstalledNotified) {
                glancesErrorNotification.running = true;
                glancesNotInstalledNotified = true;
            }
        });
    }

    function getSensors() {
        if (!isServerRunning)
            return;

        glances.get("sensors", function (data) {
            for (const item of data) {
                if (!item)
                    continue;

                switch (item.label) {
                case "CPU":
                case "Package id 0":
                    cpuPackageTemp = item.value;
                    break;
                case "Video":
                    if (!readDGPU)
                        gpuTemp = item.value;
                    break;
                case "SODIMM":
                case "DIMM":
                case "spd5118 0":
                case "spd5118 1":
                    memoryTemp = Math.max(item.value, memoryTemp);
                    break;
                case "HDD":
                case "Composite":
                    storageTemp = Math.max(item.value, storageTemp);
                    break;
                }
            }
        }, logError);
    }

    function getQuicklook() {
        if (!isServerRunning)
            return;

        glances.get("quicklook", function (data) {
            cpuTotal = data.cpu;
            cpuCurrentFrequency = data.cpu_hz_current ?? 0;
            cpuMaxFrequency = data.cpu_hz ?? 0;
            memoryUsePercentage = data.mem;
        }, logError);
    }

    function getGpu() {
        if (!isServerRunning || GlobalStates.isLaptop || !readDGPU)
            return;

        glances.get("gpu", function (data) {
            const selectedGpu = data[0];
            gpuTemp = selectedGpu.temperature;
            gpuVRAM = selectedGpu.mem;
            gpuUtilization = selectedGpu.proc;
        }, logError);
    }

    function logError(status, error) {
        console.warn("Glances API Error:", status, error);
    }
}
