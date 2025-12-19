import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Hyprland
import qs
import qs.common
import qs.components.statusbar
import qs.components.widgets

Scope {
    GlobalShortcut {
        name: "toggleStatusBar"
        description: "Expand/Collapse the status bar"
        onPressed: function () {
            GlobalStates.statusBarExpanded = !GlobalStates.statusBarExpanded;
        }
    }

    GlobalShortcut {
        name: "expandStatusBar"
        description: "Expand the status bar"
        onPressed: function () {
            GlobalStates.statusBarExpanded = true;
        }
    }

    GlobalShortcut {
        name: "collapseStatusBar"
        description: "Collapse the status bar"
        onPressed: function () {
            GlobalStates.statusBarExpanded = false;
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: statusBar

            property var modelData
            property bool expanded: GlobalStates.statusBarExpanded

            screen: modelData
            color: "transparent"
            implicitWidth: screen.width
            implicitHeight: statusbarContainer.height
            WlrLayershell.layer: WlrLayer.Top

            anchors {
                left: true
                right: true
                bottom: true
            }

            Rectangle {
                id: statusbarContainer
                implicitWidth: parent.width
                color: Colors.current.background

                implicitHeight: statusBar.expanded ? Theme.statusbar.expandedHeight : Theme.statusbar.height

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: Theme.bar.width
                    spacing: 0

                    WindowIndicator {
                        id: windowIndicator
                        Layout.alignment: Qt.AlignTop
                    }

                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                    }

                    SensorIndicator {
                        // collapsed status bar sensor indicator
                        id: sensorIndicator
                        visible: !statusBar.expanded
                        Layout.fillHeight: true
                    }

                    SystemIndicator {
                        visible: statusBar.expanded
                        Layout.fillHeight: true
                    }

                    IconButton {
                        id: expandButton
                        icon: statusBar.expanded ? "collapse_all" : "expand_all"
                        Layout.alignment: Qt.AlignTop
                        onClicked: function () {
                            GlobalStates.statusBarExpanded = !GlobalStates.statusBarExpanded;
                        }
                    }
                }
            }
        }
    }
}
