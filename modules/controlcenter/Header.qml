pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.common
import qs.widgets
import qs.modules.controlcenter.atoms

Rectangle {
    id: root

    required property string section
    required property string label

    signal closeRequested()

    Component.onCompleted: console.log("[ControlCenter.header] loaded")
    Component.onDestruction: console.log("[ControlCenter.header] unloaded")

    implicitHeight: 44
    color: Colors.surfaceContainerLowest

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: Theme.ui.mainBarHairWidth
        color: Colors.hair
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 14
        anchors.rightMargin: 14
        spacing: 10

        Row {
            Layout.alignment: Qt.AlignVCenter
            spacing: 6

            Text {
                text: root.section
                color: Colors.inkDimmer
                font.family: Theme.font.family.inter_medium
                font.pixelSize: 11
                font.weight: Font.Medium
                font.letterSpacing: 3.0
            }

            Text {
                text: "·"
                color: Colors.inkFaint
                font.family: Theme.font.family.inter_medium
                font.pixelSize: 11
                font.letterSpacing: 3.0
            }

            Text {
                text: root.label.toUpperCase()
                color: Colors.fgSurface
                font.family: Theme.font.family.inter_medium
                font.pixelSize: 11
                font.weight: Font.Medium
                font.letterSpacing: 3.0
            }
        }

        Item { Layout.fillWidth: true }

        Rectangle {
            Layout.preferredWidth: 220
            Layout.preferredHeight: 26
            radius: 3
            color: Colors.surfaceContainerLow
            border.color: Colors.hair
            border.width: Theme.ui.mainBarHairWidth

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                spacing: 8

                MaterialSymbol {
                    Layout.alignment: Qt.AlignVCenter
                    icon: "search"
                    iconSize: 12
                    fontColor: Colors.inkDim
                }

                Text {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    text: "Search…"
                    color: Colors.inkFaint
                    font.family: Theme.font.family.inter
                    font.pixelSize: 11
                    font.letterSpacing: 0.6
                }
            }
        }

        CloseButton {
            Layout.alignment: Qt.AlignVCenter
            onActivated: root.closeRequested()
        }
    }
}
