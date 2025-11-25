pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.UPower

Singleton {
    id: root

    // Exposed properties for critical sensor data
    property real cpuTemp: 0
    property real gpuTemp: 0
    property real nvmeTemp: 0
    property bool initialized: false
    property string lastError: ""

    // Run when not in powersave mode (Performance or Balanced)
    readonly property bool shouldRunSensors: PowerProfiles.profile !== PowerProfile.PowerSaver

    // Timer to periodically refresh sensor data
    Timer {
        id: refreshTimer
        interval: 5000 // Update every 5 seconds
        running: root.shouldRunSensors
        repeat: true
        onTriggered: readSensors.running = true
    }

    Process {
        id: readSensors
        command: ["sensors"]
        stdout: StdioCollector {
            onStreamFinished: {
                root.parseSensorsOutput(this.text)
                root.initialized = true
            }
        }
        stderr: StdioCollector {
            onStreamFinished: {
                if (this.text.length > 0) {
                    // Filter out harmless sensor subfeature warnings
                    const filteredErrors = this.text
                        .split('\n')
                        .filter(line => !line.includes("Can't get value of subfeature") &&
                                       !line.includes("Can't read") &&
                                       line.trim().length > 0)
                        .join('\n')

                    if (filteredErrors.length > 0) {
                        root.lastError = filteredErrors
                        console.warn("Sensors error:", filteredErrors)
                    }
                }
            }
        }
    }

    function parseSensorsOutput(output) {
        const lines = output.split('\n')

        for (let i = 0; i < lines.length; i++) {
            const line = lines[i].trim()

            // Parse CPU temperature
            // AMD (k10temp): Tctl:
            if (line.startsWith('Tctl:')) {
                const match = line.match(/\+?(-?\d+\.?\d*)°C/)
                if (match) {
                    root.cpuTemp = parseFloat(match[1])
                }
            }
            // Intel (coretemp): Package id 0:
            if (line.startsWith('Package id 0:')) {
                const match = line.match(/\+?(-?\d+\.?\d*)°C/)
                if (match) {
                    root.cpuTemp = parseFloat(match[1])
                }
            }

            // Parse GPU temperature
            // AMD (amdgpu): edge:
            if (line.startsWith('edge:')) {
                const match = line.match(/\+?(-?\d+\.?\d*)°C/)
                if (match) {
                    root.gpuTemp = parseFloat(match[1])
                }
            }
            // Dell/Generic: Video:
            if (line.startsWith('Video:')) {
                const match = line.match(/\+?(-?\d+\.?\d*)°C/)
                if (match) {
                    root.gpuTemp = parseFloat(match[1])
                }
            }

            // Parse NVMe temperature (Composite)
            if (line.startsWith('Composite:')) {
                const match = line.match(/\+?(-?\d+\.?\d*)°C/)
                if (match) {
                    root.nvmeTemp = parseFloat(match[1])
                }
            }
        }
    }

    // Get status level for UI coloring
    function getTempLevel(temp) {
        if (temp > 70) return "critical"
        if (temp >= 50) return "warning"
        return "normal"
    }

    // Format temperature for display
    function formatTemp(temp) {
        if (temp === 0) return "--"
        return Math.round(temp) + "°C"
    }

    Component.onCompleted: {
        // Initial read if not in powersave mode
        if (root.shouldRunSensors) {
            readSensors.running = true
        }
    }

    // Watch for power profile changes
    onShouldRunSensorsChanged: {
        if (root.shouldRunSensors) {
            // Entering active mode (Performance or Balanced), start reading
            readSensors.running = true
        } else {
            // Entering powersave mode, reset temps
            root.cpuTemp = 0
            root.gpuTemp = 0
            root.nvmeTemp = 0
        }
    }
}
