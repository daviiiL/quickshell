pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.UPower

Singleton {
    id: root

    property real cpuTemp: 0
    property real gpuTemp: 0
    property real nvmeTemp: 0
    property bool initialized: false
    property string lastError: ""

    readonly property bool shouldRunSensors: PowerProfiles.profile !== PowerProfile.PowerSaver

    Timer {
        id: refreshTimer
        interval: 5000
        running: root.shouldRunSensors
        repeat: true
        onTriggered: readSensors.running = true
    }

    Process {
        id: readSensors
        command: ["sensors"]
        stdout: StdioCollector {
            onStreamFinished: {
                root.parseSensorsOutput(this.text);
                root.initialized = true;
            }
        }
        stderr: StdioCollector {
            onStreamFinished: {
                if (this.text.length > 0) {
                    const filteredErrors = this.text.split('\n').filter(line => !line.includes("Can't get value of subfeature") && !line.includes("Can't read") && line.trim().length > 0).join('\n');

                    if (filteredErrors.length > 0) {
                        root.lastError = filteredErrors;
                        console.warn("Sensors error:", filteredErrors);
                    }
                }
            }
        }
    }

    function parseSensorsOutput(output) {
        const lines = output.split('\n');

        for (let i = 0; i < lines.length; i++) {
            const line = lines[i].trim();

            if (line.startsWith('Tctl:')) {
                const match = line.match(/\+?(-?\d+\.?\d*)°C/);
                if (match) {
                    root.cpuTemp = parseFloat(match[1]);
                }
            }

            if (line.startsWith('Package id 0:')) {
                const match = line.match(/\+?(-?\d+\.?\d*)°C/);
                if (match) {
                    root.cpuTemp = parseFloat(match[1]);
                }
            }

            if (line.startsWith('edge:')) {
                const match = line.match(/\+?(-?\d+\.?\d*)°C/);
                if (match) {
                    root.gpuTemp = parseFloat(match[1]);
                }
            }

            if (line.startsWith('Video:')) {
                const match = line.match(/\+?(-?\d+\.?\d*)°C/);
                if (match) {
                    root.gpuTemp = parseFloat(match[1]);
                }
            }

            if (line.startsWith('Composite:')) {
                const match = line.match(/\+?(-?\d+\.?\d*)°C/);
                if (match) {
                    root.nvmeTemp = parseFloat(match[1]);
                }
            }
        }
    }

    function getTempLevel(temp) {
        if (temp > 70)
            return "critical";
        if (temp >= 50)
            return "warning";
        return "normal";
    }

    function formatTemp(temp) {
        if (temp === 0)
            return "--";
        return Math.round(temp) + "°C";
    }

    Component.onCompleted: {
        if (root.shouldRunSensors) {
            readSensors.running = true;
        }
    }

    onShouldRunSensorsChanged: {
        if (root.shouldRunSensors) {
            readSensors.running = true;
        } else {
            root.cpuTemp = 0;
            root.gpuTemp = 0;
            root.nvmeTemp = 0;
        }
    }
}
