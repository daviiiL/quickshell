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
            property color bgColor: Preferences.darkMode ? "black" : Qt.rgba(Colors.surface.r, Colors.surface.g, Colors.surface.b, 0.9)

            WlrLayershell.namespace: "quickshell:topbar"

            screen: modelData
            color: "transparent"

            implicitHeight: Theme.ui.topBarHeight

            WlrLayershell.layer: WlrLayer.Top
            WlrLayershell.exclusiveZone: implicitHeight

            anchors {
                right: true
                left: true
                top: true
            }

            visible: !GlobalStates.powerPanelOpen

            Rectangle {
                anchors.fill: parent
                radius: Theme.ui.radius.md

                anchors.margins: Theme.ui.padding.sm / 2

                color: root.bgColor

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
