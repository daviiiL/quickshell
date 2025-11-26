pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

LazyLoader {
    id: root

    loading: true
    required property var parent
    required property list<real> spawnCoordinates

    PopupWindow {
        id: popup
        parentWindow: root.parent.QsWindow.window
        relativeX: root.spawnCoordinates[0]
        relativeY: root.spawnCoordinates[1]

        color: "red"

        width: 200
        height: 200
    }
}
