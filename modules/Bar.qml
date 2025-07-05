import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Controls
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
            screen: modelData

            anchors {
                top: true
                left: true
                bottom: true
            }

            implicitWidth: Theme.bar.width * 4
            color: "transparent"
            WlrLayershell.layer: WlrLayer.Top
            WlrLayershell.exclusiveZone: Theme.bar.width
            mask: Region {
                item: Rectangle {
                    width: bar.statusIconsExpanded ? Theme.bar.width * 4 : Theme.bar.width
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

                color: Colors.values.background
                implicitWidth: parent.width / 4

                MouseArea {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.topMargin: 20
                    implicitHeight: 20
                    implicitWidth: parent.width
                    hoverEnabled: true
                    onEntered: cheatsheet.show()
                    onExited: cheatsheet.hide()
                }

                Cheatsheet {
                    id: cheatsheet
                    screen: bar.modelData
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
                    anchors.bottom: power.top
                }
                PowerIndicator {
                    id: power
                    anchors.bottom: bottom_spacer.top
                }
                VerticalSpacer {
                    id: bottom_spacer
                    anchors.bottom: parent.bottom
                    // color: "transparent"
                }
            }
        }
    }
}
