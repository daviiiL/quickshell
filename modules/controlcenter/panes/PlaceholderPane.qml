pragma ComponentBehavior: Bound

import QtQuick
import qs.common

Item {
    id: root

    required property string paneName

    Component.onCompleted: console.log(`[ControlCenter.placeholder:${root.paneName}] loaded`)
    Component.onDestruction: console.log(`[ControlCenter.placeholder:${root.paneName}] unloaded`)

    Column {
        anchors.centerIn: parent
        spacing: 10

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.paneName.toUpperCase()
            color: Colors.inkDimmer
            font.family: Theme.font.family.inter_medium
            font.pixelSize: Theme.font.size.sm
            font.letterSpacing: 2.8
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Coming in a later phase."
            color: Qt.alpha(Colors.fgSurface, 0.45)
            font.family: Theme.font.family.inter
            font.pixelSize: Theme.font.size.sm
            font.letterSpacing: 0.3
        }
    }
}
