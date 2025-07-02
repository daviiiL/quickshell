import QtQuick
import "../utils"
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell

Item {
    id: root

    implicitWidth: parent.width
    implicitHeight: 32

    signal captured(bool isCaptured)

    Rectangle {
        anchors.fill: parent
        implicitWidth: parent.width
        color: "transparent"

        CircularProgress {
            value: Power.percentage
            anchors.horizontalCenter: parent.horizontalCenter
        }

        ToolTip.delay: 1000
        ToolTip.text: `Battery: ${Power.percentage}%`
        ToolTip.visible: mouseArea.containsMouse

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            onEntered: {
                captured(true);
            }
            onExited: {
                captured(false);
            }
        }
    }
}
