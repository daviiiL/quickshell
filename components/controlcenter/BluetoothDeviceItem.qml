pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell.Bluetooth

import qs.common
import qs.services
import qs.widgets

Rectangle {
    id: btItem
    required property BluetoothDevice device
    height: device?.paired && !device?.connected ? 140 : 60
    radius: Theme.ui.radius.md
    color: btMouseArea.containsMouse ? Colors.surface_container_high : Colors.surface_container

    Behavior on height {
        NumberAnimation {
            duration: Theme.anim.durations.sm
            easing.type: Easing.Bezier
            easing.bezierCurve: Theme.anim.curves.emphasized
        }
    }

    Behavior on color {
        ColorAnimation {
            duration: Theme.anim.durations.sm
            easing.type: Easing.Bezier
            easing.bezierCurve: Theme.anim.curves.emphasized
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.ui.padding.md
        spacing: Theme.ui.padding.sm

        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.ui.padding.md

            MaterialSymbol {
                Layout.alignment: Qt.AlignVCenter
                icon: {
                    const type = btItem.device?.type ?? "";
                    if (type.includes("audio") || type.includes("headset") || type.includes("headphone"))
                        return "headphones";
                    if (type.includes("phone"))
                        return "phone_android";
                    if (type.includes("computer"))
                        return "computer";
                    if (type.includes("keyboard"))
                        return "keyboard";
                    if (type.includes("mouse"))
                        return "mouse";
                    return "bluetooth";
                }
                fontColor: Colors.on_surface_variant
                iconSize: Theme.font.size.xl
            }

            ColumnLayout {
                Layout.fillHeight: true
                Layout.fillWidth: true
                spacing: 2

                Text {
                    text: btItem.device?.name ?? "Unknown Device"
                    font {
                        pixelSize: Theme.font.size.md
                        family: Theme.font.family.inter_regular
                    }
                    color: Colors.on_surface
                    elide: Text.ElideRight
                }

                Text {
                    visible: btItem.device && btItem.device?.paired && !btItem.device?.connected
                    text: "Paired"
                    font.pixelSize: Theme.font.size.xs
                    color: Colors.on_surface_variant
                }

                Text {
                    visible: btItem.device?.connected ?? false
                    text: {
                        let status = "Connected";
                        if (btItem.device?.batteryAvailable) {
                            status += ` • ${Math.round(btItem.device.battery * 100)}%`;
                        }
                        return status;
                    }
                    font.pixelSize: Theme.font.size.xs
                    color: Colors.primary
                }
            }

            Item {
                Layout.fillWidth: true
            }

            Text {
                visible: btItem.device && btItem.device?.connected
                text: "check"
                font {
                    pixelSize: Theme.font.size.xl
                    family: "Material Symbols Outlined"
                }
                color: Colors.primary
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            visible: btItem.device && btItem.device?.paired && !btItem.device?.connected
            spacing: Theme.ui.padding.sm

            Text {
                Layout.fillWidth: true
                text: "This device is paired but not connected. Click connect to establish a connection."
                font.pixelSize: Theme.font.size.xs
                color: Colors.on_surface_variant
                wrapMode: Text.WordWrap
            }

            RowLayout {
                Layout.fillWidth: true

                Item {
                    Layout.fillWidth: true
                }

                Rectangle {
                    Layout.preferredWidth: 80
                    Layout.preferredHeight: 32
                    radius: Theme.ui.radius.sm
                    color: unpairBtnMouseArea.containsMouse ? Colors.error_container : Colors.surface_container_highest

                    Text {
                        anchors.centerIn: parent
                        text: "Unpair"
                        font.pixelSize: Theme.font.size.sm
                        color: unpairBtnMouseArea.containsMouse ? Colors.on_error_container : Colors.on_surface
                    }

                    MouseArea {
                        id: unpairBtnMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            SystemBluetooth.unpairDevice(btItem.device);
                        }
                    }
                }

                Rectangle {
                    Layout.preferredWidth: 80
                    Layout.preferredHeight: 32
                    radius: Theme.ui.radius.sm
                    color: connectBtnMouseArea.containsMouse ? Colors.primary_container : Colors.primary

                    Text {
                        anchors.centerIn: parent
                        text: "Connect"
                        font.pixelSize: Theme.font.size.sm
                        color: connectBtnMouseArea.containsMouse ? Colors.on_primary_container : Colors.on_primary
                    }

                    MouseArea {
                        id: connectBtnMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            SystemBluetooth.connectDevice(btItem.device);
                        }
                    }
                }
            }
        }
    }

    MouseArea {
        id: btMouseArea
        anchors.fill: parent
        hoverEnabled: true
        enabled: !(btItem.device?.paired && !btItem.device?.connected)
        onClicked: {
            if (btItem.device?.connected) {
                SystemBluetooth.disconnectDevice(btItem.device);
            } else if (btItem.device?.paired) {
                SystemBluetooth.connectDevice(btItem.device);
            } else {
                // Pair first
                SystemBluetooth.pairDevice(btItem.device);
            }
        }
    }
}
