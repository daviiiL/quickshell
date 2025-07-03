import Quickshell
import Quickshell.Wayland
import QtQuick
import "../components/"
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

            implicitWidth: Config.bar.width * 4
            color: "transparent"
            WlrLayershell.layer: WlrLayer.Top
            WlrLayershell.exclusiveZone: Config.bar.width
            mask: Region {
                item: Rectangle {
                    width: bar.statusIconsExpanded ? Config.bar.width * 4 : Config.bar.width
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

                StatusIcons {
                    id: statusIcons
                    anchors.bottom: clock.top
                    
                    Connections {
                        target: statusIcons
                        function onExpandedChanged() {
                            bar.statusIconsExpanded = statusIcons.expanded
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

                PowerPopup {
                    id: popupLoader
                    pWindow: bar
                    Connections {
                        target: power
                        function onMouseCaptured(val) {
                            val ? popupLoader.show() : popupLoader.hide();
                        }
                    }
                }
            }
        }
    }
}
