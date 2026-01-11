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
        interval: 200
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
                root.panelActuallyVisible = true;
                closeDelayTimer.stop();
            } else {
                closeDelayTimer.restart();
            }
        }

        function close() {
            GlobalStates.notificationCenterOpen = false;
            closeDelayTimer.restart();
        }

        function open() {
            GlobalStates.notificationCenterOpen = true;
            root.panelActuallyVisible = true;
            closeDelayTimer.stop();
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
                anchors {
                    left: parent.left
                    top: parent.top
                    bottom: parent.bottom
                }

                implicitWidth: panel.implicitWidth - Theme.ui.padding.sm

                radius: Theme.ui.radius.md
                color: Colors.surface
                clip: true

                transform: Translate {
                    x: GlobalStates.notificationCenterOpen ? Theme.ui.padding.sm : -root.panelWidth

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
