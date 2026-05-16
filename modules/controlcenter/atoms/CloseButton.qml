pragma ComponentBehavior: Bound

import QtQuick
import qs.common
import qs.widgets

Rectangle {
    id: root

    signal activated()

    readonly property bool hot: mouseArea.containsMouse
    readonly property int animMs: Theme.anim.durations.xs * 0.6

    implicitWidth: 26
    implicitHeight: 26
    radius: 3
    color: root.hot ? Colors.surfaceContainerLow : "transparent"

    Behavior on color { ColorAnimation { duration: root.animMs } }

    MaterialSymbol {
        anchors.centerIn: parent
        icon: "close"
        iconSize: 16
        fontColor: root.hot ? Colors.fgSurface : Colors.inkFaint
        Behavior on color { ColorAnimation { duration: root.animMs } }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.activated()
    }
}
