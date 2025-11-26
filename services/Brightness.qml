import ".."
import QtQuick
import Quickshell
import Quickshell.Io
pragma Singleton

Singleton {
    id: root

    property real current
    property real max
    property real min: 0
    property string backlightDevPath
    property string maxBrightnessPath
    property string curBrightnessPath
    property bool initialized: false
    property bool _curLoaded: false
    property bool _maxLoaded: false
    property bool isDesktop: false

    signal brightnessChanged(real val)
    signal brightnessInitialized(bool initialized)
    signal brightnessCtlOff(bool disabled)

    function getBrightness() {
        readBrightness.running = true;
    }

    function initialize() {
        if (!root.isDesktop)
            getBacklightDir.running = true;

    }

    function checkInitDone() {
        if (root._curLoaded && root._maxLoaded) {
            root.initialized = true;
            root.refresh();
        }
        root.brightnessInitialized(root.initialized);
    }

    function refresh() {
        const percentage = ((root.current / root.max) * 100).toPrecision(4);
        root.brightnessChanged(percentage);
    }

    Component.onCompleted: {
        checkBattery.running = true;
    }

    Process {
        id: checkBattery

        command: ["sh", "-c", "upower -e | grep battery"]

        stdout: StdioCollector {
            onStreamFinished: {
                const hasBattery = this.text.trim().length > 0;
                root.isDesktop = !hasBattery;
                root.brightnessCtlOff(root.isDesktop);
                if (!root.isDesktop) {
                    root.initialize();
                } else {
                    GlobalStates.isLaptop = false;
                }
            }
        }

        stderr: StdioCollector {
            onStreamFinished: {
                if (this.text.length > 0 || checkBattery.stdout.text.trim().length === 0) {
                    root.isDesktop = true;
                    root.brightnessCtlOff(true);
                }
            }
        }

    }

    Process {
        id: readBrightness

        command: ["brillo"]

        stdout: StdioCollector {
            onStreamFinished: {
                root.current = this.text;
                root.brightnessChanged(this.text);
            }
        }

    }

    FileView {
        id: maxBrightness

        path: Qt.resolvedUrl(root.maxBrightnessPath)
        blockLoading: !root.isDesktop
        blockWrites: true
        onLoaded: {
            if (!root.isDesktop) {
                root.initialized = false;
                root.max = this.text();
                root._maxLoaded = true;
                root.checkInitDone();
            }
        }
    }

    FileView {
        id: curBrightness

        path: Qt.resolvedUrl(root.curBrightnessPath)
        blockLoading: !root.isDesktop
        blockWrites: true
        watchChanges: !root.isDesktop
        onLoaded: {
            if (!root.isDesktop) {
                root.initialized = false;
                root.current = this.text();
                root._curLoaded = true;
                root.checkInitDone();
            }
        }
        onFileChanged: {
            if (!root.isDesktop)
                this.reload();

        }
    }

    Process {
        id: getBacklightDir

        command: ["sh", "-c", "ls /sys/class/backlight | head -n 1"]

        stdout: StdioCollector {
            onStreamFinished: {
                if (!root.isDesktop) {
                    const path = "/sys/class/backlight/" + this.text.slice(0, this.text.length - 1 || 0);
                    const maxBrightnessPath = path + "/max_brightness";
                    const curBrightnessPath = path + "/brightness";
                    root.backlightDevPath = path;
                    root.maxBrightnessPath = maxBrightnessPath;
                    root.curBrightnessPath = curBrightnessPath;
                }
            }
        }

    }

}
