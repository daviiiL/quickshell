pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.common
import qs.components

Scope {
    id: scope
    signal instantiated(leftBarInstantiated: bool)
    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: root
            required property var modelData
            property color bgColor: Qt.rgba(Colors.surface_light.r, Colors.surface_light.g, Colors.surface_light.b, 0.9)

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

                color: root.bgColor

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
