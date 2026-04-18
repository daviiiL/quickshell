pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.common
import qs.services
import qs.modules.osd

Scope {
    id: scope

    OsdController { id: controller }

    Loader {
        id: panelLoader
        active: controller.state !== "HIDDEN"

        sourceComponent: PanelWindow {
            id: win

            screen: {
                const name = SystemNiri.focusedOutput;
                const screens = Quickshell.screens;
                for (let i = 0; i < screens.length; i++) {
                    if (screens[i].name === name) return screens[i];
                }
                return screens[0] ?? null;
            }

            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.namespace: "quickshell:osd"
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

            anchors { top: true; left: true; right: true }
            implicitHeight: 36 + 24
            exclusiveZone: 0
            color: "transparent"

            Item {
                anchors.fill: parent

                OsdPill {
                    id: pill
                    channel: controller.channel

                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    anchors.topMargin: 24

                    readonly property bool shown: controller.state === "SHOWN"
                    readonly property var activeCurve: shown
                        ? Theme.anim.curves.emphasizedDecel
                        : Theme.anim.curves.standardAccel

                    opacity: shown ? 1 : 0
                    Behavior on opacity {
                        NumberAnimation {
                            duration: Theme.anim.durations.xs
                            easing.type: Easing.BezierSpline
                            easing.bezierCurve: pill.activeCurve
                        }
                    }

                    transform: Translate {
                        y: pill.shown ? 0 : -8
                        Behavior on y {
                            NumberAnimation {
                                duration: Theme.anim.durations.xs
                                easing.type: Easing.BezierSpline
                                easing.bezierCurve: pill.activeCurve
                            }
                        }
                    }
                }
            }
        }
    }
}
