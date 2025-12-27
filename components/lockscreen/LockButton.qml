import QtQuick
import qs.common
import qs.widgets

Rectangle {
    id: root

    property string text: ""
    property string icon: ""
    property bool isActive: false
    property bool enabled: true

    signal clicked

    implicitHeight: buttonText.implicitHeight + 12
    implicitWidth: 100
    color: root.isActive ? Colors.current.primary_container : Colors.current.secondary_container
    radius: Theme.ui.radius.lg
    opacity: root.enabled ? 1.0 : 0.5

    MouseArea {
        anchors.fill: parent
        cursorShape: root.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
        enabled: root.enabled
        onPressed: root.clicked()
    }

    Row {
        anchors.centerIn: parent
        spacing: 4

        MaterialSymbol {
            id: buttonIcon
            visible: root.icon !== ""
            icon: root.icon
            fill: 1
            iconSize: Theme.font.size.md
            fontColor: root.isActive ? Colors.current.on_primary_container : Colors.current.on_secondary_container
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            id: buttonText
            text: root.text
            visible: root.text !== ""
            horizontalAlignment: Text.AlignHCenter
            color: root.isActive ? Colors.current.on_primary_container : Colors.current.on_secondary_container
            font.pointSize: Theme.font.size.md
            font.family: Theme.font.family.inter_semi_bold
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    Behavior on color {
        ColorAnimation {
            duration: Theme.anim.durations.sm
        }
    }
}
