import QtQuick
import QtQuick.Layouts
import qs.common
import qs.widgets
import qs.services

Rectangle {
    id: root
    required property bool checked
    property string buttonIcon: "wifi"
    property string buttonText: "WiFi"

    property color activeColor: Colors.primaryContainer
    property color inactiveColor: Colors.secondaryContainer
    property color activeTextColor: Colors.onPrimaryContainer
    property color inactiveTextColor: Colors.onSecondaryContainer
    property color accentColor: Colors.primary
    property color borderColor: Colors.outline
    property color indicatorColor: Colors.secondary

    signal clicked

    width: 50
    height: 50

    radius: Preferences.focusedMode ? 2 : Theme.ui.radius.md
    color: Preferences.focusedMode ? Qt.alpha(checked ? root.activeColor : Colors.surface, 0.25) : Qt.alpha(checked ? root.activeColor : root.inactiveColor, 0.4)
    scale: mouseArea.containsMouse ? 0.95 : 1.0

    border {
        color: Preferences.focusedMode ? Qt.alpha(checked ? root.accentColor : root.borderColor, 0.6) : (checked ? root.activeColor : Qt.alpha(Colors.outlineVariant, 0.4))
        width: 1
    }

    Canvas {
        id: indicatorLine
        visible: root.checked
        anchors.fill: parent
        antialiasing: true
        opacity: root.checked ? 1.0 : 0.0

        Behavior on opacity {
            NumberAnimation {
                duration: Theme.anim.durations.xs
                easing.type: Easing.OutCubic
            }
        }

        onPaint: {
            const ctx = getContext("2d");
            ctx.reset();

            ctx.strokeStyle = root.indicatorColor;
            ctx.lineWidth = 1.8;
            ctx.lineCap = "round";

            const lineY = 1;
            const lineWidth = 20;
            const startX = (width - lineWidth) / 2;
            const endX = startX + lineWidth;

            ctx.beginPath();
            ctx.moveTo(startX, lineY);
            ctx.lineTo(endX, lineY);
            ctx.stroke();
        }

        Component.onCompleted: requestPaint()
        onVisibleChanged: requestPaint()
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        MaterialSymbol {
            Layout.alignment: Qt.AlignHCenter
            icon: root.buttonIcon
            iconSize: Theme.font.size.md
            fontColor: root.checked ? root.activeTextColor : root.inactiveTextColor

            Behavior on fontColor {
                ColorAnimation {
                    duration: Theme.anim.durations.xs
                    easing.type: Easing.OutCubic
                }
            }
        }

        Text {
            Layout.alignment: Qt.AlignHCenter
            font {
                family: Theme.font.family.inter_thin
                pixelSize: Theme.font.size.xs
            }
            color: root.checked ? root.activeTextColor : root.inactiveTextColor
            text: root.buttonText

            Behavior on color {
                ColorAnimation {
                    duration: Theme.anim.durations.xs
                    easing.type: Easing.OutCubic
                }
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        onClicked: root.clicked()
    }

    Behavior on color {
        ColorAnimation {
            duration: Theme.anim.durations.xs
            easing.type: Easing.OutCubic
        }
    }

    Behavior on scale {
        NumberAnimation {
            duration: 150
            easing.type: Easing.OutCubic
        }
    }

    Behavior on border.color {
        ColorAnimation {
            duration: Theme.anim.durations.xs
            easing.type: Easing.OutCubic
        }
    }

    Behavior on border.width {
        NumberAnimation {
            duration: Theme.anim.durations.xs
            easing.type: Easing.OutCubic
        }
    }
}
