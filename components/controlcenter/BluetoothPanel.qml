pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Bluetooth

import qs.common
import qs.services
import qs.widgets

Rectangle {
    color: "transparent"

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.ui.padding.lg

        spacing: Theme.ui.padding.lg

        NetworkPanelSection {
            title: "Bluetooth"
            checked: Bluetooth.enabled
            onToggled: Bluetooth.toggleBluetooth
            showConnectionCard: Bluetooth.connected && Bluetooth.enabled
            connectionIcon: "bluetooth"
            connectionTitle: Bluetooth.firstActiveDevice?.name ?? "Unknown Device"
            connectionSubtitle: {
                let status = "Connected";
                if (Bluetooth.firstActiveDevice?.batteryAvailable) {
                    status += ` • ${Math.round(Bluetooth.firstActiveDevice.battery * 100)}%`;
                }
                return status;
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.topMargin: Theme.ui.padding.md
                visible: Bluetooth.pairedButNotConnectedDevices.length > 0 && Bluetooth.enabled
                spacing: Theme.ui.padding.sm

                Text {
                    text: "Paired Devices"
                    font {
                        pixelSize: Theme.font.size.lg
                        family: Theme.font.family.inter_medium
                        weight: Font.Medium
                    }
                    color: Colors.on_surface
                }

                Repeater {
                    model: Bluetooth.pairedButNotConnectedDevices

                    delegate: KnownBluetoothDeviceItem {
                        required property var modelData
                        Layout.fillWidth: true
                        device: modelData
                    }
                }
            }

            RowLayout {
                visible: Bluetooth.enabled
                Layout.fillWidth: true
                Layout.topMargin: Theme.ui.padding.md

                Text {
                    text: "Available Devices"
                    font {
                        pixelSize: Theme.font.size.lg
                        family: Theme.font.family.inter_medium
                        weight: Font.Medium
                    }
                    color: Colors.on_surface
                }

                Item {
                    Layout.fillWidth: true
                }

                Rectangle {
                    Layout.preferredHeight: 32
                    Layout.preferredWidth: 32
                    radius: Theme.ui.radius.sm
                    color: refreshMouseArea.containsMouse ? Colors.surface_container_high : "transparent"

                    Text {
                        anchors.centerIn: parent
                        text: "refresh"
                        font {
                            pixelSize: Theme.font.size.xl
                            family: "Material Symbols Outlined"
                        }
                        color: Colors.on_surface
                        rotation: Bluetooth.discovering ? 360 : 0

                        Behavior on rotation {
                            NumberAnimation {
                                duration: 1000
                                easing.type: Easing.Linear
                            }
                        }
                    }

                    MouseArea {
                        id: refreshMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: Bluetooth.startDiscovering()
                    }
                }
            }

            ScrollView {
                visible: Bluetooth.enabled
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true

                ListView {
                    id: devicesListView
                    spacing: Theme.ui.padding.sm

                    model: ScriptModel {
                        values: Bluetooth.friendlyDeviceList
                    }

                    delegate: BluetoothDeviceItem {
                        required property var modelData
                        width: devicesListView.width
                        device: modelData
                    }
                }
            }

            Item {
                visible: !Bluetooth.enabled
                Layout.fillHeight: true
            }
        }
    }
}
