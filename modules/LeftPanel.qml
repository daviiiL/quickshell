pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.common
import qs.services
import qs.widgets
import qs.modules.leftpanel

Scope {
    IpcHandler {
        target: "leftpanel"

        function toggle(): void {
            GlobalStates.leftPanelOpen = !GlobalStates.leftPanelOpen;
        }

        function open(): void {
            GlobalStates.leftPanelOpen = true;
        }

        function close(): void {
            GlobalStates.leftPanelOpen = false;
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: root
            required property var modelData
            screen: modelData

            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.namespace: "quickshell:leftpanel"
            WlrLayershell.keyboardFocus: GlobalStates.leftPanelOpen ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

            anchors {
                top: true
                bottom: true
                left: true
            }

            implicitWidth: Theme.ui.sidePanelWidth
            exclusiveZone: 0
            visible: GlobalStates.leftPanelOpen || slideAnim.running

            color: "transparent"

            Rectangle {
                id: panelSurface
                anchors.fill: parent
                color: Colors.panelBg
                focus: true

                Keys.onEscapePressed: GlobalStates.leftPanelOpen = false

                transform: Translate {
                    x: GlobalStates.leftPanelOpen ? 0 : -Theme.ui.sidePanelWidth

                    Behavior on x {
                        NumberAnimation {
                            id: slideAnim
                            duration: Theme.anim.durations.sm
                            easing.type: Easing.BezierSpline
                            easing.bezierCurve: Theme.anim.curves.standard
                        }
                    }
                }

                GeminiChat {
                    anchors.fill: parent
                }

                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    height: Theme.ui.mainBarHairWidth
                    color: Colors.hair
                }
                Rectangle {
                    anchors.right: parent.right
                    anchors.top: parent.top
                    width: 180
                    height: Theme.ui.mainBarHairWidth
                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop { position: 0.0; color: "transparent" }
                        GradientStop { position: 1.0; color: Qt.alpha(Colors.barAccent, 0.55) }
                    }
                }
                Rectangle {
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: Theme.ui.mainBarHairWidth
                    color: Colors.hair
                }
            }
        }
    }
}
