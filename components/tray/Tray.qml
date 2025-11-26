pragma ComponentBehavior: Bound

import "../../common/"
import QtQuick
import QtQuick.Window
import Quickshell
import Quickshell.Services.SystemTray

Rectangle {
    id: root

    anchors.horizontalCenter: parent.horizontalCenter
    anchors.bottomMargin: 20
    implicitWidth: Theme.bar.width
    implicitHeight: layout.height
    color: "transparent"

    Column {
        id: layout
        spacing: 10

        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }

        add: Transition {
            NumberAnimation {
                properties: "scale"
                from: 0
                to: 1
                duration: Theme.anim.durations.normal
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Theme.anim.curves.standardDecel
            }
        }

        move: Transition {
            NumberAnimation {
                properties: "scale"
                to: 1
                duration: Theme.anim.durations.normal
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Theme.anim.curves.standardDecel
            }
            NumberAnimation {
                properties: "x,y"
                duration: Theme.anim.durations.normal
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Theme.anim.curves.standard
            }
        }

        Repeater {
            id: trayItems
            model: SystemTray.items

            TrayItem {
                id: trayItem
                parentPositions: [root.x, root.y]
                anchors.horizontalCenter: parent.horizontalCenter
                onTrayItemClicked: coors => {
                    console.log(coors);
                    this.menu.anchor.margins.left = coors[0];
                    this.menu.anchor.margins.top = coors[1];
                    this.menu.open();
                }
            }
        }
    }
}
