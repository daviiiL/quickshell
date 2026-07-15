pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.common
import qs.widgets

Rectangle {
    id: root

    required property string icon
    required property string label
    property string sub: ""
    property bool on: false
    property bool available: true

    signal activated()

    readonly property bool hot: mouseArea.containsMouse
    readonly property int animMs: Theme.anim.durations.xs * 0.6

    implicitHeight: 100
    radius: Theme.ui.radius.sm
    color: {
        if (root.on) return Colors.surfaceContainerHigh;
        if (root.available && root.hot) return Qt.alpha(Colors.fgSurface, 0.04);
        return Colors.surfaceContainerLow;
    }
    border.color: root.on ? Colors.hairHot : Colors.hair
    border.width: Theme.ui.mainBarHairWidth
    opacity: root.available ? 1.0 : 0.45

    Behavior on color { ColorAnimation { duration: root.animMs } }
    Behavior on border.color { ColorAnimation { duration: root.animMs } }
    Behavior on opacity { NumberAnimation { duration: root.animMs } }

    ColumnLayout {
        anchors.fill: parent
        anchors.leftMargin: 14
        anchors.rightMargin: 14
        anchors.topMargin: 14
        anchors.bottomMargin: 18
        spacing: 6

        MaterialSymbol {
            icon: root.icon
            iconSize: 16
            fontColor: root.on ? Colors.fgSurface : Colors.inkDim
            Behavior on color { ColorAnimation { duration: root.animMs } }
        }

        Text {
            text: root.label.toUpperCase()
            color: root.on ? Colors.fgSurface : Colors.inkDim
            font.family: Theme.font.family.inter_medium
            font.pixelSize: Theme.font.size.xs
            font.weight: Font.Medium
            font.letterSpacing: 1.8
            Behavior on color { ColorAnimation { duration: root.animMs } }
        }

        Item { Layout.fillHeight: true }

        Text {
            visible: root.sub.length > 0
            text: root.sub
            color: Colors.inkDimmer
            font.family: Theme.font.family.inter
            font.pixelSize: Theme.font.size.xs
            font.letterSpacing: 0.3
            elide: Text.ElideRight
            Layout.fillWidth: true
        }
    }

    Rectangle {
        visible: root.on
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.leftMargin: 14
        anchors.rightMargin: 14
        anchors.bottomMargin: 10
        height: 1
        color: Colors.barAccent
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: root.available
        cursorShape: root.available ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: {
            if (root.available) root.activated();
        }
    }
}
