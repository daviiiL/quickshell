pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Qt5Compat.GraphicalEffects
import Quickshell.Wayland
import qs.common
import qs.components
import qs.services

Scope {
    id: scope
    signal instantiated(leftBarInstantiated: bool)
    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: root
            required property var modelData
            property color bgColor: Preferences.focusedMode ? "transparent" : Qt.alpha(Colors.surface_light, 0.9)

            Component.onCompleted: {
                scope.instantiated(true);
            }

            visible: !GlobalStates.powerPanelOpen

            screen: modelData
            color: GlobalStates.powerPanelOpen ? Colors.background : "transparent"

            Behavior on color {
                ColorAnimation {
                    duration: 150
                    easing.type: Easing.OutCubic
                }
            }

            implicitWidth: Theme.ui.leftBarWidth

            WlrLayershell.layer: WlrLayer.Top
            WlrLayershell.exclusiveZone: implicitWidth

            anchors {
                left: true
                top: true
                bottom: true
            }

            Rectangle {
                anchors.fill: parent
                opacity: GlobalStates.powerPanelOpen ? 0 : 1
                clip: true
                radius: Preferences.focusedMode ? 2 : 0

                border {
                    width: Preferences.focusedMode ? 1 : 0
                    color: Preferences.focusedMode ? Qt.alpha(Colors.primary, 0.5) : Colors.outline
                }

                color: root.bgColor

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

                ColumnLayout {
                    anchors {
                        topMargin: Theme.ui.padding.sm
                        bottomMargin: Theme.ui.padding.sm
                    }
                    anchors.fill: parent
                    spacing: 5
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 15
                        Layout.leftMargin: Theme.ui.padding.sm
                        Layout.rightMargin: Theme.ui.padding.sm

                        Text {
                            text: "SYS"
                            color: Colors.secondary
                            font {
                                family: Theme.font.family.inter_bold
                                weight: Font.Bold
                            }
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        Text {
                            text: "V2"
                            color: Colors.secondary
                            font {}
                        }
                    }

                    ClockCard {
                        Layout.leftMargin: Theme.ui.padding.xs
                        Layout.rightMargin: Theme.ui.padding.xs
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignHCenter
                    }
                    BatteryCard {
                        Layout.leftMargin: Theme.ui.padding.xs
                        Layout.rightMargin: Theme.ui.padding.xs
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignHCenter
                    }

                    SystemButtonsCard {
                        Layout.leftMargin: Theme.ui.padding.xs
                        Layout.rightMargin: Theme.ui.padding.xs
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignHCenter
                    }
                    SystemTrayCard {
                        Layout.leftMargin: Theme.ui.padding.xs
                        Layout.rightMargin: Theme.ui.padding.xs
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.alignment: Qt.AlignHCenter
                    }
                }
            }
        }
    }
}
