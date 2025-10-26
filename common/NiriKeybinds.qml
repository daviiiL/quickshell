pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property list<Keybind> keybinds: []

    function parseKeybinds(configText: string) {
        var isBinds = false;
        for (let line of configText.split("\n")) {
            if (line.startsWith("binds")) {
                isBinds = true;
            } else if (isBinds && !line.trim().startsWith("//") && line) {
                if (line.startsWith("}"))
                return;
                console.log(line);
            }
        }
    }

    FileView {
        id: niriConfigFile

        blockAllReads: true
        blockLoading: true
        blockWrites: true
        watchChanges: false
        path: Qt.resolvedUrl("../../../.config/niri/config.kdl")
        onLoaded: root.parseKeybinds(this.text())
    }

    component Keybind: QtObject {
        property string keys
        property string action
    }
}
