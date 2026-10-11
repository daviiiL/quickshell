pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.common
import qs.services
import qs.modules.wallpaperpicker

Scope {
    id: root

    property string requestedDir: ""

    IpcHandler {
        target: "wallpaperpicker"

        function toggle(): void {
            if (GlobalStates.wallpaperPickerOpen) GlobalStates.closeWallpaperPicker();
            else GlobalStates.openWallpaperPicker("ipc");
        }

        function open(): void {
            GlobalStates.openWallpaperPicker("ipc");
        }

        function close(): void {
            GlobalStates.closeWallpaperPicker();
        }

        function openAt(dir: string): void {
            root.requestedDir = dir;
            GlobalStates.openWallpaperPicker("ipc");
        }
    }

    Connections {
        target: GlobalStates
        function onWallpaperPickerOpenChanged(): void {
            if (!GlobalStates.wallpaperPickerOpen)
                root.requestedDir = "";
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: panel
            required property var modelData
            screen: modelData

            readonly property bool isFocusedScreen: SystemNiri.focusedOutput === "" || modelData.name === SystemNiri.focusedOutput
            readonly property bool shouldShow: GlobalStates.wallpaperPickerOpen && isFocusedScreen

            Component.onCompleted: console.log("[WallpaperPicker.window on " + modelData.name + "] spawned")

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
            WlrLayershell.namespace: "quickshell:wallpaperpicker"

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
                    onPressed: GlobalStates.closeWallpaperPicker()
                }
            }

            Rectangle {
                id: surface
                width: 960
                height: 640
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

                // Swallows clicks so they do not reach the backdrop's close MouseArea.
                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                }

                Loader {
                    id: contentLoader
                    anchors.fill: parent
                    active: panel.shouldShow
                    focus: true

                    sourceComponent: Component {
                        PickerContent {
                            anchors.fill: parent
                            focus: true
                            requestedDir: root.requestedDir
                            onCloseRequested: GlobalStates.closeWallpaperPicker()
                        }
                    }
                }
            }

            onShouldShowChanged: {
                if (shouldShow) Qt.callLater(() => { if (contentLoader.item) contentLoader.item.forceActiveFocus(); });
            }
        }
    }
}
