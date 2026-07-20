pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.common
import qs.services
import qs.modules.controlcenter
import qs.modules.controlcenter.panes

Scope {
    id: root

    readonly property var paneRegistry: [
        { name: "quick",     label: "Quick Settings", icon: "tune",               section: "QUICK",   component: quickPaneComp },
        { name: "network",   label: "Network",        icon: "wifi",               section: "SYSTEM",  component: networkPaneComp },
        { name: "bluetooth", label: "Bluetooth",      icon: "bluetooth",          section: "SYSTEM",  component: bluetoothPaneComp },
        { name: "sound",     label: "Sound",          icon: "volume_up",          section: "SYSTEM",  component: soundPaneComp },
        { name: "display",   label: "Display",        icon: "brightness_high",    section: "SYSTEM",  component: displayPaneComp },
        { name: "battery",   label: "Battery",        icon: "battery_full",       section: "SYSTEM",  component: batteryPaneComp },
        { name: "ai",        label: "AI Assistant",   icon: "auto_awesome",       section: "SYSTEM",  component: aiPaneComp },
        { name: "session",   label: "Power",          icon: "power_settings_new", section: "SESSION", component: sessionPaneComp }
    ]

    function paneEntry(name: string): var {
        return root.paneRegistry.find(p => p.name === name) || root.paneRegistry[0];
    }

    Component { id: quickPaneComp;     QuickPane {} }
    Component { id: networkPaneComp;   NetworkPane {} }
    Component { id: bluetoothPaneComp; BluetoothPane {} }
    Component { id: soundPaneComp;     SoundPane {} }
    Component { id: displayPaneComp;   DisplayPane {} }
    Component { id: batteryPaneComp;   PlaceholderPane { paneName: "Battery" } }
    Component { id: aiPaneComp;        AiPane {} }
    Component { id: sessionPaneComp;   SessionPane {} }

    IpcHandler {
        target: "controlcenter"

        function toggle(): void {
            if (GlobalStates.controlCenterOpen) GlobalStates.closeControlCenter();
            else GlobalStates.openControlCenter("ipc");
        }

        function open(): void {
            GlobalStates.openControlCenter("ipc");
        }

        function close(): void {
            GlobalStates.closeControlCenter();
        }

        function openPane(name: string): void {
            GlobalStates.controlCenterPane = name;
            GlobalStates.openControlCenter("ipc");
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: panel
            required property var modelData
            screen: modelData

            readonly property bool isFocusedScreen: SystemNiri.focusedOutput === "" || modelData.name === SystemNiri.focusedOutput
            readonly property bool shouldShow: GlobalStates.controlCenterOpen && isFocusedScreen

            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }

            exclusiveZone: -1
            color: "transparent"

            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: panel.shouldShow ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
            WlrLayershell.namespace: "quickshell:controlcenter"

            visible: shouldShow

            Rectangle {
                id: backdrop
                anchors.fill: parent
                color: "black"
                opacity: panel.shouldShow ? 0.45 : 0

                Behavior on opacity {
                    NumberAnimation {
                        duration: Theme.anim.durations.xs * 1.2
                        easing.type: Easing.OutQuad
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                    onPressed: GlobalStates.closeControlCenter()
                }
            }

            Rectangle {
                id: surface
                width: 880
                height: 600
                anchors.centerIn: parent

                color: Colors.panelBg
                radius: Theme.ui.radius.sm
                border.width: Theme.ui.mainBarHairWidth
                border.color: Colors.hair
                clip: true

                opacity: panel.shouldShow ? 1 : 0
                scale: panel.shouldShow ? 1 : 0.97

                Behavior on opacity {
                    NumberAnimation {
                        duration: Theme.anim.durations.xs * 1.6
                        easing.type: Easing.OutCubic
                    }
                }
                Behavior on scale {
                    NumberAnimation {
                        duration: Theme.anim.durations.xs * 1.6
                        easing.type: Easing.OutCubic
                    }
                }

                Keys.onEscapePressed: GlobalStates.closeControlCenter()

                // Swallows clicks so they don't reach the backdrop's close-on-click MouseArea.
                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                }

                Loader {
                    id: contentLoader
                    anchors.fill: parent
                    active: panel.shouldShow

                    sourceComponent: Component {
                        ColumnLayout {
                            id: content
                            anchors.fill: parent
                            spacing: 0

                            readonly property var activePane: root.paneEntry(GlobalStates.controlCenterPane)

                            Header {
                                Layout.fillWidth: true
                                section: content.activePane.section
                                label:   content.activePane.label
                                onCloseRequested: GlobalStates.closeControlCenter()
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                spacing: 0

                                Sidebar {
                                    Layout.fillHeight: true
                                    panes: root.paneRegistry
                                    currentPane: GlobalStates.controlCenterPane
                                    onPaneSelected: name => GlobalStates.controlCenterPane = name
                                }

                                Loader {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    sourceComponent: content.activePane.component
                                }
                            }
                        }
                    }
                }
            }

            onShouldShowChanged: {
                if (shouldShow) surface.forceActiveFocus();
            }
        }
    }
}
