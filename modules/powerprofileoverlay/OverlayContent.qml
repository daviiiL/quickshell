pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.common
import qs.services
import qs.widgets

Item {
    id: root

    readonly property var profiles: [
        { id: "Performance", name: "Performance", icon: "speed",
          description: "Maximum responsiveness · higher draw" },
        { id: "Balanced",    name: "Balanced",    icon: "donut_large",
          description: "System-managed · default for everyday work" },
        { id: "PowerSaver",  name: "Power Saver", icon: "energy_savings_leaf",
          description: "Extends battery · throttled CPU and effects" }
    ]

    implicitHeight: col.implicitHeight

    ColumnLayout {
        id: col
        anchors.fill: parent
        spacing: 0

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 36

            Text {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 14
                text: "POWER PROFILE"
                color: Colors.inkDimmer
                font.family: Theme.font.family.inter_medium
                font.pixelSize: 10
                font.weight: Font.Medium
                font.letterSpacing: 1.8
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: Theme.ui.mainBarHairWidth
            color: Colors.hair
        }

        Repeater {
            model: root.profiles
            delegate: ProfileRow {
                required property var modelData
                required property int index

                Layout.fillWidth: true
                iconName: modelData.icon
                name: modelData.name
                description: modelData.description
                active: Power.currentProfile === modelData.id
                last: index === root.profiles.length - 1

                onActivated: Power.setPowerProfile(modelData.id)
            }
        }

        Rectangle {
            visible: Power.isLaptopBattery
            Layout.fillWidth: true
            Layout.preferredHeight: Theme.ui.mainBarHairWidth
            color: Colors.hair
        }

        Item {
            visible: Power.isLaptopBattery
            Layout.fillWidth: true
            Layout.preferredHeight: 32

            Rectangle {
                anchors.fill: parent
                color: Colors.surfaceContainerLowest
            }

            RowLayout {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 14
                anchors.right: parent.right
                anchors.rightMargin: 14
                spacing: 8

                MaterialSymbol {
                    icon: "battery_full"
                    iconSize: 11
                    fontColor: Colors.inkDim
                }

                Text {
                    Layout.fillWidth: true
                    text: Math.round(Power.percentage * 100) + "% · " + Power.batteryStatusText
                    color: Colors.inkDim
                    font.family: Theme.font.family.inter_regular
                    font.pixelSize: 11
                    font.letterSpacing: 0.2
                    elide: Text.ElideRight
                }
            }
        }
    }
}
