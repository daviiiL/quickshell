pragma ComponentBehavior: Bound

import QtQuick
import qs.common

Item {
    id: root

    property color pulseColor: Colors.live

    implicitWidth: 6
    implicitHeight: 6

    Rectangle {
        id: dot
        anchors.centerIn: parent
        width: 6
        height: 6
        radius: width / 2
        color: root.pulseColor
    }

    Rectangle {
        id: halo
        anchors.centerIn: parent
        width: dot.width
        height: dot.height
        radius: width / 2
        color: "transparent"
        border.width: 2
        border.color: Qt.alpha(root.pulseColor, 0.55)
        opacity: 1

        SequentialAnimation on scale {
            loops: Animation.Infinite
            NumberAnimation { from: 1;  to: 2.3; duration: 1400; easing.type: Easing.OutCubic }
            NumberAnimation { from: 2.3; to: 1;  duration: 1000; easing.type: Easing.InQuad }
        }
        SequentialAnimation on opacity {
            loops: Animation.Infinite
            NumberAnimation { from: 1; to: 0; duration: 1400; easing.type: Easing.OutCubic }
            NumberAnimation { from: 0; to: 1; duration: 1000 }
        }
    }
}
