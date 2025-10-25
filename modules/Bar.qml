import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Services.SystemTray
import QtQuick
import "../components/"
import "../widgets/"
import "../utils"

Scope {
    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: bar

            property var modelData
            property bool statusIconsExpanded: false
            property bool powerIndicatorExpanded: false

            screen: modelData

            anchors {
                top: true
                left: true
                bottom: true
            }

            color: "transparent"
            implicitWidth: Theme.bar.maxWidth
            implicitHeight: modelData.height
            WlrLayershell.layer: WlrLayer.Top
            WlrLayershell.exclusiveZone: Theme.bar.width

            mask: Region {
                item: Rectangle {
                    width: bar.statusIconsExpanded || bar.powerIndicatorExpanded ? Theme.bar.width * 4 : Theme.bar.width
                    height: bar.height

                    Behavior on width {
                        NumberAnimation {
                            duration: 300
                            easing.type: Easing.BezierSpline
                        }
                    }
                }
            }

            Rectangle {

                anchors {
                    top: parent.top
                    left: parent.left
                    bottom: parent.bottom
                }

                color: Colors.current.background
                implicitWidth: parent.width / 4

                VerticalSpacer {
                    id: top_spacer
                    spacerHeight: 10
                    anchors.top: parent.top
                }

                Workspaces {
                    id: workspaces
                    anchors {
                        top: top_spacer.bottom
                        left: parent.left
                        right: parent.right
                    }
                }

                Tray {
                    id: tray
                    anchors.bottom: statusIcons.top
                }

                StatusIcons {
                    id: statusIcons
                    anchors.bottom: clock.top

                    Connections {
                        target: statusIcons
                        function onExpandedChanged() {
                            bar.statusIconsExpanded = statusIcons.expanded;
                        }
                    }
                }

                ClockWidget {
                    id: clock
                    anchors.bottom: powerIndicator.top
                }

                PowerIndicator {
                    id: powerIndicator
                    anchors.bottom: bottom_spacer.top

                    onExpandedChanged: {
                        bar.powerIndicatorExpanded = expanded;
                    }
                }
                VerticalSpacer {
                    id: bottom_spacer
                    spacerHeight: 30
                    anchors.bottom: parent.bottom
                }
            }
        }
    }
}
