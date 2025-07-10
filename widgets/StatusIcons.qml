pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Qt5Compat.GraphicalEffects
import Quickshell.Io
import "../components/"
import "../utils/"

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

    // ShaderEffectSource {
    //     id: backgroundSource
    //     sourceItem: parent
    //     anchors.fill: container
    //     sourceRect: Qt.rect(container.x, container.y, container.width, container.height)
    //     visible: false
    //     live: true
    //     recursive: false
    // }

    // MultiEffect {
    //     source: backgroundSource
    //     anchors.fill: container
    //     blurEnabled: true
    //     blur: 1.0
    //     blurMax: 64
    //     autoPaddingEnabled: false
    //     paddingRect: Qt.rect(0, 0, 0, 0)
    // }

    ExpandingContainer {
        id: container
        anchors.leftMargin: 6
        collapsedWidth: Theme.bar.width - 12
        expandedWidth: Theme.bar.width * 4 - 12
        anchors.left: parent.left
        animationDuration: 100
        antialiasing: true

        // function addAlphaToHex(hexColor, alpha) {
        //     // Remove leading '#' if present
        //     var nhexColor = hexColor.toString().replace("#", "");
        //     var r = nhexColor.substring(0, 2);
        //     var g = nhexColor.substring(2, 4);
        //     var b = nhexColor.substring(4, 6);
        //     var a = Math.round(alpha * 255).toString(16).padStart(2, "0").toUpperCase();
        //     console.log(a + r + g + b);
        //     return "#" + a + r + g + b;
        // }

        // color: addAlphaToHex(Colors.current.secondary_container, 0.5)

        implicitHeight: 80

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: (container.collapsedWidth - Math.max(networkIcon.implicitWidth, bluetoothIcon.implicitWidth)) / 2

            Rectangle {
                id: bluetooth
                implicitHeight: Math.max(bluetoothIcon.implicitHeight, bluetoothText.implicitHeight)
                Layout.fillWidth: true
                Layout.minimumWidth: container.expandedWidth
                // color: btHoverHandler.hovered ? "white" : "transparent"

                // HoverHandler {
                //     id: btHoverHandler
                //     blocking: false
                // }
                color: "transparent"

                RowLayout {
                    spacing: 10
                    MaterialSymbol {
                        id: bluetoothIcon
                        icon: Bluetooth.powered ? "bluetooth" : "bluetooth_disabled"
                        fontColor: Colors.current.on_secondary_container
                        iconSize: 15
                        animated: true

                        Process {
                            id: launchBlueberry
                            command: ["sh", "-c", "blueberry"]
                            running: false
                            // onExited: {
                            //     console.log(`launchBlueberry terminated`);
                            // }
                        }

                        TapHandler {
                            onTapped: {
                                launchBlueberry.running = true;
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            // hoverEnabled: true
                            // propagateComposedEvents: true

                            cursorShape: Qt.PointingHandCursor
                            // onEntered: {
                            //     console.log("entered child");
                            //     container.mouseArea.entered();
                            // }
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
                            id: launchSomething
                            command: ["sh", "-c", "blueberry"]
                            running: false
                        }

                        MouseArea {
                            id: networkMouseArea
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            // hoverEnabled: true
                            // propagateComposedEvents: true
                            onPressed: {
                                launchSomething.running = true;
                            }
                        }
                    }
                    Text {
                        id: networkText
                        text: Network.active ? `󰌘 SSID: ${Network.active?.ssid?.slice(0, 8) || ""}...` : "Disconnected"
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
