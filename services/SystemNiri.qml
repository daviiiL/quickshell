pragma Singleton

import QtQuick
import Quickshell

import Niri 0.1

Singleton {
    id: root

    readonly property Niri niri: Niri {
        Component.onCompleted: connect()

        // onConnected: console.log("Connected to niri")
        onErrorOccurred: function (error) {
            console.error("Error:", error);
        }
    }

    readonly property var workspaces: niri.workspaces
    readonly property var windows: niri.windows
    readonly property int workspacesShown: 10
}
