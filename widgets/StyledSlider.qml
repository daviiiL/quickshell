import QtQuick
import QtQuick.Controls
import qs.common

Slider {
    id: root

    property color highlightColor: Colors.primary
    property color trackColor: Colors.surface_container_high
    property color handleColor: Colors.primary

    from: 0
    to: 1
    stepSize: 0.001

    background: Rectangle {
        x: root.leftPadding
        y: root.topPadding + root.availableHeight / 2 - height / 2
        implicitWidth: 200
        implicitHeight: 4
        width: root.availableWidth
        height: implicitHeight
        radius: height / 2
        color: root.trackColor

        Rectangle {
            width: root.visualPosition * parent.width
            height: parent.height
            color: root.highlightColor
            radius: height / 2
        }
    }

    handle: Rectangle {
        x: root.leftPadding + root.visualPosition * (root.availableWidth - width)
        y: root.topPadding + root.availableHeight / 2 - height / 2
        implicitWidth: 16
        implicitHeight: 16
        radius: width / 2
        color: root.handleColor
        visible: root.hovered || root.pressed

        Behavior on color {
            ColorAnimation {
                duration: Theme.anim.durations.xs
                easing.type: Easing.Bezier
                easing.bezierCurve: Theme.anim.curves.standard
            }
        }
    }
}
