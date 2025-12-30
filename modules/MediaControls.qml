pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Io
import qs.common
import qs.components
import qs.services
import qs.widgets

Scope {
    id: root

    property var players: SystemMpris.players

    Loader {
        id: mediaControlsLoader
        active: GlobalStates.mediaControlsOpen

        onActiveChanged: {
            if (!mediaControlsLoader.active && root.players.length === 0) {
                GlobalStates.mediaControlsOpen = false;
            }
        }

        sourceComponent: PanelWindow {
            id: mediaControlsRoot
            visible: true

            WlrLayershell.namespace: "quickshell:mediaControls"
            WlrLayershell.layer: WlrLayer.Top

            screen: Quickshell.screens[0]
            color: "transparent"

            implicitWidth: 400
            implicitHeight: playerColumn.implicitHeight
            anchors {
                top: true
                left: true
            }

            margins {
                top: GlobalStates.mediaControlsY
                left: GlobalStates.mediaControlsX
            }

            HyprlandFocusGrab {
                windows: [mediaControlsRoot]
                active: mediaControlsLoader.active
                onCleared: () => {
                    GlobalStates.mediaControlsOpen = false;
                }
            }

            ColumnLayout {
                id: playerColumn
                anchors.fill: parent
                spacing: Theme.ui.padding.sm

                Repeater {
                    model: root.players
                    delegate: PlayerControl {
                        id: playerControl
                        required property var modelData
                        player: modelData
                        Layout.fillWidth: true
                        implicitHeight: 200
                    }
                }

                Item {
                    visible: root.players.length === 0
                    Layout.fillWidth: true
                    implicitHeight: placeholderRect.implicitHeight

                    Rectangle {
                        id: placeholderRect
                        anchors.centerIn: parent
                        color: Colors.surface_container
                        radius: Theme.ui.radius.lg
                        implicitWidth: 360
                        implicitHeight: placeholderLayout.implicitHeight + Theme.ui.padding.lg * 2

                        ColumnLayout {
                            id: placeholderLayout
                            anchors.centerIn: parent
                            spacing: Theme.ui.padding.sm

                            StyledText {
                                Layout.alignment: Qt.AlignHCenter
                                text: "No active player"
                                font.pixelSize: Theme.font.size.lg
                                font.weight: Font.Medium
                                color: Colors.on_surface
                            }

                            StyledText {
                                Layout.alignment: Qt.AlignHCenter
                                color: Colors.on_surface_variant
                                text: "Make sure your player has MPRIS support"
                                font.pixelSize: Theme.font.size.sm
                            }
                        }
                    }
                }
            }
        }
    }

    IpcHandler {
        target: "mediaControls"

        function toggle(): void {
            GlobalStates.mediaControlsOpen = !GlobalStates.mediaControlsOpen;
        }

        function close(): void {
            GlobalStates.mediaControlsOpen = false;
        }

        function open(): void {
            GlobalStates.mediaControlsOpen = true;
        }
    }
}
