import QtQuick

import qs.common
import qs.services

Rectangle {
    id: root

    required property bool checked
    required property var onClicked

    implicitWidth: 48
    implicitHeight: 28
    radius: 14
    color: checked ? Colors.primary : Colors.surface

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
        color: root.checked ? Colors.on_primary : (Preferences.darkMode ? Colors.on_secondary : Colors.outline_variant)

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
        onClicked: root.onClicked()
    }
}
