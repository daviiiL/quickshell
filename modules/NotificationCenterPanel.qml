pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.common
import qs.components.notification

Scope {
    id: root

    property int animationDuration: 200
    property int panelWidth: 400
    property int panelHeight: 600

    GlobalShortcut {
        name: "notificationCenterToggle"
        description: "Toggles the notification center"

        onPressed: {
            GlobalStates.notificationCenterOpen = !GlobalStates.notificationCenterOpen;
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: panel
            required property var modelData

            screen: modelData
            visible: GlobalStates.notificationCenterOpen

            anchors {
                left: true
                top: true
                bottom: true
            }

            margins {
                top: Theme.ui.padding.sm
                left: Theme.ui.padding.sm
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
                color: Colors.surface_light
                clip: true

                NotificationCenterView {
                    anchors.fill: parent
                }

                Behavior on opacity {
                    NumberAnimation {
                        duration: root.animationDuration
                        easing.type: Easing.BezierSpline
                        easing.bezierCurve: Theme.anim.curves.standard
                    }
                }
            }
        }
    }
}
