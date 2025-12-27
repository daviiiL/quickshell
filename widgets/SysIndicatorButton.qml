import QtQuick
import QtQuick.Layouts
import qs.common
import qs.widgets

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

    border {
        color: checked ? Colors.primary_container : Colors.secondary_container
    }

    Canvas {
        visible: root.checked
        anchors.fill: parent
        antialiasing: true

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

        Component.onCompleted: requestPaint()
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        MaterialSymbol {
            Layout.alignment: Qt.AlignHCenter
            icon: root.buttonIcon
            iconSize: Theme.font.size.md
            fontColor: root.checked ? Colors.on_primary_container : Colors.on_secondary_container
        }

        Text {
            Layout.alignment: Qt.AlignHCenter
            font {
                family: Theme.font.family.inter_thin
                pixelSize: Theme.font.size.xs
            }
            color: root.checked ? Colors.on_primary_container : Colors.on_secondary_container
            text: root.buttonText
        }
    }
    MouseArea {
        id: mouseArea
        hoverEnabled: true
        anchors.fill: parent

        onClicked: () => {
            if (root.onClicked)
                root.onClicked();
        }
    }
}
