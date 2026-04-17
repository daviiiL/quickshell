pragma ComponentBehavior: Bound

import QtQuick
import qs.common

Rectangle {
    id: root

    property string iconSource: ""
    property string label: ""
    property bool running: true
    property bool focused: false
    property int unreadCount: 0

    signal activated()

    implicitWidth: Theme.ui.mainBarDockItemSize
    implicitHeight: Theme.ui.mainBarDockItemSize
    radius: Theme.ui.mainBarDockItemRadius
    border.width: Theme.ui.mainBarHairWidth

    readonly property bool hovered: hoverArea.containsMouse

    color: {
        if (root.focused) return Qt.alpha(Colors.barAccent, 0.05);
        if (root.hovered) return Colors.surfaceContainerLow;
        return "transparent";
    }
    border.color: {
        if (root.focused) return Colors.hairHot;
        if (root.hovered) return Colors.hair;
        return "transparent";
    }

    Behavior on color        { ColorAnimation { duration: 150 } }
    Behavior on border.color { ColorAnimation { duration: 150 } }

    Image {
        anchors.centerIn: parent
        width: Theme.ui.mainBarDockIconSize
        height: Theme.ui.mainBarDockIconSize
        source: root.iconSource
        sourceSize.width: width * 2
        sourceSize.height: height * 2
        smooth: true
        opacity: (root.focused || root.hovered) ? 1.0 : 0.56
        Behavior on opacity { NumberAnimation { duration: 150; easing.type: Easing.InOutQuad } }
    }

    Rectangle {
        visible: root.running
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: 3
        width: root.focused ? 16 : 12
        height: 2
        radius: 1
        color: root.focused ? Colors.barAccent : Colors.inkFaint
        Behavior on width { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
    }

    Rectangle {
        visible: root.unreadCount > 0
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: 2
        anchors.rightMargin: 2
        height: 16
        width: Math.max(16, badgeLabel.implicitWidth + 6)
        radius: 8
        color: Colors.barAccent
        border.width: 2
        border.color: Colors.barBg

        Text {
            id: badgeLabel
            anchors.centerIn: parent
            text: root.unreadCount
            font.family: Theme.font.family.inter_bold
            font.weight: Font.Bold
            font.pixelSize: 11
            color: Colors.barBg
        }
    }

    MouseArea {
        id: hoverArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.activated()
    }
}
