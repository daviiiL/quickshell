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

    property var onClicked: null

    function makeTranslucent(color) {
        return Qt.rgba(color.r, color.g, color.b, 0.4);
    }

    width: 50
    height: 50

    radius: Theme.ui.radius.md
    color: checked ? root.makeTranslucent(Colors.primary_container) : root.makeTranslucent(Colors.secondary_container)
    scale: mouseArea.pressed ? 0.95 : 1.0

    border {
        color: checked ? (Preferences.darkMode ? Colors.primary_container : root.makeTranslucent(Colors.secondary)) : Colors.secondary_container
        width: 1
    }

    Behavior on color {
        ColorAnimation {
            duration: 200
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
            duration: 200
            easing.type: Easing.OutCubic
        }
    }

    Behavior on border.width {
        NumberAnimation {
            duration: 200
            easing.type: Easing.OutCubic
        }
    }

    Canvas {
        id: indicatorLine
        visible: root.checked
        anchors.fill: parent
        antialiasing: true
        opacity: root.checked ? 1.0 : 0.0

        Behavior on opacity {
            NumberAnimation {
                duration: 250
                easing.type: Easing.OutCubic
            }
        }

        onPaint: {
            const ctx = getContext("2d");
            ctx.reset();

            ctx.strokeStyle = Colors.secondary;
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

        Component.onCompleted: {
            requestPaint();
        }

        onVisibleChanged: () => requestPaint()

        Connections {
            target: Colors

            function onPrimaryChanged() {
                indicatorLine.requestPaint();
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        MaterialSymbol {
            Layout.alignment: Qt.AlignHCenter
            icon: root.buttonIcon
            iconSize: Theme.font.size.md
            fontColor: root.checked ? Colors.on_primary_container : Colors.on_secondary_container

            Behavior on fontColor {
                ColorAnimation {
                    duration: 200
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
            color: root.checked ? Colors.on_primary_container : Colors.on_secondary_container
            text: root.buttonText

            Behavior on color {
                ColorAnimation {
                    duration: 200
                    easing.type: Easing.OutCubic
                }
            }
        }
    }
    MouseArea {
        id: mouseArea
        hoverEnabled: false
        anchors.fill: parent

        onClicked: () => {
            if (root.onClicked)
                root.onClicked();
        }
    }
}
