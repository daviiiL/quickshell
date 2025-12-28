pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell

import qs.common
import qs.services
import qs.widgets

Rectangle {
    id: root

    property bool showChildren: Network.wifiEnabled

    color: "transparent"

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.ui.padding.lg

        spacing: Theme.ui.padding.lg

        NetworkPanelSection {
            title: "Ethernet"
            checked: Network.ethernetConnected
            onToggled: Network.toggleEthernet
            showConnectionCard: Network.ethernetConnected
            connectionIcon: "lan"
            connectionTitle: Network.ethernetDevice
            connectionSubtitle: Network.ethernetSpeed ? `Connected • ${Network.ethernetSpeed}` : "Connected"
        }

        NetworkPanelSection {
            topMargin: Network.ethernetDevice.length > 0 ? Theme.ui.padding.lg : 0
            title: "Wi-Fi"
            checked: Network.wifiEnabled
            onToggled: Network.toggleWifi
            showConnectionCard: Network.active && Network.wifiEnabled && Network.networkName !== "lo"
            connectionIcon: "signal_wifi_4_bar"
            connectionTitle: Network.networkName
            connectionSubtitle: "Connected"

            ColumnLayout {
                Layout.fillWidth: true
                Layout.topMargin: Theme.ui.padding.md
                visible: Network.knownNetworks.length > 0 && Network.wifiEnabled
                spacing: Theme.ui.padding.sm

                Text {
                    text: "Known Networks"
                    font {
                        pixelSize: Theme.font.size.lg
                        family: Theme.font.family.inter_medium
                        weight: Font.Medium
                    }
                    color: Colors.on_surface
                }

                Repeater {
                    model: Network.knownNetworks

                    delegate: KnownNetworkItem {
                        required property string modelData
                        Layout.fillWidth: true
                        networkName: modelData
                    }
                }
            }

            // available networks
            RowLayout {
                visible: root.showChildren
                Layout.fillWidth: true
                Layout.topMargin: Theme.ui.padding.md

                Text {
                    text: "Available Networks"
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
                        rotation: Network.wifiScanning ? 360 : 0

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
                        onClicked: Network.rescanWifi()
                    }
                }
            }

            ScrollView {
                visible: root.showChildren
                Layout.fillHeight: true
                Layout.fillWidth: true
                clip: true

                ListView {
                    id: networksListView
                    spacing: Theme.ui.padding.sm

                    model: ScriptModel {
                        values: Network.friendlyWifiNetworks
                    }

                    delegate: WifiNetworkItem {
                        required property var modelData
                        width: networksListView.width
                        network: modelData
                    }
                }
            }

            Item {
                visible: Network.networkName === "lo"
                Layout.fillHeight: true
            }
        }
    }
}
