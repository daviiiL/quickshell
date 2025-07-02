import QtQuick
import "../utils"

Item {
    id: root

    implicitWidth: parent.width
    implicitHeight: 32

    signal mouseCaptured(bool isCaptured)

    Rectangle {
        anchors.fill: parent
        implicitWidth: parent.width
        color: "transparent"

        CircularProgress {
            value: Power.percentage
            anchors.horizontalCenter: parent.horizontalCenter
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            //     onEntered: {
            //         mouseCaptured(true);
            //     }
            //     onExited: {
            //         mouseCaptured(false);
            //     }
        }
    }
}
