pragma ComponentBehavior: Bound

import QtQuick
import qs.common
import qs.widgets

Rectangle {
    id: root

    required property string icon
    property bool enabled: true
    property string tooltip: ""

    signal activated()

    readonly property bool hot: root.enabled && mouseArea.containsMouse
    readonly property int animMs: Theme.anim.durations.xs * 0.6

    implicitWidth: 26
    implicitHeight: 26
    radius: 3
    color: root.hot ? Colors.surfaceContainerLow : "transparent"
    opacity: root.enabled ? 1.0 : 0.35

    Behavior on color { ColorAnimation { duration: root.animMs } }
    Behavior on opacity { NumberAnimation { duration: root.animMs } }

    MaterialSymbol {
        anchors.centerIn: parent
        icon: root.icon
        iconSize: 16
        fontColor: root.hot ? Colors.fgSurface : Colors.inkDim
        Behavior on color { ColorAnimation { duration: root.animMs } }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: root.enabled
        cursorShape: root.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: { if (root.enabled) root.activated() }
    }
}
