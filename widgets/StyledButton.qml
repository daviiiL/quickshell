import QtQuick
import QtQuick.Layouts
import qs.common
import qs.widgets

Rectangle {
    id: root
    property string icon: ""
    property string text: ""
    required property var onClicked

    signal clicked

    function makeTranslucent(color) {
        return Qt.rgba(color.r, color.g, color.b, 0.4);
    }

    width: 70
    height: 30

    radius: Theme.ui.radius.md
    color: (mouseArea.containsMouse || mouseArea.pressed) ? root.makeTranslucent(Colors.primary_container) : root.makeTranslucent(Colors.secondary_container)

    Behavior on color {
        ColorAnimation {
            duration: 150
            easing.type: Easing.InOutQuad
        }
    }

    border {
        color: (mouseArea.containsMouse || mouseArea.pressed) ? Colors.primary_container : Colors.secondary_container

        Behavior on color {
            ColorAnimation {
                duration: 150
                easing.type: Easing.InOutQuad
            }
        }
    }

    Canvas {
        id: indicatorLine
        visible: mouseArea.containsMouse || mouseArea.pressed
        anchors.fill: parent
        antialiasing: true
        opacity: 0

        Behavior on opacity {
            NumberAnimation {
                duration: 200
                easing.type: Easing.InOutQuad
            }
        }

        onVisibleChanged: {
            opacity = visible ? 1 : 0;
        }

        onPaint: {
            const ctx = getContext("2d");
            ctx.reset();

            ctx.strokeStyle = Colors.primary;
            ctx.lineWidth = 3;
            ctx.lineCap = "round";

            const lineY = 2;
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
            icon: root.icon
            iconSize: Theme.font.size.md
            fontColor: (mouseArea.containsMouse || mouseArea.pressed) ? Colors.on_primary_container : Colors.on_secondary_container
            visible: root.icon !== ""

            Behavior on fontColor {
                ColorAnimation {
                    duration: 150
                    easing.type: Easing.InOutQuad
                }
            }
        }

        Text {
            Layout.alignment: Qt.AlignHCenter
            font {
                family: Theme.font.family.inter_thin
                pixelSize: Theme.font.size.xs
            }
            color: (mouseArea.containsMouse || mouseArea.pressed) ? Colors.on_primary_container : Colors.on_secondary_container
            text: root.text
            visible: root.text !== ""

            Behavior on color {
                ColorAnimation {
                    duration: 150
                    easing.type: Easing.InOutQuad
                }
            }
        }
    }

    MouseArea {
        id: mouseArea
        hoverEnabled: true
        anchors.fill: parent

        onClicked: {
            root.clicked();
        }
    }
}
