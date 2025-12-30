import QtQuick
import QtQuick.Layouts
import qs.common
import qs.widgets

Rectangle {
    id: root
    property string icon: ""
    property string text: ""
    property var iconSize: null
    property bool highlighted: false
    property bool clickable: true
    signal clicked

    function makeTranslucent(color) {
        return Qt.rgba(color.r, color.g, color.b, 0.4);
    }

    width: 70
    height: 30

    radius: (root.clickable && (mouseArea.containsMouse || mouseArea.pressed)) ? Theme.ui.radius.full : Theme.ui.radius.md

    transform: Scale {
        origin.x: root.width / 2
        origin.y: root.height / 2
        xScale: (root.clickable && (mouseArea.containsMouse || mouseArea.pressed)) ? 1.1 : 1.0
        yScale: (root.clickable && (mouseArea.containsMouse || mouseArea.pressed)) ? 1.1 : 1.0

        Behavior on xScale {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutBack
                easing.overshoot: 1.2
            }
        }

        Behavior on yScale {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutBack
                easing.overshoot: 1.2
            }
        }
    }

    Behavior on radius {
        NumberAnimation {
            duration: 200
            easing.type: Easing.InOutQuad
        }
    }
    color: {
        if (!root.clickable) {
            return root.makeTranslucent(Colors.surface_variant);
        }
        if (root.highlighted) {
            return (mouseArea.containsMouse || mouseArea.pressed) ? Qt.lighter(Colors.primary, 1.1) : Colors.primary;
        }
        return (mouseArea.containsMouse || mouseArea.pressed) ? root.makeTranslucent(Colors.primary_container) : root.makeTranslucent(Colors.secondary_container);
    }

    Behavior on color {
        ColorAnimation {
            duration: 150
            easing.type: Easing.InOutQuad
        }
    }

    border {
        color: {
            if (!root.clickable) {
                return Colors.surface_variant;
            }
            return (mouseArea.containsMouse || mouseArea.pressed) ? Colors.primary_container : Colors.secondary_container;
        }

        Behavior on color {
            ColorAnimation {
                duration: 150
                easing.type: Easing.InOutQuad
            }
        }
    }

    Canvas {
        id: indicatorLine
        visible: root.clickable && (mouseArea.containsMouse || mouseArea.pressed)
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
            iconSize: root.iconSize || Theme.font.size.md
            fontColor: {
                if (!root.clickable) {
                    return Colors.on_surface_variant;
                }
                if (root.highlighted) {
                    return Colors.on_primary;
                }
                return (mouseArea.containsMouse || mouseArea.pressed) ? Colors.on_primary_container : Colors.on_secondary_container;
            }
            visible: root.icon !== ""
            opacity: root.clickable ? 1.0 : 0.38

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
            color: {
                if (!root.clickable) {
                    return Colors.on_surface_variant;
                }
                return (mouseArea.containsMouse || mouseArea.pressed) ? Colors.on_primary_container : Colors.on_secondary_container;
            }
            text: root.text
            visible: root.text !== ""
            opacity: root.clickable ? 1.0 : 0.38

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
        hoverEnabled: root.clickable
        enabled: root.clickable
        anchors.fill: parent

        onClicked: {
            if (root.clickable)
                root.clicked();
        }
    }
}
