import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import qs.common
import qs.components.statusbar

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
