import QtQuick
import QtQuick.Layouts
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

                ColumnLayout {
                    anchors.fill: parent
                    Workspaces {
                        Layout.fillWidth: true
                        Layout.topMargin: 20
                        Layout.alignment: Qt.AlignTop
                    }

                    Tray {
                        Layout.alignment: Qt.AlignBottom
                        Layout.fillHeight: true
                    }

                    NotificationButton {
                        Layout.alignment: Qt.AlignBottom
                    }

                    StatusIcons {
                        id: statusIcons
                        Layout.alignment: Qt.AlignBottom
                        Connections {
                            function onExpandedChanged() {
                                bar.statusIconsExpanded = statusIcons.expanded;
                            }

                            target: statusIcons
                        }
                    }

                    ClockWidget {
                        Layout.alignment: Qt.AlignBottom
                    }

                    PowerIndicator {
                        Layout.alignment: Qt.AlignBottom
                        Layout.bottomMargin: 10
                        onExpandedChanged: {
                            bar.powerIndicatorExpanded = expanded;
                        }
                    }
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
