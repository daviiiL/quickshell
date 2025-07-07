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
                // const splitIndex = line.trim().indexOf(" ");
                // console.log(splitIndex);
                // if (splitIndex) {
                //     const [key, action] = [line.slice(0, splitIndex).trim(), line.slice(splitIndex + 1).trim()];
                //     console.log(JSON.stringify({
                //         key,
                //         action
                //     }));
                // }
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
