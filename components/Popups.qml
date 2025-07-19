pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

LazyLoader {
    id: root

    // start loading immediately
    loading: true
    required property var parent
    required property list<real> spawnCoordinates

    // this window will be loaded in the background during spare
    // frame time unless active is set to true, where it will be
    // loaded in the foreground
    PopupWindow {
        id: popup
        // position the popup above the button
        parentWindow: root.parent.QsWindow.window
        relativeX: root.spawnCoordinates[0]
        relativeY: root.spawnCoordinates[1]

        // some heavy component here
        color: "red"

        width: 200
        height: 200
    }
}
