import QtQuick
import "../components/"
import "../utils"

ExpandingContainer {
    id: root

    implicitHeight: 52
    collapsedWidth: 38
    expandedWidth: 140
    color: "transparent"

    signal mouseCaptured(bool isCaptured)

    Rectangle {
        anchors.fill: parent
        radius: parent.radius || Theme.rounding.regular
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop {
                position: 0.0
                color: Colors.values.background
            }
            GradientStop {
                position: 1.0
                color: root.expanded ? Qt.lighter(Colors.values.background, 3.0) : Colors.values.background

                Behavior on color {
                    ColorAnimation {
                        duration: root.animationDuration
                        easing.type: Easing.InOutQuad
                    }
                }
            }
        }
    }

    CircularProgress {
        id: progressIndicator
        value: Power.percentage
        anchors.left: parent.left
        anchors.leftMargin: 8
        anchors.verticalCenter: parent.verticalCenter

        transform: Rotation {
            id: rotation
            origin.x: progressIndicator.width / 2
            origin.y: progressIndicator.height / 2
            angle: 0
        }
    }

    Connections {
        target: root
        function onEntered() {
            expandRotationAnimation.start();
        }
        function onExited() {
            retractRotationAnimation.start();
        }
    }

    NumberAnimation {
        id: expandRotationAnimation
        target: rotation
        property: "angle"
        from: 0
        to: -360
        duration: root.animationDuration * 1.5
        easing.type: Easing.OutCubic
    }

    NumberAnimation {
        id: retractRotationAnimation
        target: rotation
        property: "angle"
        from: -360
        to: 0
        duration: root.animationDuration * 1.5
        easing.type: Easing.OutCubic
    }

    Text {
        id: timeText
        text: `    ${root.formatTime(Power.timeToGoal)}`
        color: Colors.values.on_secondary_container
        font.pointSize: Theme.font.size.regular
        font.family: Theme.font.style.inter
        anchors.left: progressIndicator.right
        anchors.leftMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        opacity: root.expanded ? 1 : 0
        visible: opacity > 0

        Behavior on opacity {
            NumberAnimation {
                duration: root.animationDuration
                easing.type: Easing.OutCubic
            }
        }
    }

    function formatTime(seconds) {
        if (seconds <= 0)
            return "--:--";

        var hours = Math.floor(seconds / 3600);
        var minutes = Math.floor((seconds % 3600) / 60);

        if (hours > 0) {
            return hours + "h " + minutes + "m";
        } else {
            return minutes + "m";
        }
    }
}
