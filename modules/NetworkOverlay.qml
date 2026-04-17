pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.common
import qs.services
import qs.modules.networkoverlay

Scope {
    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: root
            required property var modelData
            screen: modelData

            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.namespace: "quickshell:networkoverlay"

            anchors { top: true; bottom: true; left: true; right: true }

            exclusiveZone: 0
            visible: GlobalStates.networkOverlayOpen || slideAnim.running
            color: "transparent"

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                onPressed: GlobalStates.networkOverlayOpen = false
            }

            FocusScope {
                anchors.fill: parent
                focus: GlobalStates.networkOverlayOpen

                Keys.onEscapePressed: GlobalStates.networkOverlayOpen = false

                Rectangle {
                    id: popup
                    width: 300
                    height: Math.min(content.implicitHeight, root.height - Theme.ui.mainBarHeight - 24)

                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: Theme.ui.mainBarHeight + 6

                    x: {
                        const screenX = root.screen?.x ?? 0;
                        const desired = GlobalStates.networkButtonCenterX - screenX - width / 2;
                        const minX = 8;
                        const maxX = root.width - width - 8;
                        return Math.max(minX, Math.min(maxX, desired));
                    }

                    color: Colors.panelBg
                    radius: 4
                    border.color: Colors.hair
                    border.width: Theme.ui.mainBarHairWidth

                    opacity: GlobalStates.networkOverlayOpen ? 1 : 0
                    Behavior on opacity {
                        NumberAnimation {
                            duration: Theme.anim.durations.xs
                            easing.type: Easing.BezierSpline
                            easing.bezierCurve: Theme.anim.curves.standard
                        }
                    }

                    transform: Translate {
                        id: slideT
                        y: GlobalStates.networkOverlayOpen ? 0 : 16
                        Behavior on y {
                            NumberAnimation {
                                id: slideAnim
                                duration: Theme.anim.durations.sm
                                easing.type: Easing.BezierSpline
                                easing.bezierCurve: Theme.anim.curves.emphasizedDecel
                            }
                        }
                    }

                    Rectangle {
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.topMargin: 0
                        anchors.leftMargin: 0
                        width: 120
                        height: Theme.ui.mainBarHairWidth
                        gradient: Gradient {
                            orientation: Gradient.Horizontal
                            GradientStop { position: 0.0; color: Qt.alpha(Colors.barAccent, 0.55) }
                            GradientStop { position: 1.0; color: "transparent" }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                    }

                    OverlayContent {
                        id: content
                        anchors.fill: parent
                    }
                }
            }
        }
    }
}
