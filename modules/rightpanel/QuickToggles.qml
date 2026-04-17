pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.common
import qs.widgets

RowLayout {
    id: root

    Layout.fillWidth: true
    spacing: 0

    property var toggles: [
        { label: "wifi",   icon: "wifi",               on: true  },
        { label: "bt",     icon: "bluetooth",          on: false },
        { label: "dnd",    icon: "do_not_disturb_on",  on: true  },
        { label: "night",  icon: "dark_mode",          on: false }
    ]

    Repeater {
        model: root.toggles

        delegate: Item {
            id: cell
            required property var modelData
            required property int index

            property bool on: cell.modelData.on
            property bool hovered: ma.containsMouse

            Layout.fillWidth: true
            Layout.fillHeight: false
            implicitHeight: 56

            Rectangle {
                anchors.fill: parent
                color: cell.hovered || cell.on ? Colors.surfaceContainerLow : "transparent"
                Behavior on color { ColorAnimation { duration: Theme.anim.durations.xs } }

                Rectangle {
                    visible: cell.on
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    height: Theme.ui.mainBarHairWidth
                    color: Colors.hairHot
                }

                Rectangle {
                    visible: cell.index < root.toggles.length - 1
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: Theme.ui.mainBarHairWidth
                    color: Colors.hair
                }
            }

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 6

                MaterialSymbol {
                    Layout.alignment: Qt.AlignHCenter
                    icon: cell.modelData.icon
                    iconSize: 16
                    fontColor: cell.hovered || cell.on ? Colors.fgSurface : Colors.inkDim
                    opacity: cell.hovered || cell.on ? 1.0 : 0.72
                    fill: cell.on ? 1 : 0
                    colorAnimated: true
                    Behavior on opacity { NumberAnimation { duration: 150 } }
                }

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: cell.modelData.label.toUpperCase()
                    color: cell.hovered || cell.on ? Colors.fgSurface : Colors.inkDim
                    font.family: Theme.font.family.inter_medium
                    font.pixelSize: 10
                    font.letterSpacing: 1.4
                    Behavior on color { ColorAnimation { duration: 150 } }
                }
            }

            MouseArea {
                id: ma
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: cell.on = !cell.on
            }
        }
    }
}
