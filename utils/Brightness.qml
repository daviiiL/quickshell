pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property real current: 0

    Process {
        id: curBrightnessProc
        command: ["brillo"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: root.current = this.text
        }
    }
}
