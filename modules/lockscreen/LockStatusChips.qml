pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.common
import qs.services

RowLayout {
    id: root
    spacing: 8

    property string layout: "US"

    component Chip: Rectangle {
        id: chip
        property color dotColor: "transparent"
        property bool hasDot: false
        property string label: ""
        property color textColor: Colors.inkDim

        height: 28
        radius: 3
        border.width: 1
        border.color: Colors.hair
        color: "transparent"
        implicitWidth: chipRow.implicitWidth + 20

        RowLayout {
            id: chipRow
            anchors.centerIn: parent
            spacing: 6

            Rectangle {
                visible: chip.hasDot
                width: 7
                height: 7
                radius: 3.5
                color: chip.dotColor
            }

            Text {
                text: chip.label
                font.pixelSize: 13
                font.letterSpacing: 2.0
                font.family: Theme.font.family.inter_regular
                color: chip.textColor
            }
        }
    }

    Chip {
        hasDot: true
        dotColor: (Network.ethernetConnected || Network.active)
                    ? Colors.live
                    : Colors.stale
        label: Network.ethernet
                 ? "ETH"
                 : (Network.active ? "WIFI" : "OFFLINE")
    }

    Chip {
        visible: Power.isLaptopBattery
        label: Math.round(Power.percentage * 100) + "%"
        textColor: (!Power.isCharging && Power.percentage < 0.2)
                     ? Colors.warning
                     : Colors.inkDim
    }

    Chip {
        label: root.layout
        // TODO(lockscreen/kbd): pull live layout from `niri msg keyboard-layouts`.
    }
}
