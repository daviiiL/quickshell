import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Services.SystemTray
import QtQuick
import QtQuick.Layouts
import "../components"
import "../components/notification"
import "../components/widgets"
import "../components/tray"
import "../components/statusbar"
import "../common"

Scope {
    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: statusBar

            property var modelData
            property bool statusIconsExpanded: false
            property bool powerIndicatorExpanded: false

            screen: modelData

            anchors {
                left: true
                right: true
                bottom: true
            }

            color: "transparent"
            implicitWidth: screen.width
            implicitHeight: Theme.statusbar.height
            WlrLayershell.layer: WlrLayer.Top
            // WlrLayershell.exclusiveZone: Theme.bar.width

            Rectangle {

                anchors.fill: parent
                color: Colors.current.background

                RowLayout {
                    anchors.fill: parent
                    spacing: 0

                    WindowIndicator {
                        id: windowIndicator
                        Layout.fillHeight: true
                    }

                    // Spacer to push sensors to the right
                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                    }

                    SensorIndicator {
                        id: sensorIndicator
                        Layout.fillHeight: true
                    }
                }
            }
        }
    }
}
