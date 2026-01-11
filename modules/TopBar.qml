pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell

import Quickshell.Wayland
import qs.common
import qs.components.topbar

Scope {

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: root

            WlrLayershell.layer: WlrLayer.Top
            WlrLayershell.namespace: "quickshell:topbar"
            WlrLayershell.exclusiveZone: implicitHeight

            required property var modelData
            property color bgColor: Colors.background
            screen: modelData

            visible: true
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

                color: root.bgColor
                opacity: GlobalStates.powerPanelOpen ? 0 : 1
                radius: Theme.ui.radius.md

                RowLayout {
                    anchors.fill: parent
                    spacing: Theme.ui.padding.md

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
