import Quickshell
import QtQuick
import "../../common"

Item {
    id: root
    implicitWidth: 50
    implicitHeight: parent.height

    property int value: 50
    property int progress: (value / 100) * width

    Rectangle {
        id: background
        width: parent.width
        color: Colors.current.secondary_container
        anchors {
            top: parent.top
            bottom: parent.bottom
            topMargin: 2
            bottomMargin: 2
        }

        Rectangle {
            color: root.progress > 70 ? Colors.current.error : Colors.current.on_secondary_container
            anchors {
                left: parent.left
                top: parent.top
                bottom: parent.bottom
            }
            width: root.progress
        }
    }
}
