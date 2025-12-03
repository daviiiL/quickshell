import QtQuick
import qs.common

Rectangle {
    id: root
    property string key

    property real horizontalPadding: 6
    property real verticalPadding: 1
    property real borderWidth: 1
    property real extraBottomBorderWidth: 2
    property color borderColor: Colors.current.on_surface
    property real borderRadius: 5
    property color keyColor: Colors.current.surface_container_low

    implicitWidth: keyFace.implicitWidth + borderWidth * 2
    implicitHeight: keyFace.implicitHeight + borderWidth * 2 + extraBottomBorderWidth
    radius: borderRadius
    color: borderColor

    Rectangle {
        id: keyFace
        anchors {
            fill: parent
            topMargin: borderWidth
            leftMargin: borderWidth
            rightMargin: borderWidth
            bottomMargin: extraBottomBorderWidth + borderWidth
        }
        implicitWidth: keyText.implicitWidth + horizontalPadding * 2
        implicitHeight: keyText.implicitHeight + verticalPadding * 2
        color: keyColor
        radius: borderRadius - borderWidth

        StyledText {
            id: keyText
            anchors.centerIn: parent
            font.family: Theme.font.style.free_mono
            font.pixelSize: Theme.font.size.small
            text: key
        }
    }
}
