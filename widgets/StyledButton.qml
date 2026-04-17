import QtQuick
import QtQuick.Layouts
import qs.common
import qs.widgets
import qs.services

Rectangle {
    id: root
    property string icon: ""
    property string text: ""
    property var iconSize: null
    property bool highlighted: false
    property bool clickable: true
    signal clicked

    property color accentColor: Colors.primary
    property color activeColor: Colors.primaryContainer
    property color inactiveColor: Colors.secondaryContainer
    property color disabledColor: Colors.surfaceVariant
    property color activeTextColor: Colors.onPrimaryContainer
    property color inactiveTextColor: Colors.onSecondaryContainer
    property color disabledTextColor: Colors.onSurfaceVariant
    property color highlightedTextColor: Colors.onPrimary
    property color borderColor: Colors.outline

    readonly property bool active: mouseArea.containsMouse || mouseArea.pressed
    readonly property bool scaled: clickable && active

    function makeTranslucent(color) {
        return Qt.rgba(color.r, color.g, color.b, 0.4);
    }

    width: 70
    height: 30

    radius: Preferences.focusedMode ? 2 : Theme.ui.radius.md

    transform: Scale {
        origin.x: root.width / 2
        origin.y: root.height / 2
        xScale: root.scaled ? 1.1 : 1.0
        yScale: root.scaled ? 1.1 : 1.0

        Behavior on xScale {
            NumberAnimation {
                duration: Theme.anim.durations.xs
                easing.type: Easing.OutBack
                easing.overshoot: 1.2
            }
        }

        Behavior on yScale {
            NumberAnimation {
                duration: Theme.anim.durations.xs
                easing.type: Easing.OutBack
                easing.overshoot: 1.2
            }
        }
    }

    Behavior on radius {
        NumberAnimation {
            duration: Theme.anim.durations.xs
            easing.type: Easing.InOutQuad
        }
    }
    color: {
        if (Preferences.focusedMode) {
            if (!root.clickable)
                return Qt.alpha(root.disabledColor, 0.25);
            if (root.highlighted)
                return root.active ? Qt.alpha(root.accentColor, 0.4) : Qt.alpha(root.accentColor, 0.3);
            return root.active ? Qt.alpha(root.activeColor, 0.35) : Qt.alpha(root.inactiveColor, 0.25);
        }

        if (!root.clickable)
            return root.makeTranslucent(root.disabledColor);
        if (root.highlighted)
            return root.active ? Qt.lighter(root.accentColor, 1.1) : root.accentColor;
        return root.active ? root.makeTranslucent(root.activeColor) : root.makeTranslucent(root.inactiveColor);
    }

    Behavior on color {
        ColorAnimation {
            duration: 150
            easing.type: Easing.InOutQuad
        }
    }

    border {
        width: Preferences.focusedMode ? 1 : 0
        color: {
            if (Preferences.focusedMode) {
                if (!root.clickable)
                    return Qt.alpha(root.borderColor, 0.4);
                return root.active ? Qt.alpha(root.accentColor, 0.6) : Qt.alpha(root.borderColor, 0.5);
            }

            if (!root.clickable)
                return root.disabledColor;
            return root.active ? root.activeColor : root.inactiveColor;
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
        visible: root.clickable && root.active
        anchors.fill: parent
        antialiasing: true
        opacity: 0

        Behavior on opacity {
            NumberAnimation {
                duration: Theme.anim.durations.xs
                easing.type: Easing.InOutQuad
            }
        }

        onVisibleChanged: opacity = visible ? 1 : 0

        onPaint: {
            const ctx = getContext("2d");
            ctx.reset();

            ctx.strokeStyle = root.accentColor;
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

        Component.onCompleted: requestPaint()
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        MaterialSymbol {
            Layout.alignment: Qt.AlignHCenter
            icon: root.icon
            iconSize: root.iconSize || Theme.font.size.md
            fontColor: {
                if (!root.clickable)
                    return root.disabledTextColor;
                if (root.highlighted)
                    return root.highlightedTextColor;
                return root.active ? root.activeTextColor : root.inactiveTextColor;
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
                if (!root.clickable)
                    return root.disabledTextColor;
                return root.active ? root.activeTextColor : root.inactiveTextColor;
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
