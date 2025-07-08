import QtQuick
import "../components/"
import "../utils/"

ExpandingContainer {
    id: root

    implicitHeight: 52
    collapsedWidth: Theme.bar.width
    expandedWidth: Theme.bar.width * 4
    color: Colors.current.background

    verticalExpansion: true
    expandedHeight: root.expandedWidth * 0.6
    collapsedHeight: root.implicitHeight

    signal mouseCaptured(bool isCaptured)

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
    }

    Rectangle {
        id: contentContainer
        anchors {
            left: progressIndicator.right
            top: parent.top
            bottom: parent.bottom
            right: parent.right
        }

        color: root.color
        radius: Theme.rounding.regular
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop {
                position: 0.0
                color: Colors.current.background
            }
            GradientStop {
                position: 1.0
                color: root.expanded ? Qt.lighter(Colors.current.background, 3.0) : Colors.current.background

                Behavior on color {
                    ColorAnimation {
                        duration: root.animationDuration
                        easing.type: Easing.InOutQuad
                    }
                }
            }
        }

        Text {
            id: timeText
            text: `   ${root.formatTime(Power.timeToGoal)}`
            color: Colors.current.on_secondary_container
            font.pointSize: Theme.font.size.regular
            font.family: Theme.font.style.inter
            anchors {
                top: contentContainer.top
                horizontalCenter: contentContainer.horizontalCenter
            }
            opacity: root.expanded ? 1 : 0
            visible: opacity > 0

            Behavior on opacity {
                NumberAnimation {
                    duration: root.animationDuration
                    easing.type: Easing.OutCubic
                }
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
