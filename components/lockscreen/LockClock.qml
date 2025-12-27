import QtQuick
import qs.common
import qs.services

Item {
    id: root

    property real shiftMarginTop: 0
    property real shiftMarginLeft: 0

    anchors {
        top: parent.top
        bottom: parent.bottom
        left: parent.left
        right: parent.right
        topMargin: shiftMarginTop
        leftMargin: shiftMarginLeft
    }

    function shiftClock() {
        var topShift = (Math.random() * 2 - 1) * 100;
        var leftShift = (Math.random() * 2 - 1) * 100;
        root.shiftMarginTop = topShift;
        root.shiftMarginLeft = leftShift;
    }

    Rectangle {
        anchors.centerIn: parent

        implicitHeight: timeText.height
        implicitWidth: timeText.width

        color: "transparent"

        Text {
            id: timeText
            anchors.centerIn: parent
            text: DateTime.time
            color: Colors.current.primary
            antialiasing: true

            renderType: Text.QtRendering
            renderTypeQuality: Text.HighRenderTypeQuality

            smooth: true
            font {
                family: Theme.font.family.inter_semi_bold
                pixelSize: 150
            }
        }
    }

    Timer {
        id: pixelShiftTimer
        interval: 300000
        running: root.visible
        repeat: true
        onTriggered: root.shiftClock()
    }
}
