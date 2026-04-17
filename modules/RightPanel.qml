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
        target: "rightpanel"

        function toggle(): void {
            GlobalStates.rightPanelOpen = !GlobalStates.rightPanelOpen;
        }

        function open(): void {
            GlobalStates.rightPanelOpen = true;
        }

        function close(): void {
            GlobalStates.rightPanelOpen = false;
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
                color: Colors.surface
                focus: true

                Keys.onEscapePressed: GlobalStates.rightPanelOpen = false

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

                StyledText {
                    anchors.centerIn: parent
                    text: "Right Panel"
                }
            }
        }
    }
}
