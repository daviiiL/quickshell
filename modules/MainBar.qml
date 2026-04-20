pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import qs.common
import qs.services
import qs.modules.mainbar

Scope {
    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: root
            required property var modelData
            screen: modelData

            WlrLayershell.layer: WlrLayer.Top
            WlrLayershell.namespace: "quickshell:mainbar"

            anchors {
                bottom: true
                left: true
                right: true
            }

            implicitHeight: Theme.ui.mainBarHeight
            exclusiveZone: Preferences.focusedMode ? 0 : implicitHeight
            visible: !Preferences.focusedMode

            color: "transparent"

            Rectangle {
                anchors.fill: parent
                color: Colors.barBg

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
                    width: 220
                    height: Theme.ui.mainBarHairWidth
                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop { position: 0.0; color: Qt.alpha(Colors.barAccent, 0.55) }
                        GradientStop { position: 1.0; color: "transparent" }
                    }
                }

                RowLayout {
                    anchors.fill: parent
                    spacing: 0

                    RowLayout {
                        spacing: 0
                        Layout.fillHeight: true

                        RowLayout {
                            spacing: 10
                            Layout.leftMargin: Theme.ui.mainBarSubGroupPadX
                            Layout.rightMargin: Theme.ui.mainBarSubGroupPadX

                            LiveDot {
                                pulseColor: syncProc.running ? Colors.busy : Colors.live
                            }

                            ClockView {
                                syncing: syncProc.running
                                onActivated: syncProc.running = true
                            }
                        }

                        Rectangle { width: Theme.ui.mainBarHairWidth; Layout.fillHeight: true; color: Colors.hair }

                        RowLayout {
                            spacing: 0
                            Layout.leftMargin: Theme.ui.mainBarSubGroupPadX
                            Layout.rightMargin: Theme.ui.mainBarSubGroupPadX
                            Workspaces { screen: root.screen }
                        }

                        Rectangle { width: Theme.ui.mainBarHairWidth; Layout.fillHeight: true; color: Colors.hair }

                        RowLayout {
                            spacing: 0
                            Layout.leftMargin: Theme.ui.mainBarSubGroupPadX
                            Layout.rightMargin: Theme.ui.mainBarSubGroupPadX
                            Dock {}
                        }
                    }

                    Item { Layout.fillWidth: true; Layout.fillHeight: true }

                    RowLayout {
                        spacing: 0
                        Layout.fillHeight: true

                        Rectangle { width: Theme.ui.mainBarHairWidth; Layout.fillHeight: true; color: Colors.hair }

                        RowLayout {
                            spacing: 0
                            Layout.leftMargin: Theme.ui.mainBarSubGroupPadX
                            Layout.rightMargin: Theme.ui.mainBarSubGroupPadX
                            NetworkButton { screen: root.screen }
                        }

                        Rectangle { width: Theme.ui.mainBarHairWidth; Layout.fillHeight: true; color: Colors.hair }

                        RowLayout {
                            spacing: 0
                            Layout.leftMargin: Theme.ui.mainBarSubGroupPadX
                            Layout.rightMargin: Theme.ui.mainBarSubGroupPadX

                            BrightnessButton  {}
                            VolumeButton      {}
                        }

                        Rectangle { width: Theme.ui.mainBarHairWidth; Layout.fillHeight: true; color: Colors.hair }

                        RowLayout {
                            spacing: 0
                            Layout.leftMargin: Theme.ui.mainBarSubGroupPadX
                            Layout.rightMargin: Theme.ui.mainBarSubGroupPadX
                            BatteryButton {}
                        }

                        Rectangle { width: Theme.ui.mainBarHairWidth; Layout.fillHeight: true; color: Colors.hair }

                        RowLayout {
                            spacing: 0
                            Layout.leftMargin: Theme.ui.mainBarSubGroupPadX
                            Layout.rightMargin: Theme.ui.mainBarSubGroupPadX
                            NotificationButton {}
                        }
                    }
                }
            }

            Process {
                id: syncProc
                command: ["sh", "-c", `tz=$(curl -s --max-time 5 https://ipapi.co/timezone) && [ -n "$tz" ] && timedatectl set-timezone "$tz"`]
                onExited: exitCode => {
                    if (exitCode === 0) DateTime.refresh();
                }
            }
        }
    }
}
