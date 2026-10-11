pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.common
import qs.services
import qs.modules.controlcenter.atoms

Flickable {
    id: root

    Component.onCompleted: console.log("[ControlCenter.power] loaded")
    Component.onDestruction: console.log("[ControlCenter.power] unloaded")

    readonly property bool laptop: Power.isLaptopBattery

    contentWidth: width
    contentHeight: column.implicitHeight + column.anchors.topMargin + column.anchors.bottomMargin
    boundsBehavior: Flickable.StopAtBounds
    clip: true

    readonly property var profileOptions: [
        { id: "PowerSaver",  label: "Saver" },
        { id: "Balanced",    label: "Balanced" },
        { id: "Performance", label: "Performance" }
    ]

    component TimerGroup: GroupBox {
        id: group
        required property string which
        required property var set
        property bool trailing: false
        property bool leading: false

        ToggleRow {
            visible: group.leading
            label: "Caffeine"
            checked: GlobalStates.caffeinated
            showSeparator: true
            onToggled: GlobalStates.toggleCaffeine()
        }
        DurationPicker {
            title: "Lock after"
            seconds: group.set.lock
            available: !GlobalStates.caffeinated
            showSeparator: true
            onPicked: s => Preferences.setIdleTimer(group.which, "lock", s)
        }
        DurationPicker {
            title: "Screen off after"
            seconds: group.set.screenOff
            available: !GlobalStates.caffeinated
            showSeparator: true
            onPicked: s => Preferences.setIdleTimer(group.which, "screenOff", s)
        }
        DurationPicker {
            title: "Suspend after"
            seconds: group.set.suspend
            available: !GlobalStates.caffeinated
            showSeparator: group.trailing
            onPicked: s => Preferences.setIdleTimer(group.which, "suspend", s)
        }
    }

    ColumnLayout {
        id: column
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.leftMargin: 26
        anchors.rightMargin: 26
        anchors.topMargin: 22
        anchors.bottomMargin: 24
        spacing: 0

        BatteryCard {
            visible: root.laptop
        }

        GroupLabel {
            Layout.topMargin: root.laptop ? 18 : 0
            text: "Power profile"
        }

        GroupBox {
            Item {
                visible: Power.profilesAvailable || Power.profilesProbing
                Layout.fillWidth: true
                implicitHeight: 44
                opacity: Power.profilesProbing ? 0.45 : 1

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 14
                    anchors.rightMargin: 14
                    spacing: 12

                    Text {
                        Layout.fillWidth: true
                        text: "Mode"
                        color: Colors.fgSurface
                        font.family: Theme.font.family.inter
                        font.pixelSize: Theme.font.size.body
                    }

                    SegmentedControl {
                        Layout.alignment: Qt.AlignVCenter
                        options: root.profileOptions
                        current: Power.currentProfile
                        onSelected: id => Power.setPowerProfile(id)
                    }
                }
            }

            NoteRow {
                visible: !Power.profilesAvailable && !Power.profilesProbing
                iconSymbol: "bolt"
                label: "Power profiles unavailable"
                sub: Power.profilesUnavailableReason
            }
        }

        GroupLabel { text: root.laptop ? "Plugged in" : "Automatic" }

        TimerGroup { which: "ac"; set: Preferences.idleAc; leading: true }

        GroupLabel { visible: root.laptop; text: "On battery" }

        TimerGroup {
            visible: root.laptop
            which: "battery"
            set: Preferences.idleBattery
            trailing: true

            ToggleRow {
                label: "Show percentage in bar"
                checked: Preferences.showBatteryPercentInBar
                onToggled: Preferences.setShowBatteryPercentInBar(!Preferences.showBatteryPercentInBar)
            }
        }

        GroupLabel { visible: root.laptop && Power.healthSupported; text: "Battery health" }

        GroupBox {
            visible: root.laptop && Power.healthSupported

            Item {
                Layout.fillWidth: true
                implicitHeight: 44

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 14
                    anchors.rightMargin: 14

                    Text {
                        Layout.fillWidth: true
                        text: "Maximum capacity"
                        color: Colors.fgSurface
                        font.family: Theme.font.family.inter
                        font.pixelSize: Theme.font.size.body
                    }

                    Text {
                        text: Math.round(Power.healthPercentage * 100) + "%"
                        color: Colors.inkDim
                        font.family: Theme.font.family.inter
                        font.pixelSize: Theme.font.size.body
                    }
                }
            }
        }
    }
}
