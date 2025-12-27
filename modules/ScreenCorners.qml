import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.common
import qs.components

Scope {
    Variants {
        model: Quickshell.screens

        Scope {
            id: monitorScope
            required property var modelData
            property HyprlandMonitor monitor: Hyprland.monitorFor(modelData)

            property list<HyprlandWorkspace> workspacesForMonitor: monitor ? Hyprland.workspaces.values.filter(workspace => workspace.monitor && workspace.monitor.name == monitor.name) : []
            property var activeWorkspaceWithFullscreen: workspacesForMonitor.filter(workspace => ((workspace.toplevels.values.filter(window => window.wayland?.fullscreen)[0] != undefined) && workspace.active))[0]
            property bool fullscreen: activeWorkspaceWithFullscreen != undefined

            PanelWindow {
                id: root

                screen: monitorScope.modelData
                visible: !monitorScope.fullscreen

                anchors {
                    top: true
                    left: true
                    right: true
                    bottom: true
                }

                margins {
                    left: Theme.ui.leftBarWidth + Theme.ui.padding.sm * 2
                    top: Theme.ui.topBarHeight + Theme.ui.padding.sm * 2
                }

                mask: Region {
                    item: null
                }

                color: "transparent"

                WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
                WlrLayershell.exclusionMode: ExclusionMode.Ignore
                WlrLayershell.namespace: "quickshell:screenCorners"
                WlrLayershell.layer: WlrLayer.Overlay

                readonly property color cornerColor: "transparent"
                ScreenCorner {
                    id: topLeftCorner
                    anchors {
                        top: parent.top
                        left: parent.left
                    }
                    color: root.cornerColor
                    size: Theme.ui.radius.lg
                    corner: ScreenCorner.CornerEnum.TopLeft
                }

                ScreenCorner {
                    id: topRightCorner
                    anchors {
                        top: parent.top
                        right: parent.right
                    }
                    color: root.cornerColor
                    size: Theme.ui.radius.lg
                    corner: ScreenCorner.CornerEnum.TopRight
                }

                ScreenCorner {
                    id: bottomLeftCorner
                    anchors {
                        bottom: parent.bottom
                        left: parent.left
                    }
                    color: root.cornerColor
                    size: Theme.ui.radius.lg
                    corner: ScreenCorner.CornerEnum.BottomLeft
                }

                ScreenCorner {
                    id: bottomRightCorner
                    anchors {
                        bottom: parent.bottom
                        right: parent.right
                    }
                    color: root.cornerColor
                    size: Theme.ui.radius.lg
                    corner: ScreenCorner.CornerEnum.BottomRight
                }
            }
        }
    }
}
