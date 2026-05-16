pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.common
import qs.services

Scope {
    id: root

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

            onVisibleChanged: console.log(`[ControlCenter.window on ${modelData.name}] ${visible ? "spawned" : "killed"}`)

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
                    active: panel.shouldShow || surface.opacity > 0

                    sourceComponent: Component {
                        Column {
                            anchors.centerIn: parent
                            spacing: 12

                            Component.onCompleted: console.log("[ControlCenter.content] loaded")
                            Component.onDestruction: console.log("[ControlCenter.content] unloaded")

                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: "Control Center"
                                color: Colors.fgSurface
                                font.family: Theme.font.family.inter_medium
                                font.pixelSize: 22
                            }

                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: "Phase 1 — scaffold + IPC. Esc or click backdrop to close."
                                color: Qt.alpha(Colors.fgSurface, 0.5)
                                font.family: Theme.font.family.inter
                                font.pixelSize: 12
                                font.letterSpacing: 0.4
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
