pragma ComponentBehavior: Bound

import QtQuick
import qs.common

Rectangle {
    id: root
    color: Colors.surfaceContainerLowest
    transformOrigin: Item.Center

    Connections {
        target: GlobalStates
        function onScreenDismissingChanged(): void {
            if (GlobalStates.screenDismissing)
                dismissAnim.restart();
        }
    }

    ParallelAnimation {
        id: dismissAnim

        NumberAnimation {
            target: root; property: "opacity"
            from: 1; to: 0; duration: 400
            easing.type: Easing.InCubic
        }
        NumberAnimation {
            target: root; property: "scale"
            from: 1; to: 0.97; duration: 400
            easing.type: Easing.InCubic
        }

        onFinished: {
            GlobalStates.screenLocked = false;
            GlobalStates.screenDismissing = false;
            root.opacity = 1;
            root.scale = 1;
        }
    }

    Canvas {
        id: grid
        anchors.fill: parent
        renderStrategy: Canvas.Cooperative

        readonly property color hairColor: Colors.hair

        onPaint: {
            const ctx = getContext("2d");
            ctx.reset();
            ctx.globalAlpha = 0.32;
            ctx.strokeStyle = grid.hairColor;
            ctx.lineWidth = 1;
            ctx.beginPath();
            const step = 56;
            for (let x = 0.5; x < width; x += step) {
                ctx.moveTo(x, 0);
                ctx.lineTo(x, height);
            }
            for (let y = 0.5; y < height; y += step) {
                ctx.moveTo(0, y);
                ctx.lineTo(width, y);
            }
            ctx.stroke();

            ctx.globalCompositeOperation = "destination-in";
            ctx.globalAlpha = 1;
            const cx = width * 0.5;
            const cy = height * 0.4;
            const rMax = Math.max(width, height) * 0.8;
            const g = ctx.createRadialGradient(cx, cy, rMax * 0.08, cx, cy, rMax);
            g.addColorStop(0, "rgba(0,0,0,1)");
            g.addColorStop(1, "rgba(0,0,0,0)");
            ctx.fillStyle = g;
            ctx.fillRect(0, 0, width, height);
        }

        onWidthChanged:  requestPaint()
        onHeightChanged: requestPaint()
        onHairColorChanged: requestPaint()
    }

    Rectangle {
        id: hairTop
        anchors { top: parent.top; left: parent.left; right: parent.right }
        height: 1
        color: Colors.hair

        readonly property color accentFaded: Qt.rgba(Colors.barAccent.r, Colors.barAccent.g, Colors.barAccent.b, 0.55)

        Rectangle {
            anchors.left: parent.left
            anchors.top: parent.top
            width: parent.width * 0.45
            height: 1
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: hairTop.accentFaded }
                GradientStop { position: 1.0; color: "transparent" }
            }
        }
    }

    Rectangle {
        anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
        height: 1
        color: Colors.hair
    }

    LockClock {
        id: clock
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.leftMargin: parent.width * 0.055
        anchors.topMargin: parent.height * 0.14
    }

    LockDateLine {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.leftMargin: parent.width * 0.055
        anchors.topMargin: parent.height * 0.54
    }

    LockStatusChips {
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.rightMargin: parent.width * 0.04
        anchors.topMargin: parent.height * 0.07
    }

    LockPasswordField {
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.leftMargin: parent.width * 0.055
        anchors.bottomMargin: parent.height * 0.09
        width: Math.min(640, parent.width * 0.48)
    }

    LockUserBadge {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.rightMargin: parent.width * 0.04
        anchors.bottomMargin: parent.height * 0.09
    }
}
