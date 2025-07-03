pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property real current: 0
    readonly property real max: 100
    readonly property real min: 0

    signal brightnessChanged(real val)

    Process {
        id: readBrightness
        command: ["brillo"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                root.current = this.text;
                root.brightnessChanged(this.text);
            }
        }
    }

    function getBrightness() {
        readBrightness.running = true;
        return current;
    }

    Component.onCompleted: {
        readBrightness.running = true;
    }
}
