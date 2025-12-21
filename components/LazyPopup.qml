pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland

LazyLoader {
    id: root
    loading: true
    required property var parent
    required property list<real> spawnCoordinates

    signal dismissed

    PopupWindow {
        id: popup

        parentWindow: root.parent
        relativeX: root.spawnCoordinates[0] - width / 2
        relativeY: root.spawnCoordinates[1] - height / 2

        width: 420
        height: 320
        visible: true
        color: "transparent"

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

        Shortcut {
            sequence: "Escape"
            onActivated: root.dismissed()
        }

        Rectangle {
            anchors.fill: parent
            radius: 12
            color: "#2b2b2b"

            Text {
                anchors.centerIn: parent
                text: "Launcher Popup"
                color: "white"
            }

            MouseArea {
                anchors.fill: parent
                onClicked: function () {
                    console.debug("dismissing this son of a bitch");
                    root.dismissed();
                }
            }
        }
    }
}
