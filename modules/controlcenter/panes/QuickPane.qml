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

        Text {
            text: "Quick Settings"
            color: Colors.fgSurface
            font.family: Theme.font.family.inter_medium
            font.pixelSize: 19
            font.weight: Font.Medium
        }

        Text {
            Layout.topMargin: 4
            Layout.bottomMargin: 18
            text: "TOGGLES · BRIGHTNESS · VOLUME"
            color: Colors.inkDimmer
            font.family: Theme.font.family.inter_medium
            font.pixelSize: 10
            font.letterSpacing: 2.4
        }

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
                label: "Do Not Disturb"
                sub: Notifications.silent ? "Silent" : "Off"
                on: Notifications.silent
                onActivated: Notifications.silent = !Notifications.silent
            }

            QuickTile {
                Layout.fillWidth: true
                icon: "dark_mode"
                label: "Dark Mode"
                sub: GlobalStates.darkMode ? "On" : "Off"
                on: GlobalStates.darkMode
                onActivated: GlobalStates.toggleDarkMode()
            }

            QuickTile {
                Layout.fillWidth: true
                icon: "wb_twilight"
                label: "Night Light"
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
                icon: "lock"
                label: "Lock"
                sub: "Now"
                onActivated: {
                    GlobalStates.closeControlCenter();
                    SessionActions.lock();
                }
            }
        }

        GroupLabel { text: "BRIGHTNESS" }

        GroupBox {
            SliderRow {
                iconSymbol: "brightness_6"
                label: "Display"
                value: Brightness.brightness / 100
                available: Brightness.available
                onMoved: v => Brightness.setBrightness(Math.round(v * 100))
            }
        }

        GroupLabel { text: "VOLUME" }

        GroupBox {
            SliderRow {
                iconSymbol: "volume_up"
                label: "Speakers"
                value: SystemAudio.ready ? SystemAudio.volume : 0
                available: SystemAudio.ready
                onMoved: v => SystemAudio.setVolume(v)
            }
        }
    }
}
