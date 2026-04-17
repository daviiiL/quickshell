import QtQuick

import qs.common

Rectangle {
    id: root

    required property bool checked
    signal clicked

    property color activeColor: Colors.primary
    property color inactiveColor: Colors.surface
    property color handleActiveColor: Colors.fgPrimary
    property color handleInactiveColor: Colors.fgSecondary

    implicitWidth: 48
    implicitHeight: 28
    radius: 14
    color: checked ? root.activeColor : root.inactiveColor

    Behavior on color {
        ColorAnimation {
            duration: Theme.anim.durations.sm
            easing.type: Easing.Bezier
            easing.bezierCurve: Theme.anim.curves.emphasized
        }
    }

    Rectangle {
        width: 24
        height: 24
        radius: 12
        x: root.checked ? parent.width - width - 2 : 2
        y: 2
        color: root.checked ? root.handleActiveColor : root.handleInactiveColor

        Behavior on x {
            NumberAnimation {
                duration: Theme.anim.durations.sm
                easing.type: Easing.Bezier
                easing.bezierCurve: Theme.anim.curves.emphasized
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: root.clicked()
    }
}
