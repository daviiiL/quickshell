pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.common

RowLayout {
    id: root

    property string iconSource: ""
    property real value: 0
    property real from: 0
    property real to: 1
    property string valueLabel: ""

    signal moved(real v)

    readonly property real _progress: {
        const range = root.to - root.from;
        if (range <= 0) return 0;
        return Math.max(0, Math.min(1, (root.value - root.from) / range));
    }

    Layout.fillWidth: true
    Layout.leftMargin: 14
    Layout.rightMargin: 14
    spacing: 12

    Image {
        Layout.preferredWidth: 18
        Layout.preferredHeight: 18
        Layout.alignment: Qt.AlignVCenter
        source: root.iconSource
        sourceSize.width: 36
        sourceSize.height: 36
        smooth: true
        opacity: 0.72
        visible: source != ""
    }

    Item {
        id: track
        Layout.fillWidth: true
        Layout.preferredHeight: 14
        Layout.alignment: Qt.AlignVCenter

        Rectangle {
            id: trackLine
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.right: parent.right
            height: 2
            radius: 1
            color: Colors.hair
        }

        Rectangle {
            id: fill
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            width: root._progress * trackLine.width
            height: 2
            radius: 1
            color: Colors.barAccent
        }

        Rectangle {
            id: thumb
            width: 10
            height: 10
            radius: 5
            color: Colors.barAccent
            border.color: Colors.surface
            border.width: 3
            anchors.verticalCenter: parent.verticalCenter
            x: root._progress * (trackLine.width - width)
            scale: drag.pressed ? 1.15 : (drag.containsMouse ? 1.05 : 1.0)
            Behavior on scale { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }
        }

        MouseArea {
            id: drag
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.LeftButton
            cursorShape: Qt.PointingHandCursor
            onPressed: mouse => root._commitX(mouse.x)
            onPositionChanged: mouse => { if (pressed) root._commitX(mouse.x); }
        }
    }

    Text {
        Layout.preferredWidth: 44
        Layout.alignment: Qt.AlignVCenter
        horizontalAlignment: Text.AlignRight
        text: root.valueLabel
        color: Colors.fgSurface
        font.family: Theme.font.family.inter_medium
        font.pixelSize: 13
        font.weight: Font.Medium
        font.letterSpacing: 0.2
    }

    function _commitX(x) {
        const t = Math.max(0, Math.min(1, x / track.width));
        const v = root.from + t * (root.to - root.from);
        root.moved(v);
    }
}
