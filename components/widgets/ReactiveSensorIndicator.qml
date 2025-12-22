import QtQuick
import qs.common
import qs.components.widgets

Item {
    id: root
    implicitWidth: baseWidth
    implicitHeight: baseHeight

    property int baseWidth: 50
    property int baseHeight: Theme.statusbar.height / 4
    readonly property int originalHeight: baseHeight

    property int value: 0
    property int progress: (value / 100) * width
    property string criticalColor: "red"

    property bool hoverEnabled: true
    property bool isBattery: false
    property bool isCharging: false
    property bool isTempSensor: false

    readonly property color successColor: "#b4ffb4"
    readonly property color warningColor: "#ffd4ab"
    readonly property bool textOnRight: root.value < 80

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

    function percentageColor() {
        if (value < 50) {
            return Colors.current.on_secondary_container;
        } else {
            if (criticalColor === "red") {
                return Colors.current.on_error;
            } else if (criticalColor === "green") {
                return Colors.current.secondary_container;
            } else {
                return Colors.current.secondary_container;
            }
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
                    easing.type: Easing.OutCubic
                }
            }

            Behavior on color {
                ColorAnimation {
                    duration: Theme.anim.durations.normal
                    easing.type: Easing.OutCubic
                }
            }
        }

        Rectangle {
            id: chargingOverlay
            visible: root.isCharging && root.isBattery
            color: root.successColor
            opacity: 0.3
            anchors {
                left: parent.left
                top: parent.top
                bottom: parent.bottom
            }
            width: root.progress

            SequentialAnimation on width {
                running: root.isCharging && root.isBattery
                loops: Animation.Infinite

                NumberAnimation {
                    from: root.progress
                    to: background.width
                    duration: 1500
                    easing.type: Easing.InOutSine
                }

                NumberAnimation {
                    from: background.width
                    to: root.progress
                    duration: 1500
                    easing.type: Easing.InOutSine
                }
            }

            SequentialAnimation on opacity {
                running: root.isCharging && root.isBattery
                loops: Animation.Infinite

                NumberAnimation {
                    from: 0.3
                    to: 0.6
                    duration: 1500
                    easing.type: Easing.InOutSine
                }

                NumberAnimation {
                    from: 0.6
                    to: 0.3
                    duration: 1500
                    easing.type: Easing.InOutSine
                }
            }
        }
    }

    MaterialSymbol {
        id: chargingIcon
        z: 2
        visible: root.isCharging && root.isBattery
        icon: "electric_bolt"
        fill: 1
        iconSize: Theme.font.size.regular
        fontColor: Colors.current.primary
        anchors.centerIn: background

        SequentialAnimation on opacity {
            running: root.isCharging && root.isBattery
            loops: Animation.Infinite

            NumberAnimation {
                from: 0.8
                to: 1.0
                duration: 800
                easing.type: Easing.InOutSine
            }

            NumberAnimation {
                from: 1.0
                to: 0.8
                duration: 800
                easing.type: Easing.InOutSine
            }
        }

        SequentialAnimation on scale {
            running: root.isCharging && root.isBattery
            loops: Animation.Infinite

            NumberAnimation {
                from: 1.0
                to: 1.15
                duration: 800
                easing.type: Easing.InOutSine
            }

            NumberAnimation {
                from: 1.15
                to: 1.0
                duration: 800
                easing.type: Easing.InOutSine
            }
        }
    }

    StyledText {
        id: percentageText
        z: 3
        visible: mouseArea.containsMouse
        text: root.isTempSensor ? root.value + "°C" : root.value + "%"
        font.pixelSize: Theme.font.size.regular
        color: root.percentageColor()
        anchors.verticalCenter: background.verticalCenter

        states: [
            State {
                when: root.textOnRight
                AnchorChanges {
                    target: percentageText
                    anchors.right: background.right
                    anchors.left: undefined
                }
                PropertyChanges {
                    percentageText.anchors.rightMargin: 4
                }
            },
            State {
                when: !root.textOnRight
                AnchorChanges {
                    target: percentageText
                    anchors.left: background.left
                    anchors.right: undefined
                }
                PropertyChanges {
                    percentageText.anchors.leftMargin: 4
                }
            }
        ]

        transitions: Transition {
            AnchorAnimation {
                duration: Theme.anim.durations.normal
                easing.type: Easing.OutCubic
            }
        }

        Behavior on color {
            ColorAnimation {
                duration: Theme.anim.durations.normal
                easing.type: Easing.OutCubic
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: root.hoverEnabled

        onEntered: {
            root.height = root.originalHeight * 2;
            root.scale = 1.2;
        }

        onExited: {
            root.height = root.originalHeight;
            root.scale = 1.0;
        }
    }

    Behavior on height {
        NumberAnimation {
            duration: Theme.anim.durations.normal
            easing.type: Easing.OutBack
            easing.overshoot: 1.2
        }
    }

    Behavior on scale {
        NumberAnimation {
            duration: Theme.anim.durations.normal
            easing.type: Easing.OutBack
            easing.overshoot: 1.2
        }
    }
}
