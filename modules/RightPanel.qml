pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.common
import qs.services
import qs.widgets
import qs.modules.rightpanel

Scope {
    IpcHandler {
        target: "rightpanel"

        function toggle(): void {
            if (GlobalStates.rightPanelOpen) {
                GlobalStates.rightPanelOpen = false;
                GlobalStates.rightPanelSource = "";
            } else {
                GlobalStates.rightPanelSource = "ipc";
                GlobalStates.rightPanelOpen = true;
            }
        }

        function open(): void {
            GlobalStates.rightPanelSource = "ipc";
            GlobalStates.rightPanelOpen = true;
        }

        function close(): void {
            GlobalStates.rightPanelOpen = false;
            GlobalStates.rightPanelSource = "";
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: root
            required property var modelData
            screen: modelData

            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.namespace: "quickshell:rightpanel"

            anchors {
                top: true
                bottom: true
                right: true
            }

            implicitWidth: Theme.ui.sidePanelWidth
            exclusiveZone: 0
            visible: GlobalStates.rightPanelOpen || slideAnim.running

            color: "transparent"

            Rectangle {
                id: panelSurface
                anchors.fill: parent
                color: Colors.panelBg
                focus: true

                Keys.onEscapePressed: {
                    GlobalStates.rightPanelOpen = false;
                    GlobalStates.rightPanelSource = "";
                }

                transform: Translate {
                    id: slideT
                    x: GlobalStates.rightPanelOpen ? 0 : Theme.ui.sidePanelWidth

                    Behavior on x {
                        NumberAnimation {
                            id: slideAnim
                            duration: Theme.anim.durations.sm
                            easing.type: Easing.BezierSpline
                            easing.bezierCurve: Theme.anim.curves.standard
                        }
                    }
                }

                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    height: Theme.ui.mainBarHairWidth
                    color: Colors.hair
                }
                Rectangle {
                    anchors.left: parent.left
                    anchors.top: parent.top
                    width: 180
                    height: Theme.ui.mainBarHairWidth
                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop { position: 0.0; color: Qt.alpha(Colors.barAccent, 0.55) }
                        GradientStop { position: 1.0; color: "transparent" }
                    }
                }
                Rectangle {
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: Theme.ui.mainBarHairWidth
                    color: Colors.hair
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.topMargin: Theme.ui.mainBarHairWidth
                    spacing: 0

                    Header {
                        userName: "davidas"
                        hostLabel: "niri · arch"
                    }

                    Rectangle { Layout.fillWidth: true; Layout.preferredHeight: Theme.ui.mainBarHairWidth; color: Colors.hair }

                    QuickToggles {}

                    Rectangle { Layout.fillWidth: true; Layout.preferredHeight: Theme.ui.mainBarHairWidth; color: Colors.hair }

                    BrightnessSection {}

                    Rectangle { Layout.fillWidth: true; Layout.preferredHeight: Theme.ui.mainBarHairWidth; color: Colors.hair }

                    SoundSection {}

                    Rectangle { Layout.fillWidth: true; Layout.preferredHeight: Theme.ui.mainBarHairWidth; color: Colors.hair }

                    NotificationCenter {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                    }
                }
            }
        }
    }
}
