pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Window
import Quickshell.Services.SystemTray
import qs.common

Rectangle {
    id: root

    color: "transparent"

    Column {
        id: layout
        spacing: 10

        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            bottomMargin: 10
            topMargin: 10
        }

        add: Transition {
            NumberAnimation {
                properties: "scale"
                from: 0
                to: 1
                duration: Theme.anim.durations.md
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Theme.anim.curves.standardDecel
            }
        }

        move: Transition {
            NumberAnimation {
                properties: "scale"
                to: 1
                duration: Theme.anim.durations.md
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Theme.anim.curves.standardDecel
            }
            NumberAnimation {
                properties: "x,y"
                duration: Theme.anim.durations.md
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Theme.anim.curves.standard
            }
        }

        Repeater {
            id: trayItems
            model: SystemTray.items

            TrayItem {
                id: trayItem
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }
}
