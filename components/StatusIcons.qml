pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Qt5Compat.GraphicalEffects
import Quickshell.Io
import "../common/"
import "../services/"
import "./widgets"

Item {
    id: root

    property bool expanded: container.expanded

    implicitHeight: container.height
    implicitWidth: parent.width

    function getNetworkIcon(strength: int): string {
        if (strength >= 80)
            return "signal_wifi_4_bar";
        if (strength >= 60)
            return "network_wifi_3_bar";
        if (strength >= 40)
            return "network_wifi_2_bar";
        if (strength >= 20)
            return "network_wifi_1_bar";
        return "signal_wifi_0_bar";
    }

    ExpandingContainer {
        id: container
        anchors.leftMargin: 6
        collapsedWidth: Theme.bar.width - 12
        expandedWidth: Theme.bar.width * 4 - 12
        anchors.left: parent.left
        animationDuration: 100
        antialiasing: true
        radius: Theme.rounding.small
        implicitHeight: 80

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: (container.collapsedWidth - Math.max(networkIcon.implicitWidth, bluetoothIcon.implicitWidth)) / 2

            Rectangle {
                id: bluetooth
                implicitHeight: Math.max(bluetoothIcon.implicitHeight, bluetoothText.implicitHeight)
                Layout.fillWidth: true
                Layout.minimumWidth: container.expandedWidth
                color: "transparent"

                RowLayout {
                    spacing: 10
                    MaterialSymbol {
                        id: bluetoothIcon
                        icon: Bluetooth.powered ? "bluetooth" : "bluetooth_disabled"
                        fontColor: bluetoothMouseArea.containsMouse ? Colors.current.primary : Colors.current.on_secondary_container
                        iconSize: 15
                        animated: true

                        Process {
                            id: launchBlueberry
                            command: ["sh", "-c", "blueberry"]
                            running: false
                        }

                        MouseArea {
                            id: bluetoothMouseArea
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onPressed: {
                                launchBlueberry.running = true;
                            }
                        }
                    }
                    Text {
                        id: bluetoothText
                        text: {
                            if (!Bluetooth.powered)
                                return "Bluetooth off";
                            return Bluetooth.discovering ? "Discovering on" : "Discovering off";
                        }
                        color: Colors.current.on_secondary_container
                        font.family: Theme.font.style.inter
                        font.pointSize: Theme.font.size.regular
                        opacity: container.expanded ? 1.0 : 0.0
                    }
                }
            }

            Rectangle {
                id: network
                implicitHeight: Math.max(networkIcon.implicitHeight, networkText.implicitHeight)
                Layout.fillWidth: true
                Layout.minimumWidth: container.expandedWidth
                color: "transparent"
                RowLayout {
                    spacing: 10
                    MaterialSymbol {
                        id: networkIcon
                        icon: Network.active ? root.getNetworkIcon(Network.active.strength ?? 0) : "signal_wifi_off"
                        fontColor: networkMouseArea.containsMouse ? Colors.current.primary : Colors.current.on_secondary_container
                        iconSize: 15
                        animated: true
                        Process {
                            id: launchGnomeControlCenter
                            command: ["sh", "-c", "XDG_CURRENT_DESKTOP=gnome gnome-control-center network"]
                            running: false
                        }

                        MouseArea {
                            id: networkMouseArea
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onPressed: {
                                launchGnomeControlCenter.running = true;
                            }
                        }
                    }
                    Text {
                        id: networkText
                        text: Network.active ? `SSID: ${Network.active?.ssid?.slice(0, 8) || ""}...` : "Disconnected"
                        color: Colors.current.on_secondary_container
                        font.family: Theme.font.style.inter
                        font.pointSize: Theme.font.size.regular
                        opacity: container.expanded ? 1.0 : 0.0
                    }
                }
            }
        }
    }
}
