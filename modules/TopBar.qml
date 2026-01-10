import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.common
import qs.components
import qs.services

Scope {

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: root

            required property var modelData
            property color bgColor: Preferences.darkMode ? Colors.background : Qt.rgba(Colors.surface.r, Colors.surface.g, Colors.surface.b, 0.9)

            WlrLayershell.namespace: "quickshell:topbar"

            screen: modelData
            color: GlobalStates.powerPanelOpen ? Colors.background : "transparent"

            Behavior on color {
                ColorAnimation {
                    duration: 150
                    easing.type: Easing.OutCubic
                }
            }

            implicitHeight: Theme.ui.topBarHeight

            WlrLayershell.layer: WlrLayer.Top
            WlrLayershell.exclusiveZone: implicitHeight

            anchors {
                right: true
                left: true
                top: true
            }

            visible: true

            Rectangle {
                anchors.fill: parent
                radius: Theme.ui.radius.md

                anchors.margins: Theme.ui.padding.sm
                anchors.bottomMargin: 0

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

                RowLayout {
                    anchors.fill: parent
                    spacing: Theme.ui.padding.md

                    Workspaces {
                        Layout.preferredHeight: parent.height - Theme.ui.padding.sm
                        Layout.leftMargin: Theme.ui.padding.sm
                        Layout.alignment: Qt.AlignVCenter
                        screen: root.screen
                    }

                    TopBarMprisControl {
                        id: mpris
                    }

                    TopBarOsd {}

                    SystemStatusCard {
                        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                    }

                    PowerButton {}
                }
            }
        }
    }
}
