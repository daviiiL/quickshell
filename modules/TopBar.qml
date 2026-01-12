pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell
import Qt5Compat.GraphicalEffects

import Quickshell.Wayland
import qs.common
import qs.components.topbar
import qs.services

Scope {

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: root

            WlrLayershell.layer: WlrLayer.Top
            WlrLayershell.namespace: "quickshell:topbar"
            WlrLayershell.exclusiveZone: implicitHeight

            required property var modelData
            property color bgColor: Preferences.focusedMode ? "transparent" : Colors.background
            screen: modelData

            visible: !GlobalStates.powerPanelOpen
            color: GlobalStates.powerPanelOpen ? Colors.background : "transparent"
            implicitHeight: Theme.ui.topBarHeight

            anchors {
                right: true
                left: true
                top: true
            }

            Rectangle {
                anchors.fill: parent
                anchors.margins: Theme.ui.padding.sm
                anchors.bottomMargin: 0
                border {
                    width: Preferences.focusedMode ? 1 : 0
                    color: Preferences.focusedMode ? Qt.alpha(Colors.primary, 0.5) : Colors.outline
                }
                color: root.bgColor
                opacity: GlobalStates.powerPanelOpen ? 0 : 1
                radius: Preferences.focusedMode ? 2 : Theme.ui.radius.md
                clip: true

                Item {
                    anchors.fill: parent
                    visible: Preferences.focusedMode

                    Rectangle {
                        id: noiseTexture
                        anchors.fill: parent
                        visible: false
                        layer.enabled: true

                        Canvas {
                            anchors.fill: parent
                            onPaint: {
                                var ctx = getContext("2d");
                                var imageData = ctx.createImageData(width, height);
                                var data = imageData.data;

                                for (var i = 0; i < data.length; i += 4) {
                                    var gray = Math.random() * 50 + 100;
                                    data[i] = gray;
                                    data[i + 1] = gray;
                                    data[i + 2] = gray;
                                    data[i + 3] = 100;
                                }

                                ctx.putImageData(imageData, 0, 0);
                            }
                            Component.onCompleted: requestPaint()
                        }

                        Rectangle {
                            anchors.fill: parent
                            color: Colors.primary_container
                            opacity: 0.7
                        }
                    }

                    FastBlur {
                        anchors.fill: parent
                        source: noiseTexture
                        radius: 40
                        cached: true
                        transparentBorder: true
                    }

                    Rectangle {
                        anchors.fill: parent
                        color: Qt.alpha(Colors.surface, 0.25)
                    }
                }

                Rectangle {
                    visible: Preferences.focusedMode
                    width: 16
                    height: 1
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.topMargin: -0.5
                    anchors.leftMargin: 20
                    color: Colors.primary
                    opacity: 0.8
                }
                Rectangle {
                    visible: Preferences.focusedMode
                    width: 16
                    height: 1
                    anchors.top: parent.top
                    anchors.right: parent.right
                    anchors.topMargin: -0.5
                    anchors.rightMargin: 20
                    color: Colors.primary
                    opacity: 0.8
                }

                RowLayout {
                    anchors.fill: parent
                    spacing: Preferences.focusedMode ? Theme.ui.padding.sm : Theme.ui.padding.md

                    BarLeftSection {
                        screen: root.screen
                    }

                    BarCenterSection {}

                    BarRightSection {}
                }

                Behavior on opacity {
                    NumberAnimation {
                        duration: 150
                        easing.type: Easing.OutCubic
                    }
                }

                Behavior on color {
                    ColorAnimation {
                        duration: Theme.anim.durations.md
                    }
                }
            }

            Behavior on color {
                ColorAnimation {
                    duration: 150
                    easing.type: Easing.OutCubic
                }
            }
        }
    }

    component BarLeftSection: RowLayout {
        Layout.leftMargin: Theme.ui.padding.sm
        Layout.fillHeight: true

        property var screen

        Workspaces {
            Layout.fillHeight: true
            screen: parent.screen
        }

        MediaControlsButton {}
    }

    component BarCenterSection: RowLayout {
        Layout.fillHeight: true

        Osd {}
    }

    component BarRightSection: RowLayout {
        Layout.fillHeight: true

        SystemStatusCard {
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
        }

        PowerButton {}
    }
}
