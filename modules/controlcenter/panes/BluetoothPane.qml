pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell.Bluetooth
import qs.common
import qs.services
import qs.modules.controlcenter.atoms

Flickable {
    id: root

    Component.onCompleted: {
        console.log("[ControlCenter.bluetooth] loaded");
        if (SystemBluetooth.available && SystemBluetooth.enabled) {
            SystemBluetooth.startDiscovering();
        }
    }
    Component.onDestruction: {
        console.log("[ControlCenter.bluetooth] unloaded");
        if (SystemBluetooth.available && SystemBluetooth.enabled) {
            SystemBluetooth.stopDiscovering();
        }
    }

    contentWidth: width
    contentHeight: column.implicitHeight + column.anchors.topMargin + column.anchors.bottomMargin
    boundsBehavior: Flickable.StopAtBounds
    clip: true

    function deviceMeta(device: var): string {
        if (!device) return "";
        const t = String(device.deviceType ?? "").toLowerCase();
        if (!t) return "";
        if (t.includes("audio") || t.includes("headset") || t.includes("headphone")) return "Audio";
        if (t.includes("keyboard")) return "Keyboard";
        if (t.includes("mouse"))    return "Mouse";
        if (t.includes("phone"))    return "Phone";
        if (t.includes("computer")) return "Computer";
        return t.charAt(0).toUpperCase() + t.slice(1);
    }

    function connectedChip(device: var): string {
        if (!device || !device.connected) return "Not connected";
        const b = device.battery;
        const battery = (typeof b === "number" && b >= 0 && b <= 100) ? ` · ${Math.round(b)}%` : "";
        return `Connected${battery}`;
    }

    function tryToggle(device: var): void {
        if (!device) return;
        if (device.connected)   SystemBluetooth.disconnectDevice(device);
        else if (device.paired) SystemBluetooth.connectDevice(device);
        else                    SystemBluetooth.pairDevice(device);
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

        Text {
            text: "Bluetooth"
            color: Colors.fgSurface
            font.family: Theme.font.family.inter_medium
            font.pixelSize: 19
            font.weight: Font.Medium
        }

        Text {
            Layout.topMargin: 4
            Layout.bottomMargin: 18
            text: "PAIRED DEVICES · DISCOVERY"
            color: Colors.inkDimmer
            font.family: Theme.font.family.inter_medium
            font.pixelSize: 10
            font.letterSpacing: 2.4
        }

        GroupBox {
            ToggleRow {
                label: "Bluetooth"
                checked: SystemBluetooth.enabled
                available: SystemBluetooth.available
                showSeparator: true
                onToggled: SystemBluetooth.toggleBluetooth()
            }

            DeviceRow {
                icon: "bluetooth"
                name: "Discoverable as"
                meta: Bluetooth.defaultAdapter?.name ?? "—"
            }
        }

        Loader {
            Layout.fillWidth: true
            active: SystemBluetooth.available && SystemBluetooth.enabled
            visible: active

            sourceComponent: Component {
                ColumnLayout {
                    spacing: 0

                    GroupLabel { text: "MY DEVICES" }

                    GroupBox {
                        Repeater {
                            id: pairedRepeater
                            model: SystemBluetooth.friendlyDeviceList.filter(d => d?.paired)

                            delegate: DeviceRow {
                                required property var modelData
                                required property int index

                                icon: SystemBluetooth.bluetoothDeviceIconName(String(modelData?.deviceType ?? ""))
                                name: modelData?.name || "Unknown"
                                meta: root.deviceMeta(modelData)
                                chipText: root.connectedChip(modelData)
                                chipVariant: modelData?.connected ? "live" : "default"
                                clickable: true
                                showSeparator: index < pairedRepeater.count - 1
                                onActivated: root.tryToggle(modelData)
                            }
                        }

                        DeviceRow {
                            visible: pairedRepeater.count === 0
                            icon: "bluetooth_disabled"
                            name: "No paired devices"
                            meta: nearbyRepeater.count > 0 ? "Pair one from the list below" : "Scan for nearby devices"
                        }
                    }

                    GroupLabel {
                        text: SystemBluetooth.discovering ? "NEARBY · SCANNING…" : "NEARBY"
                    }

                    GroupBox {
                        Repeater {
                            id: nearbyRepeater
                            model: SystemBluetooth.unpairedDevices

                            delegate: DeviceRow {
                                required property var modelData
                                required property int index

                                icon: SystemBluetooth.bluetoothDeviceIconName(String(modelData?.deviceType ?? ""))
                                name: modelData?.name || "Unknown device"
                                meta: root.deviceMeta(modelData)
                                showChevron: true
                                clickable: true
                                showSeparator: index < nearbyRepeater.count - 1
                                onActivated: root.tryToggle(modelData)
                            }
                        }

                        DeviceRow {
                            visible: nearbyRepeater.count === 0
                            icon: "search"
                            name: SystemBluetooth.discovering ? "Scanning…" : "No nearby devices"
                            meta: SystemBluetooth.discovering ? "" : "Tap to scan"
                            clickable: !SystemBluetooth.discovering
                            onActivated: SystemBluetooth.startDiscovering()
                        }
                    }
                }
            }
        }
    }
}
