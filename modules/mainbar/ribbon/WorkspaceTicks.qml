pragma ComponentBehavior: Bound

import QtQuick
import qs.common

Column {
    id: root

    property int currentIdx: 0
    property var occupied: [false, false, false, false, false]

    signal activated(int idx)

    spacing: Theme.ui.mainBarTickGap

    Repeater {
        model: 5

        Item {
            id: slot
            required property int index
            readonly property int idx: index + 1
            readonly property bool current: idx === root.currentIdx
            readonly property bool occ: !!root.occupied[index]

            width: Theme.ui.mainBarTickWidth
            height: Theme.ui.mainBarTickHeight

            Rectangle {
                anchors.fill: parent
                radius: Theme.ui.mainBarTickRadius
                color: Colors.barAccent
                opacity: slot.current ? 1.0 : (hit.containsMouse ? 0.7 : (slot.occ ? 0.4 : 0.14))
                Behavior on opacity { NumberAnimation { duration: Theme.anim.durations.xs * 0.75 } }
            }

            MouseArea {
                id: hit
                anchors.centerIn: parent
                width: parent.width + Theme.ui.mainBarTickHitPad
                height: parent.height + Theme.ui.mainBarTickGap
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.activated(slot.idx)
            }
        }
    }
}
