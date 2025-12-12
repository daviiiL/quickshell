import QtQuick
import qs.common
import qs.components.widgets

Rectangle {
    id: root

    property string icon: ""
    property color iconColor: Colors.current.primary
    property color iconColorPressed: Colors.current.primary_container
    property int iconSize: 24

    signal clicked()

    width: iconSize + 16
    height: iconSize + 16
    radius: 4
    color: mouseArea.pressed ? Qt.rgba(1, 1, 1, 0.2) : mouseArea.containsMouse ? Qt.rgba(1, 1, 1, 0.1) : "transparent"

    Behavior on color {
        ColorAnimation {
            duration: 150
        }
    }

    MaterialSymbol {
        anchors.centerIn: parent
        icon: root.icon
        iconSize: root.iconSize
        fontColor: mouseArea.pressed ? root.iconColorPressed : root.iconColor

        Behavior on fontColor {
            ColorAnimation {
                duration: 150
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onClicked: root.clicked()
    }
}
