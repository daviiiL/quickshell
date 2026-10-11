pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property string toolName: "brightnessctl"
    readonly property real brightness: _brightness

    readonly property bool toolAvailable: _toolAvailable
    readonly property bool deviceAvailable: _pathsReady
    readonly property bool probing: !_toolProbed || !_deviceProbed
    readonly property bool available: toolAvailable && deviceAvailable

    readonly property string unavailableReason: probing ? "" : _reasonFor(toolAvailable, deviceAvailable)

    function _reasonFor(tool, device) {
        if (tool && device) return "";
        if (!device) return "No backlight device found";
        return toolName + " is not installed";
    }

    property real _brightness: 0
    property int _current: 0
    property int _max: 1
    property string _backlightPath: ""
    property string _backlightDevice: ""
    property string _brightnessPath: ""
    property string _maxBrightnessPath: ""
    property bool _pathsReady: false
    property bool _toolAvailable: false
    property bool _toolProbed: false
    property bool _deviceProbed: false

    // Probed once; restart the shell to re-detect.
    Component.onCompleted: {
        checkToolProc.running = true;
        getBacklightDir.running = true;
    }

    onProbingChanged: {
        if (probing) return;
        const reason = _reasonFor(toolAvailable, deviceAvailable);
        console.log("[Brightness] probe finished: tool=" + toolAvailable
            + " device=" + deviceAvailable + " available=" + (toolAvailable && deviceAvailable)
            + (reason ? " reason='" + reason + "'" : ""));
    }

    function increaseBrightness() {
        setBrightness(brightness + 5);
    }

    function decreaseBrightness() {
        setBrightness(brightness - 5);
    }

    function setBrightness(value) {
        if (!available)
            return;
        value = Math.max(1, Math.min(100, value));
        setProc.command = [root.toolName, "--class", "backlight", "s", value + "%", "--quiet", "-d", root._backlightDevice];
        setProc.running = true;
    }

    Process {
        id: checkToolProc

        command: ["sh", "-c", "command -v " + root.toolName + " >/dev/null 2>&1 && echo ok || echo missing"]

        stdout: StdioCollector {
            onStreamFinished: {
                root._toolAvailable = this.text.trim() === "ok";
                root._toolProbed = true;
            }
        }
    }

    Process {
        id: getBacklightDir

        command: ["sh", "-c", "ls /sys/class/backlight | head -n 1"]

        stdout: StdioCollector {
            onStreamFinished: {
                const device = this.text.trim();
                if (device.length > 0) {
                    root._backlightPath = "/sys/class/backlight/" + device;
                    root._backlightDevice = device;
                    checkPathsProc.running = true;
                } else {
                    root._deviceProbed = true;
                }
            }
        }
    }

    Process {
        id: checkPathsProc

        command: ["sh", "-c", "test -f '" + root._backlightPath + "/brightness' && test -f '" + root._backlightPath + "/max_brightness' && echo 'ok' || echo 'missing'"]

        stdout: StdioCollector {
            onStreamFinished: {
                if (this.text.trim() === "ok") {
                    root._brightnessPath = root._backlightPath + "/brightness";
                    root._maxBrightnessPath = root._backlightPath + "/max_brightness";
                    root._pathsReady = true;
                }
                root._deviceProbed = true;
            }
        }
    }

    Process {
        id: setProc
    }

    FileView {
        id: maxBrightness

        path: root._maxBrightnessPath !== "" ? "file://" + root._maxBrightnessPath : ""
        blockLoading: !root._pathsReady
        blockWrites: true

        onLoaded: {
            const value = parseInt(this.text());
            if (!isNaN(value) && value > 0) {
                root._max = value;
                root._updateBrightness();
            }
        }
    }

    FileView {
        id: curBrightness

        path: root._brightnessPath !== "" ? "file://" + root._brightnessPath : ""
        blockLoading: !root._pathsReady
        blockWrites: true
        watchChanges: true

        onLoaded: {
            const value = parseInt(this.text());
            if (!isNaN(value)) {
                root._current = value;
                root._updateBrightness();
            }
        }

        onFileChanged: this.reload()
    }

    function _updateBrightness() {
        if (_max > 0)
            root._brightness = (_current / _max) * 100;
    }

    IpcHandler {
        target: "brightness"

        function increment() {
            root.increaseBrightness();
        }

        function decrement() {
            root.decreaseBrightness();
        }
    }
}
