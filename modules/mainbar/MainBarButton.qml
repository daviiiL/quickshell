pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.common

Rectangle {
    id: root

    property bool hovered: mouseArea.containsMouse
    property bool active: false
    property int contentPadX: Theme.ui.mainBarButtonPadX
    property int contentGap: Theme.ui.mainBarButtonGap
    default property alias content: row.data

    signal activated()

    implicitHeight: Theme.ui.mainBarButtonHeight
    implicitWidth: row.implicitWidth + 2 * contentPadX
    radius: Theme.ui.mainBarButtonRadius

    color: {
        if (root.active)   return "transparent";
        if (root.hovered)  return Colors.surfaceContainerLow;
        return "transparent";
    }
    border.width: Theme.ui.mainBarHairWidth
    border.color: {
        if (root.active)  return Colors.hairHot;
        if (root.hovered) return Colors.hair;
        return "transparent";
    }

    Behavior on color        { ColorAnimation { duration: 150; easing.type: Easing.InOutQuad } }
    Behavior on border.color { ColorAnimation { duration: 150; easing.type: Easing.InOutQuad } }

    RowLayout {
        id: row
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: root.contentPadX
        anchors.rightMargin: root.contentPadX
        spacing: root.contentGap
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.activated()
    }
}
