pragma Singleton

import QtQuick
import Quickshell

import Niri 0.1

Singleton {
    id: root

    readonly property Niri niri: Niri {
        Component.onCompleted: connect()

        onErrorOccurred: function (error) {
            console.error("Error:", error);
        }
    }

    readonly property var workspaces: niri.workspaces
    readonly property var windows: niri.windows
    readonly property int workspacesShown: 10

    property string focusedOutput: ""

    function _recomputeFocusedOutput() {
        for (let i = 0; i < _wsTracker.count; i++) {
            const o = _wsTracker.objectAt(i);
            if (o && o.isFocused) {
                root.focusedOutput = o.output;
                return;
            }
        }
        root.focusedOutput = "";
    }

    Instantiator {
        id: _wsTracker
        model: root.niri.workspaces
        delegate: QtObject {
            required property var model
            readonly property bool isFocused: model.isFocused ?? false
            readonly property string output: model.output ?? ""
            onIsFocusedChanged: root._recomputeFocusedOutput()
            onOutputChanged: root._recomputeFocusedOutput()
        }
        onObjectAdded: root._recomputeFocusedOutput()
        onObjectRemoved: root._recomputeFocusedOutput()
    }
}
