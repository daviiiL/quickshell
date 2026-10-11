pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.common
import qs.services
import qs.modules.controlcenter.atoms

Flickable {
    id: root

    Component.onCompleted: console.log("[ControlCenter.quick] loaded")
    Component.onDestruction: console.log("[ControlCenter.quick] unloaded")

    contentWidth: width
    contentHeight: column.implicitHeight + column.anchors.topMargin + column.anchors.bottomMargin
    boundsBehavior: Flickable.StopAtBounds
    clip: true

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

        GridLayout {
            Layout.fillWidth: true
            columns: 4
            rowSpacing: 10
            columnSpacing: 10

            QuickTile {
                Layout.fillWidth: true
                icon: "wifi"
                label: "Wi-Fi"
                sub: {
                    if (Network.active?.ssid) return Network.active.ssid;
                    return Network.wifiEnabled ? "Disconnected" : "Off";
                }
                on: Network.wifiEnabled && !!Network.active
                onActivated: Network.toggleWifi()
            }

            QuickTile {
                Layout.fillWidth: true
                icon: "bluetooth"
                label: "Bluetooth"
                sub: {
                    if (!SystemBluetooth.available) return "Unavailable";
                    if (!SystemBluetooth.enabled) return "Off";
                    const n = SystemBluetooth.connectedDevices.length;
                    return n === 0 ? "On" : n === 1 ? "1 device" : `${n} devices`;
                }
                on: SystemBluetooth.available && SystemBluetooth.enabled
                available: SystemBluetooth.available
                onActivated: SystemBluetooth.toggleBluetooth()
            }

            QuickTile {
                Layout.fillWidth: true
                icon: "flight"
                label: "Airplane"
                sub: "Unavailable"
                available: false
            }

            QuickTile {
                Layout.fillWidth: true
                icon: "do_not_disturb_on"
                label: "Do not disturb"
                sub: Notifications.silent ? "Silent" : "Off"
                on: Notifications.silent
                onActivated: Notifications.silent = !Notifications.silent
            }

            QuickTile {
                Layout.fillWidth: true
                icon: "dark_mode"
                label: "Dark mode"
                sub: GlobalStates.darkMode ? "On" : "Off"
                on: GlobalStates.darkMode
                onActivated: GlobalStates.toggleDarkMode()
            }

            QuickTile {
                Layout.fillWidth: true
                icon: "wb_twilight"
                label: "Night light"
                sub: "Unavailable"
                available: false
            }

            QuickTile {
                Layout.fillWidth: true
                icon: "center_focus_strong"
                label: "Focused"
                sub: Preferences.focusedMode ? "Bar hidden" : "Off"
                on: Preferences.focusedMode
                onActivated: Preferences.toggleFocusMode()
            }

            QuickTile {
                Layout.fillWidth: true
                icon: "coffee"
                label: "Caffeine"
                sub: GlobalStates.caffeinated ? "Idle paused" : "Off"
                on: GlobalStates.caffeinated
                onActivated: GlobalStates.toggleCaffeine()
            }
        }

        GroupLabel { text: "Brightness" }

        GroupBox {
            SliderRow {
                iconSymbol: "brightness_6"
                label: "Display"
                value: Brightness.brightness / 100
                available: Brightness.available
                onMoved: v => Brightness.setBrightness(Math.round(v * 100))
            }
        }

        GroupLabel { text: "Volume" }

        GroupBox {
            SliderRow {
                iconSymbol: "volume_up"
                label: "Speakers"
                value: SystemAudio.ready ? SystemAudio.volume : 0
                available: SystemAudio.ready
                onMoved: v => SystemAudio.setVolume(v)
            }
        }

        GroupLabel { text: "Session" }

        RowLayout {
            id: sessionStrip
            Layout.fillWidth: true
            spacing: 8

            function closeAnd(action): void {
                GlobalStates.closeControlCenter();
                action();
            }

            SessionStripButton { label: "Lock";      icon: "lock";               onActivated: sessionStrip.closeAnd(SessionActions.lock) }
            SessionStripButton { label: "Suspend";   icon: "dark_mode";          onActivated: sessionStrip.closeAnd(SessionActions.suspend) }
            SessionStripButton { label: "Hibernate"; icon: "schedule";           onActivated: sessionStrip.closeAnd(SessionActions.hibernate) }
            SessionStripButton { label: "Log out";   icon: "logout";             confirm: true; onActivated: sessionStrip.closeAnd(SessionActions.logout) }
            SessionStripButton { label: "Restart";   icon: "restart_alt";        confirm: true; danger: true; onActivated: sessionStrip.closeAnd(SessionActions.reboot) }
            SessionStripButton { label: "Shut down"; icon: "power_settings_new"; confirm: true; danger: true; onActivated: sessionStrip.closeAnd(SessionActions.poweroff) }
        }
    }
}
