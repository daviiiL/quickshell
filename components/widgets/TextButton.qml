import QtQuick
import QtQuick.Layouts
import qs.common

Rectangle {
    id: root

    property string text: ""
    property color textColor: Colors.current.on_primary_container
    property color textColorPressed: Colors.current.primary_container
    property int fontSize: 14
    property int padding: 8

    signal clicked

    implicitWidth: buttonText.implicitWidth + (root.padding * 2)
    implicitHeight: buttonText.implicitHeight + (root.padding * 2)
    radius: Theme.ui.rounding.xs

    color: mouseArea.containsMouse ? Colors.current.on_primary_container : Colors.current.primary_container
    Behavior on color {
        ColorAnimation {
            duration: 150
        }
    }

    Text {
        id: buttonText
        anchors.centerIn: parent
        text: root.text
        font.pixelSize: root.fontSize
        color: mouseArea.containsMouse ? root.textColorPressed : root.textColor

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
