pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.common
import qs.services
import qs.modules.controlcenter.atoms

Item {
    id: root

    Component.onCompleted: console.log("[ControlCenter.session] loaded")
    Component.onDestruction: console.log("[ControlCenter.session] unloaded")

    function closeAnd(action): void {
        GlobalStates.closeControlCenter();
        action();
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.leftMargin: 26
        anchors.rightMargin: 26
        anchors.topMargin: 22
        anchors.bottomMargin: 24
        spacing: 0

        Text {
            text: "Power"
            color: Colors.fgSurface
            font.family: Theme.font.family.inter_medium
            font.pixelSize: 19
            font.weight: Font.Medium
        }

        Text {
            Layout.topMargin: 4
            Layout.bottomMargin: 18
            text: "END OR SUSPEND SESSION"
            color: Colors.inkDimmer
            font.family: Theme.font.family.inter_medium
            font.pixelSize: 10
            font.letterSpacing: 2.4
        }

        GridLayout {
            Layout.fillWidth: true
            columns: 3
            rowSpacing: 10
            columnSpacing: 10

            SessionButton {
                Layout.fillWidth: true
                label: "Lock"
                icon: "lock"
                sub: "Lock the screen now"
                onActivated: root.closeAnd(SessionActions.lock)
            }

            SessionButton {
                Layout.fillWidth: true
                label: "Suspend"
                icon: "dark_mode"
                sub: "Save state to RAM"
                onActivated: root.closeAnd(SessionActions.suspend)
            }

            SessionButton {
                Layout.fillWidth: true
                label: "Log Out"
                icon: "logout"
                sub: "End the current session"
                onActivated: root.closeAnd(SessionActions.logout)
            }

            SessionButton {
                Layout.fillWidth: true
                label: "Restart"
                icon: "restart_alt"
                sub: "Reboot the system"
                danger: true
                onActivated: root.closeAnd(SessionActions.reboot)
            }

            SessionButton {
                Layout.fillWidth: true
                label: "Shut Down"
                icon: "power_settings_new"
                sub: "Power off"
                danger: true
                onActivated: root.closeAnd(SessionActions.poweroff)
            }

            SessionButton {
                Layout.fillWidth: true
                label: "Hibernate"
                icon: "schedule"
                sub: "Save state to disk"
                onActivated: root.closeAnd(SessionActions.hibernate)
            }
        }

        Item { Layout.fillHeight: true }
    }
}
