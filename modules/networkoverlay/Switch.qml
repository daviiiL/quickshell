pragma ComponentBehavior: Bound

import QtQuick
import qs.common

Rectangle {
    id: root

    property bool checked: false
    signal toggled

    implicitWidth: 30
    implicitHeight: 16
    radius: height / 2
    color: root.checked ? Qt.alpha(Colors.barAccent, 0.12) : "transparent"
    border.color: root.checked ? Colors.hairHot : Colors.hair
    border.width: Theme.ui.mainBarHairWidth
    Behavior on color        { ColorAnimation { duration: 180 } }
    Behavior on border.color { ColorAnimation { duration: 180 } }

    Rectangle {
        id: knob
        width: 12
        height: 12
        radius: height / 2
        y: 1
        x: root.checked ? parent.width - width - 2 : 2
        color: root.checked ? Colors.barAccent : Colors.inkDimmer
        Behavior on x     { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
        Behavior on color { ColorAnimation  { duration: 180 } }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.toggled()
    }
}
