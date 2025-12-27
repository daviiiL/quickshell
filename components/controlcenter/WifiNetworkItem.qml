pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import qs.common
import qs.services
import qs.widgets

Rectangle {
    id: wifiItem
    required property var network
    height: network?.askingPassword ? 160 : 60
    radius: Theme.ui.radius.md
    color: wifiMouseArea.containsMouse || network?.askingPassword ? Colors.surface_container_high : Colors.surface_container

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
                    const strength = wifiItem.network?.strength ?? 0;
                    return strength > 80 ? "signal_wifi_4_bar" : strength > 60 ? "network_wifi_3_bar" : strength > 40 ? "network_wifi_2_bar" : strength > 20 ? "network_wifi_1_bar" : "signal_wifi_0_bar";
                }
                fontColor: Colors.on_surface_variant
                iconSize: Theme.font.size.xl
            }

            ColumnLayout {
                Layout.fillHeight: true
                Layout.fillWidth: true
                spacing: 2

                Text {
                    text: wifiItem.network?.ssid ?? "Unknown"
                    font {
                        pixelSize: Theme.font.size.md
                        family: Theme.font.family.inter_regular
                    }
                    color: Colors.on_surface
                    elide: Text.ElideRight
                }

                Text {
                    visible: Network.wifiConnectTarget === wifiItem.network && !wifiItem.network?.askingPassword
                    text: "Connecting..."
                    font.pixelSize: Theme.font.size.xs
                    color: Colors.primary
                }
            }

            Text {
                id: wifiConnectingSpinner
                text: "progress_activity"
                visible: Network.wifiConnectTarget === wifiItem.network && !wifiItem.network?.askingPassword && !wifiItem.network?.active
                font {
                    pixelSize: Theme.font.size.lg
                    family: "Material Symbols Outlined"
                }
                color: Colors.primary

                RotationAnimator on rotation {
                    running: Network.wifiConnectTarget === wifiItem.network && !wifiItem.network?.askingPassword
                    from: 0
                    to: 360
                    duration: 1000
                    loops: Animation.Infinite
                }
            }

            Item {
                Layout.fillWidth: true
            }
            Text {
                visible: wifiItem.network?.isSecure ?? false
                text: wifiItem.network?.active ? "check" : "lock"
                font {
                    pixelSize: Theme.font.size.xl
                    family: "Material Symbols Outlined"
                }
                color: Colors.on_surface_variant
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            visible: wifiItem.network?.askingPassword ?? false
            spacing: Theme.ui.padding.sm

            TextField {
                id: passwordField
                Layout.fillWidth: true
                placeholderText: "Password"
                echoMode: TextInput.Password
                color: Colors.on_surface
                placeholderTextColor: Colors.on_surface
                background: Rectangle {
                    color: Colors.surface_container_highest
                    radius: Theme.ui.radius.sm
                    border.color: passwordField.activeFocus ? Colors.primary : Colors.outline
                    border.width: 1
                }

                onAccepted: {
                    Network.changePassword(wifiItem.network, passwordField.text);
                }
                padding: Theme.ui.padding.sm
            }

            RowLayout {
                Layout.fillWidth: true

                Item {
                    Layout.fillWidth: true
                }

                Rectangle {
                    Layout.preferredWidth: 70
                    Layout.preferredHeight: 32
                    radius: Theme.ui.radius.sm
                    color: cancelBtnMouseArea.containsMouse ? Colors.surface_container_highest : Colors.surface_container_high

                    Text {
                        anchors.centerIn: parent
                        text: "Cancel"
                        font.pixelSize: Theme.font.size.sm
                        color: Colors.on_surface
                    }

                    MouseArea {
                        id: cancelBtnMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: wifiItem.network.askingPassword = false
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
                            Network.changePassword(wifiItem.network, passwordField.text);
                        }
                    }
                }
            }
        }
    }

    MouseArea {
        id: wifiMouseArea
        anchors.fill: parent
        hoverEnabled: true
        enabled: !(wifiItem.network?.askingPassword ?? false)
        onClicked: {
            if (!wifiItem.network?.active) {
                Network.connectToWifiNetwork(wifiItem.network);
            }
        }
    }
}
