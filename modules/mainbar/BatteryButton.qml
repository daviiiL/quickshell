pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.common
import qs.services
import qs.widgets

MainBarButton {
    id: root

    visible: (typeof Power !== "undefined" && Power.isLaptopBattery) || false

    readonly property real level:
        (typeof Power !== "undefined" && Power.percentage !== undefined)
            ? Power.percentage : 0
    readonly property bool charging:
        (typeof Power !== "undefined" && Power.isCharging) || false

    onActivated: {}

    Rectangle {
        id: capsule
        Layout.preferredWidth:  Theme.ui.mainBarBatteryWidth
        Layout.preferredHeight: Theme.ui.mainBarBatteryHeight
        radius: 3
        color: "transparent"
        border.width: Theme.ui.mainBarHairWidth
        border.color: root.hovered ? Colors.fgSurface : Colors.inkDim
        Behavior on border.color { ColorAnimation { duration: 150 } }

        Item {
            id: inner
            anchors.fill: parent
            anchors.margins: 1
            clip: true

            Canvas {
                id: fillCanvas
                anchors.fill: parent

                property real paintLevel: root.level
                property color paintColor: {
                    if (root.charging)     return Colors.live;
                    if (root.level < 0.05) return "#ff5252";
                    if (root.level < 0.10) return "#ff9a3d";
                    return Colors.barAccent;
                }

                Behavior on paintLevel { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }
                Behavior on paintColor { ColorAnimation  { duration: 200 } }

                onPaintLevelChanged: requestPaint()
                onPaintColorChanged: requestPaint()
                onWidthChanged:      requestPaint()
                onHeightChanged:     requestPaint()

                onPaint: {
                    const ctx = getContext("2d");
                    ctx.clearRect(0, 0, width, height);
                    const w = Math.max(0, width * paintLevel);
                    if (w <= 0) return;
                    const slant = Math.min(Theme.ui.mainBarBatterySlant, w);
                    ctx.fillStyle = paintColor;
                    ctx.beginPath();
                    ctx.moveTo(0, 0);
                    ctx.lineTo(Math.max(0, w - slant), 0);
                    ctx.lineTo(w, height);
                    ctx.lineTo(0, height);
                    ctx.closePath();
                    ctx.fill();
                }
            }
        }
    }

    RowLayout {
        Layout.alignment: Qt.AlignVCenter
        Layout.preferredWidth: 52
        spacing: 2

        Item { Layout.fillWidth: true }

        Image {
            Layout.alignment: Qt.AlignVCenter
            Layout.preferredWidth: 10
            Layout.preferredHeight: 10
            source: "../../assets/icons/charging.svg"
            sourceSize.width: 20
            sourceSize.height: 20
            smooth: true
            opacity: root.charging ? (root.hovered ? 1.0 : 0.56) : 0
            Behavior on opacity { NumberAnimation { duration: 150; easing.type: Easing.InOutQuad } }
        }

        Text {
            text: Math.round(root.level * 100) + "%"
            color: root.hovered ? Colors.fgSurface : Colors.inkDim
            font.family: Theme.font.family.inter_medium
            font.weight: Font.Medium
            font.pixelSize: 15
            horizontalAlignment: Text.AlignRight
            Behavior on color { ColorAnimation { duration: 150 } }
        }
    }
}
