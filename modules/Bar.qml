import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.common
import qs.components
import qs.components.notification
import qs.components.tray

Scope {
    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: bar

            property var modelData
            property bool statusIconsExpanded: false
            property bool powerIndicatorExpanded: false

            screen: modelData
            color: "transparent"
            implicitWidth: Theme.bar.maxWidth
            implicitHeight: modelData.height
            WlrLayershell.layer: WlrLayer.Top
            WlrLayershell.exclusiveZone: Theme.bar.width

            anchors {
                top: true
                left: true
                bottom: true
            }

            Rectangle {
                color: Colors.current.background
                implicitWidth: parent.width / 4

                anchors {
                    top: parent.top
                    left: parent.left
                    bottom: parent.bottom
                }

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

                    anchors.bottom: notificationButton.top
                }

                NotificationButton {
                    id: notificationButton

                    anchors {
                        left: parent.left
                        right: parent.right
                        bottom: statusIcons.top
                    }
                }

                StatusIcons {
                    id: statusIcons

                    anchors.bottom: clock.top

                    Connections {
                        function onExpandedChanged() {
                            bar.statusIconsExpanded = statusIcons.expanded;
                        }

                        target: statusIcons
                    }
                }

                ClockWidget {
                    id: clock

                    anchors.bottom: power_spacer.top
                }

                VerticalSpacer {
                    id: power_spacer

                    spacerHeight: 20
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

                    spacerHeight: 50
                    anchors.bottom: parent.bottom
                }
            }

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
        }
    }
}
