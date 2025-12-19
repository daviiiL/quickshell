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
    Behavior on color {
        ColorAnimation {
            duration: 150
        }
    }

    Text {
        id: buttonText
        anchors.centerIn: parent
        text: mouseArea.containsMouse ? "> " + root.text : root.text
        font.pixelSize: root.fontSize
        color: mouseArea.containsMouse ? root.textColorPressed : root.textColor

        font.family: root.fontStyle

        Behavior on color {
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
