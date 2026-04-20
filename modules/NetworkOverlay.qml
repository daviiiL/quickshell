pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.common
import qs.services
import qs.modules.networkoverlay

Scope {
    id: scope

    Timer {
        id: closeTimer
        interval: Theme.anim.durations.sm + 50
        onTriggered: panelLoader.active = false
    }

    Connections {
        target: GlobalStates
        function onNetworkOverlayOpenChanged() {
            if (GlobalStates.networkOverlayOpen) {
                closeTimer.stop();
                panelLoader.active = true;
                if (Network.wifiEnabled) Network.rescanWifi();
            } else if (panelLoader.active) {
                closeTimer.restart();
            }
        }
    }

    Loader {
        id: panelLoader
        active: false

        sourceComponent: PanelWindow {
            id: root
            visible: true

            property bool shown: false
            Component.onCompleted: shown = Qt.binding(() => GlobalStates.networkOverlayOpen)

            screen: {
                const name = GlobalStates.networkOverlayScreen;
                const screens = Quickshell.screens;
                for (let i = 0; i < screens.length; i++) {
                    if (screens[i].name === name) return screens[i];
                }
                return screens[0];
            }

            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.namespace: "quickshell:networkoverlay"
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

            anchors { top: true; bottom: true; left: true; right: true }

            exclusiveZone: -1
            color: "transparent"

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                onPressed: GlobalStates.networkOverlayOpen = false
            }

            FocusScope {
                anchors.fill: parent
                focus: root.shown

                Keys.onEscapePressed: GlobalStates.networkOverlayOpen = false

                Rectangle {
                    id: popup
                    width: 300
                    height: Math.min(440, root.height - Theme.ui.mainBarHeight - 24)

                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: Theme.ui.mainBarHeight

                    x: {
                        const screenX = root.screen?.x ?? 0;
                        const centerX = GlobalStates.networkButtonCenters[root.screen?.name] ?? (screenX + root.width / 2);
                        return Math.max(8, Math.min(root.width - width - 8, centerX - screenX - width / 2));
                    }

                    color: Colors.panelBg
                    radius: 4
                    border.color: Colors.hair
                    border.width: Theme.ui.mainBarHairWidth

                    opacity: root.shown ? 1 : 0
                    Behavior on opacity {
                        NumberAnimation {
                            duration: Theme.anim.durations.xs
                            easing.type: Easing.BezierSpline
                            easing.bezierCurve: Theme.anim.curves.standard
                        }
                    }

                    transform: Translate {
                        id: slideT
                        y: root.shown ? 0 : 16
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
                        anchors.fill: parent
                    }
                }
            }
        }
    }
}
