pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

Singleton {
    id: root

    readonly property real brightness: _brightness
    readonly property bool available: Power.isLaptopBattery

    property real _brightness: 0
    property int _current: 0
    property int _max: 1
    property string _backlightPath: ""
    property string _brightnessPath: ""
    property string _maxBrightnessPath: ""
    property bool _pathsReady: false

    onAvailableChanged: {
        if (available && !_pathsReady) {
            getBacklightDir.running = true;
        }
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
        setProc.command = ["brightnessctl", "--class", "backlight", "s", value + "%", "--quiet"];
        setProc.running = true;
    }

    Process {
        id: getBacklightDir

        command: ["sh", "-c", "ls /sys/class/backlight | head -n 1"]

        stdout: StdioCollector {
            onStreamFinished: {
                const device = this.text.trim();
                if (device.length > 0) {
                    root._backlightPath = "/sys/class/backlight/" + device;
                    checkPathsProc.running = true;
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
            // console.debug("Max brightness loaded:", this.text());
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
            // console.debug("Current brightness loaded:", this.text());
            const value = parseInt(this.text());
            if (!isNaN(value)) {
                root._current = value;
                root._updateBrightness();
            }
        }

        onFileChanged: {
            // console.debug("Brightness file changed");
            this.reload();
        }
    }

    function _updateBrightness() {
        if (_max > 0) {
            const newBrightness = (_current / _max) * 100;
            root._brightness = newBrightness;
        }
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

    GlobalShortcut {
        name: "brightnessIncrease"
        description: "Increase brightness"
        onPressed: root.increaseBrightness()
    }

    GlobalShortcut {
        name: "brightnessDecrease"
        description: "Decrease brightness"
        onPressed: root.decreaseBrightness()
    }
}
