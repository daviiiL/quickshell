import QtQuick
import qs.common

Item {
    id: root
    implicitWidth: 50
    implicitHeight: parent.height

    property int value: 50
    property int progress: (value / 100) * width
    property string criticalColor: "red"

    readonly property color successColor: "#b4ffb4"
    readonly property color warningColor: "#ffd4ab"

    function progressColor() {
        if (criticalColor === "red") {
            if (value <= 60)
                return Colors.current.on_secondary_container;
            else if (value <= 80)
                return root.warningColor;
            else
                return Colors.current.error;
        } else if (criticalColor === "green") {
            if (value <= 20)
                return Colors.current.error;
            else if (value <= 80)
                return Colors.current.on_secondary_container;
            else
                return root.successColor;
        } else {
            return Colors.current.on_secondary_container;
        }
    }

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
            id: progressBar
            color: root.progressColor()
            anchors {
                left: parent.left
                top: parent.top
                bottom: parent.bottom
            }
            width: root.progress

            Behavior on width {
                NumberAnimation {
                    duration: Theme.anim.durations.normal
                    easing.type: Easing.Bezier
                }
            }

            Behavior on color {
                ColorAnimation {
                    duration: Theme.anim.durations.normal
                    easing.type: Easing.OutCubic
                }
            }
        }
    }
}
