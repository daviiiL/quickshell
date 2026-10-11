pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.common
import qs.modules.controlcenter.atoms

Rectangle {
    id: root

    required property var panes
    required property string currentPane

    signal paneSelected(string name)

    readonly property string userName: Quickshell.env("USER") || "user"
    readonly property string initial: root.userName.substring(0, 1).toUpperCase()

    Component.onCompleted: console.log("[ControlCenter.sidebar] loaded")
    Component.onDestruction: console.log("[ControlCenter.sidebar] unloaded")

    implicitWidth: 224
    color: Colors.surfaceContainerLowest

    Rectangle {
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: Theme.ui.mainBarHairWidth
        color: Colors.hair
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: 14
            Layout.rightMargin: 14
            Layout.topMargin: 14
            Layout.bottomMargin: 12
            spacing: 10

            Rectangle {
                Layout.preferredWidth: 30
                Layout.preferredHeight: 30
                radius: 15
                color: Colors.surfaceContainerHigh
                border.color: Colors.hairHot
                border.width: Theme.ui.mainBarHairWidth

                Text {
                    anchors.centerIn: parent
                    text: root.initial
                    color: Colors.fgSurface
                    font.family: Theme.font.family.inter_medium
                    font.pixelSize: Theme.font.size.body
                    font.weight: Font.Medium
                }
            }

            Text {
                Layout.alignment: Qt.AlignVCenter
                text: root.userName
                color: Colors.fgSurface
                font.family: Theme.font.family.inter_medium
                font.pixelSize: Theme.font.size.body
                font.weight: Font.Medium
            }

            Item { Layout.fillWidth: true }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: Theme.ui.mainBarHairWidth
            color: Colors.hair
        }

        Item { Layout.preferredHeight: 6 }

        Repeater {
            model: root.panes

            ColumnLayout {
                id: itemColumn
                required property var modelData
                required property int index

                readonly property bool isFirstInSection:
                    itemColumn.index === 0
                    || root.panes[itemColumn.index - 1].section !== itemColumn.modelData.section

                Layout.fillWidth: true
                spacing: 0

                Rectangle {
                    visible: itemColumn.isFirstInSection && itemColumn.index > 0
                    Layout.fillWidth: true
                    Layout.leftMargin: 14
                    Layout.rightMargin: 14
                    Layout.topMargin: 8
                    Layout.bottomMargin: 8
                    Layout.preferredHeight: Theme.ui.mainBarHairWidth
                    color: Colors.hair
                }

                SidebarItem {
                    label: itemColumn.modelData.label
                    icon: itemColumn.modelData.icon
                    meta: itemColumn.modelData.meta || ""
                    active: itemColumn.modelData.name === root.currentPane
                    onActivated: root.paneSelected(itemColumn.modelData.name)
                }
            }
        }

        Item { Layout.fillHeight: true }
    }
}
