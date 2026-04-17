pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.common
import qs.services
import qs.widgets

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
                color: Colors.surface
                focus: true

                Keys.onEscapePressed: GlobalStates.leftPanelOpen = false

                transform: Translate {
                    id: slideT
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

                StyledText {
                    anchors.centerIn: parent
                    text: "Left Panel"
                }
            }
        }
    }
}
