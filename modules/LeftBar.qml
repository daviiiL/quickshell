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

            Component.onCompleted: {
                scope.instantiated(true);
            }

            visible: !GlobalStates.powerPanelOpen

            screen: modelData
            color: Colors.surface_light_translucent

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
                color: Colors.surface_light_translucent
                radius: Theme.ui.radius.md

                anchors.margins: Theme.ui.padding.sm / 2

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
                        Layout.leftMargin: Theme.ui.padding.md
                        Layout.rightMargin: Theme.ui.padding.md

                        Text {
                            text: "SYS"
                            color: Colors.secondary
                            font {
                                family: Theme.font.family.inter_bold
                            }
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        Text {
                            text: "V1"
                            color: Colors.secondary
                            font {}
                        }
                    }

                    ClockCard {
                        Layout.leftMargin: Theme.ui.padding.sm
                        Layout.rightMargin: Theme.ui.padding.sm
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignHCenter
                    }
                    BatteryCard {
                        Layout.leftMargin: Theme.ui.padding.sm
                        Layout.rightMargin: Theme.ui.padding.sm
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignHCenter
                    }

                    SystemButtonsCard {
                        Layout.leftMargin: Theme.ui.padding.sm
                        Layout.rightMargin: Theme.ui.padding.sm
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignHCenter
                    }
                    SystemTrayCard {
                        Layout.leftMargin: Theme.ui.padding.sm
                        Layout.rightMargin: Theme.ui.padding.sm
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.alignment: Qt.AlignHCenter
                    }
                }
            }
        }
    }
}
