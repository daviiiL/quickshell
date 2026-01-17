import QtQuick
import qs.common
import qs.services

Item {
    id: root

    property real value: 0
    property color highlightColor: Colors.primary
    property color trackColor: Colors.surface_container_high

    implicitHeight: 4

    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: root.trackColor

        Rectangle {
            width: Math.max(0, Math.min(1, root.value)) * parent.width
            height: parent.height
            color: root.highlightColor
            radius: height / 2

            Behavior on width {
                NumberAnimation {
                    duration: Theme.anim.durations.xs
                    easing.type: Easing.Bezier
                    easing.bezierCurve: Theme.anim.curves.standard
                }
            }
        }
    }
}
