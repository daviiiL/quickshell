import QtQuick
import qs.common

Rectangle {
    id: root

    property string text: ""
    property color textColor: Colors.current.secondary
    property color textColorPressed: Colors.current.secondary_container
    property int fontSize: 14
    property string fontStyle: Theme.font.style.departureMono
    property int padding: 8

    border {
        color: Colors.current.secondary
        pixelAligned: true
    }

    signal clicked

    implicitWidth: buttonText.implicitWidth + (root.padding * 2)
    implicitHeight: buttonText.implicitHeight + (root.padding * 2)
    radius: Theme.ui.rounding.xs

    color: mouseArea.containsMouse ? Colors.current.on_secondary_container : "transparent"
    scale: mouseArea.pressed ? 0.96 : (mouseArea.containsMouse ? 1.02 : 1.0)

    Behavior on color {
        ColorAnimation {
            duration: 200
            easing.type: Easing.OutCubic
        }
    }

    Behavior on scale {
        NumberAnimation {
            duration: 150
            easing.type: Easing.OutCubic
        }
    }

    Text {
        anchors {
            left: parent.left
            verticalCenter: parent.verticalCenter

            leftMargin: 20
        }

        font {
            family: Theme.font.style.departureMono
            pixelSize: Theme.font.size.xl
        }

        text: ">"
    }

    Text {
        id: buttonText
        anchors.centerIn: parent
        text: root.text
        font.pixelSize: root.fontSize
        color: mouseArea.containsMouse ? root.textColorPressed : root.textColor

        font.family: root.fontStyle

        opacity: mouseArea.pressed ? 0.7 : 1.0

        Behavior on color {
            ColorAnimation {
                duration: 200
                easing.type: Easing.OutCubic
            }
        }

        Behavior on opacity {
            NumberAnimation {
                duration: 100
                easing.type: Easing.OutCubic
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
