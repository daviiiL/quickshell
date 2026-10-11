pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.common
import qs.services

Rectangle {
    id: root

    readonly property real level: Math.max(0, Math.min(1, Power.percentage))
    readonly property color ringColor: root.level < 0.15 ? Colors.error : Colors.live

    readonly property string headline: {
        if (Power.percentage > 0.99 && !Power.isCharging) return "Fully charged";
        const t = Power.timeToGoal;
        if (!Number.isFinite(t) || t <= 0) return Power.isCharging ? "Charging" : "Estimating…";
        const h = Math.floor(t / 3600), m = Math.floor((t % 3600) / 60);
        const span = (h > 0 ? h + " h " : "") + m + " m";
        return span + (Power.isCharging ? " until full" : " remaining");
    }

    readonly property string detail: {
        const w = Math.abs(Power.changeRate);
        if (w === 0) return "Battery not in use";
        return (Power.isCharging ? "Charging · " : "Discharging · ") + w.toFixed(1) + " W";
    }

    Layout.fillWidth: true
    implicitHeight: 96
    radius: Theme.ui.radius.sm
    color: Colors.surfaceContainerLow
    border.color: Colors.hair
    border.width: Theme.ui.mainBarHairWidth

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 18
        anchors.rightMargin: 18
        spacing: 18

        Canvas {
            id: ring
            Layout.preferredWidth: 64
            Layout.preferredHeight: 64
            Layout.alignment: Qt.AlignVCenter

            readonly property real value: root.level
            readonly property color arc: root.ringColor
            readonly property color track: Colors.surfaceContainer

            onValueChanged: requestPaint()
            onArcChanged: requestPaint()
            onTrackChanged: requestPaint()

            onPaint: {
                const ctx = getContext("2d");
                ctx.reset();
                const cx = width / 2, cy = height / 2, r = width / 2 - 4;
                ctx.lineWidth = 6;
                ctx.lineCap = "round";
                ctx.strokeStyle = track;
                ctx.beginPath();
                ctx.arc(cx, cy, r, 0, Math.PI * 2);
                ctx.stroke();
                if (value > 0) {
                    ctx.strokeStyle = arc;
                    ctx.beginPath();
                    ctx.arc(cx, cy, r, -Math.PI / 2, -Math.PI / 2 + Math.PI * 2 * value);
                    ctx.stroke();
                }
            }

            Text {
                anchors.centerIn: parent
                text: Math.round(root.level * 100) + "%"
                color: Colors.fgSurface
                font.family: Theme.font.family.inter_medium
                font.pixelSize: Theme.font.size.body
                font.weight: Font.Medium
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 4

            Text {
                text: root.headline
                color: Colors.fgSurface
                font.family: Theme.font.family.inter_medium
                font.pixelSize: Theme.font.size.bodyLarge
                font.weight: Font.Medium
            }

            Text {
                text: root.detail
                color: Colors.inkDimmer
                font.family: Theme.font.family.inter
                font.pixelSize: Theme.font.size.caption
            }
        }
    }
}
