pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property string currentLayoutCode: "us"
    property string currentLayoutName: "US"

    Process {
        id: layoutProc
        running: true
        command: ["bash", "-c", "hyprctl devices -j | jq -r '.keyboards[0].active_keymap'"]
        stdout: StdioCollector {
            id: layoutCollector
            onStreamFinished: {
                const layout = layoutCollector.text.trim();
                if (layout.length > 0) {
                    root.currentLayoutName = layout;
                    root.currentLayoutCode = layout.substring(0, 2).toLowerCase();
                }
            }
        }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: {
            layoutProc.running = true;
        }
    }

    Component.onCompleted: {
        layoutProc.running = true;
    }
}
