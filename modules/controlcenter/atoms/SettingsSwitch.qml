pragma ComponentBehavior: Bound

import QtQuick
import qs.common

Rectangle {
    id: root

    property bool checked: false
    property bool available: true

    signal toggled()

    readonly property int animMs: Theme.anim.durations.xs * 0.6
    readonly property int thumbSize: 14
    readonly property int thumbInset: 2

    implicitWidth: 32
    implicitHeight: 18
    radius: height / 2
    opacity: root.available ? 1.0 : 0.45

    color: root.checked ? Colors.surfaceContainerHigh : Colors.surfaceContainer
    border.color: root.checked ? Colors.hairHot : Colors.hair
    border.width: Theme.ui.mainBarHairWidth

    Behavior on color        { ColorAnimation { duration: root.animMs } }
    Behavior on border.color { ColorAnimation { duration: root.animMs } }
    Behavior on opacity      { NumberAnimation { duration: root.animMs } }

    Rectangle {
        width: root.thumbSize
        height: root.thumbSize
        radius: width / 2
        y: (root.height - height) / 2
        x: root.checked ? root.width - width - root.thumbInset : root.thumbInset
        color: root.checked ? Colors.barAccent : Colors.inkDim

        Behavior on x     { NumberAnimation { duration: root.animMs * 1.2; easing.type: Easing.OutCubic } }
        Behavior on color { ColorAnimation  { duration: root.animMs } }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: root.available
        cursorShape: root.available ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: { if (root.available) root.toggled() }
    }
}
