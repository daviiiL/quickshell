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
    id: root
    color: "transparent"

    property bool showChildren: SystemBluetooth.enabled ?? false

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.ui.padding.lg

        spacing: Theme.ui.padding.lg

        ControlCenterPanelSection {
            title: "Bluetooth"
            checked: SystemBluetooth.enabled
            onToggled: SystemBluetooth.toggleBluetooth()
            showConnectionCard: SystemBluetooth.connected
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
                visible: SystemBluetooth.pairedButNotConnectedDevices.length > 0 && root.showChildren
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
                    model: ScriptModel {
                        values: SystemBluetooth.pairedButNotConnectedDevices
                    }

                    delegate: KnownBluetoothDeviceItem {
                        required property var modelData
                        Layout.fillWidth: true
                        device: modelData
                    }
                }
            }

            RowLayout {
                visible: root.showChildren
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
                        rotation: SystemBluetooth.discovering ? 360 : 0
                        NumberAnimation on rotation {
                            loops: Animation.Infinite
                            duration: 1000
                            from: 0
                            to: 360
                            easing.type: Easing.Linear
                            running: SystemBluetooth.discovering
                        }
                    }

                    MouseArea {
                        id: refreshMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: () => SystemBluetooth.startDiscovering()
                    }
                }
            }

            ScrollView {
                visible: root.showChildren
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true

                onVisibleChanged: {
                    if (this.visible) {
                        SystemBluetooth.startDiscovering();
                    }
                }

                ListView {
                    id: devicesListView
                    spacing: Theme.ui.padding.sm

                    model: ScriptModel {
                        values: SystemBluetooth.friendlyDeviceList
                    }

                    delegate: BluetoothDeviceItem {
                        required property var modelData
                        width: devicesListView.width
                        device: modelData
                    }
                }
            }

            Item {
                visible: !root.showChildren
                Layout.fillHeight: true
            }
        }
    }
}
