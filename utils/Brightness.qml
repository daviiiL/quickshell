pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

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

    signal brightnessChanged(real val)
    signal brightnessInitialized(bool initialized)

    Process {
        id: readBrightness
        command: ["brillo"]
        stdout: StdioCollector {
            onStreamFinished: {
                root.current = this.text;
                root.brightnessChanged(this.text);
            }
        }

        // onExited: {
        //     console.log("process readBrightness exited");
        // }
    }

    FileView {
        id: maxBrightness
        path: Qt.resolvedUrl(root.maxBrightnessPath)
        blockLoading: true
        blockWrites: true
        onLoaded: {
            root.initialized = false;
            // console.log("FileView maxBrightness read max", this.text());
            root.max = this.text();
            root._maxLoaded = true;
            root.checkInitDone();
        }
    }

    FileView {
        id: curBrightness
        path: Qt.resolvedUrl(root.curBrightnessPath)
        blockLoading: true
        blockWrites: true
        watchChanges: true
        onLoaded: {
            root.initialized = false;
            // console.log("FileView curBrightness read cur", this.text());
            root.current = this.text();
            root._curLoaded = true;
            root.checkInitDone();
        }
        onFileChanged: {
            // console.log("brightness change detected");
            this.reload();
        }
    }

    Process {
        id: getBacklightDir
        command: ["sh", "-c", "ls /sys/class/backlight | head -n 1"]
        stdout: StdioCollector {
            onStreamFinished: {
                const path = "/sys/class/backlight/" + this.text.slice(0, this.text.length - 1 || 0);
                const maxBrightnessPath = path + "/max_brightness";
                const curBrightnessPath = path + "/brightness";

                root.backlightDevPath = path;
                root.maxBrightnessPath = maxBrightnessPath;
                root.curBrightnessPath = curBrightnessPath;
                // console.log(JSON.stringify({
                //     rootPath: root.backlightDevPath,
                //     maxPath: root.maxBrightnessPath,
                //     curPath: root.curBrightnessPath
                // }));
            }
        }

        // onExited: {
        //     console.log("process getBacklightDir exited");
        // }
    }

    function getBrightness() {
        readBrightness.running = true;
    }

    function initialize() {
        getBacklightDir.running = true;
    }

    function checkInitDone() {
        if (root._curLoaded && root._maxLoaded) {
            root.initialized = true;
            // console.log("Brightness initialized", root.initialized);
            root.refresh();
        }
        // else
        // console.log("brightness NOT initialized, val", root.initialized);
        // NOTE: this is a test behavior... don't use yet
        root.brightnessInitialized(root.initialized);
    }

    function refresh() {
        const percentage = ((root.current / root.max) * 100).toPrecision(4);
        // console.log("BRIGHTNESS: signaling change", percentage);
        root.brightnessChanged(percentage);
    }

    Component.onCompleted: {
        initialize();
        //getBrightness();
    }
}
