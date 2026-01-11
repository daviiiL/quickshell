pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import qs.common
import qs.components.notification

Scope {
    id: root

    property int animationDuration: 200
    property int panelWidth: 400
    property int panelHeight: 600

    property bool panelActuallyVisible: false

    Timer {
        id: closeDelayTimer
        interval: 200 // Match animation duration
        repeat: false
        running: false
        onTriggered: {
            root.panelActuallyVisible = false;
        }
    }

    IpcHandler {
        target: "notifcenter"

        function toggle() {
            GlobalStates.notificationCenterOpen = !GlobalStates.notificationCenterOpen;

            if (GlobalStates.notificationCenterOpen) {
                // Opening: show panel immediately, opacity will animate 0→1
                root.panelActuallyVisible = true;
                closeDelayTimer.stop();
            } else {
                // Closing: opacity animates 1→0, then hide panel after delay
                closeDelayTimer.restart();
            }
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: panel
            required property var modelData

            screen: modelData
            visible: root.panelActuallyVisible

            anchors {
                left: true
                top: true
                bottom: true
            }

            margins {
                top: Theme.ui.padding.sm
                // left: Theme.ui.padding.sm
                bottom: Theme.ui.padding.sm
            }

            implicitWidth: root.panelWidth
            color: "transparent"

            WlrLayershell.layer: WlrLayer.Top
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
            WlrLayershell.namespace: "quickshell:notificationcenter"

            exclusiveZone: 0

            Rectangle {
                id: contentRect
                anchors.fill: parent
                radius: Theme.ui.radius.md
                color: Colors.surface_container_low
                clip: true

                transform: Translate {
                    x: GlobalStates.notificationCenterOpen ? 0 : -root.panelWidth

                    Behavior on x {
                        NumberAnimation {
                            duration: 200
                            easing.type: Easing.OutCubic
                        }
                    }
                }

                border {
                    width: 1
                    color: Colors.outline_variant
                }

                NotificationCenterView {
                    anchors.fill: parent
                }
            }
        }
    }
}
