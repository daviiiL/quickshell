pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.common
import qs.services
import qs.modules.cliphist

Scope {
    id: root

    IpcHandler {
        target: "cliphist"

        function toggle(): void {
            if (GlobalStates.cliphistOverlayOpen) {
                GlobalStates.cliphistOverlayOpen = false;
            } else {
                Cliphist.refresh();
                GlobalStates.cliphistOverlayOpen = true;
            }
        }

        function open(): void {
            Cliphist.refresh();
            GlobalStates.cliphistOverlayOpen = true;
        }

        function close(): void {
            GlobalStates.cliphistOverlayOpen = false;
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: panel
            required property var modelData

            screen: modelData
            visible: GlobalStates.cliphistOverlayOpen

            anchors { top: true; left: true; right: true; bottom: true }
            margins { top: 0; bottom: 0; left: 0; right: 0 }

            exclusiveZone: -1

            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
            WlrLayershell.namespace: "quickshell:cliphist"

            color: "transparent"

            function closeCliphist() {
                GlobalStates.cliphistOverlayOpen = false;
            }

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                onPressed: panel.closeCliphist()
            }

            Rectangle {
                id: scrim
                anchors.fill: parent
                color: "#00000059"
                layer.enabled: true
                layer.effect: MultiEffect {
                    blurEnabled: true
                    blur: 0.6
                    blurMax: 16
                }
            }

            Rectangle {
                id: card

                width: 880
                implicitHeight: Math.min(
                    cardColumn.implicitHeight,
                    Math.round(panel.height * 0.7)
                )

                anchors.top: parent.top
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.topMargin: Math.round(panel.height * 0.16)

                color: Colors.panelBg
                radius: Theme.ui.radius.md
                border.width: 1
                border.color: Colors.hair
                clip: true

                scale: panel.visible ? 1 : 0.96
                opacity: panel.visible ? 1 : 0

                transform: Translate {
                    y: panel.visible ? 0 : -12

                    Behavior on y {
                        NumberAnimation {
                            duration: Theme.anim.durations.xs * 1.5
                            easing.type: Easing.OutCubic
                        }
                    }
                }

                Behavior on scale {
                    NumberAnimation {
                        duration: Theme.anim.durations.xs * 1.5
                        easing.type: Easing.OutCubic
                    }
                }

                Behavior on opacity {
                    NumberAnimation {
                        duration: Theme.anim.durations.xs * 1.2
                        easing.type: Easing.OutQuad
                    }
                }

                Behavior on implicitHeight {
                    NumberAnimation {
                        duration: Theme.anim.durations.xs * 1.8
                        easing.type: Easing.OutCubic
                    }
                }

                Rectangle {
                    anchors.left: parent.left
                    anchors.top: parent.top
                    width: 180
                    height: 1
                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop { position: 0.0; color: Colors.hairCatch }
                        GradientStop { position: 1.0; color: "transparent" }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: false
                    acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                }

                CliphistContent {
                    id: cardColumn
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    height: parent.height

                    onCloseRequested: panel.closeCliphist()
                }
            }

            Connections {
                target: Cliphist
                function onPicked(id) {
                    panel.closeCliphist();
                }
                function onEntriesChanged() {
                    if (panel.visible
                        && Cliphist.entries.length === 0
                        && Cliphist.query.length === 0
                        && Cliphist.available) {
                        panel.closeCliphist();
                    }
                }
            }

            onVisibleChanged: {
                if (visible) {
                    Qt.callLater(() => cardColumn.focusSearch());
                } else {
                    cardColumn.searchField.text = "";
                    Cliphist.query = "";
                    cardColumn.resultsList.currentIndex = 0;
                }
            }
        }
    }
}
