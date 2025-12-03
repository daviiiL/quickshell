import QtQuick
import Quickshell.Io
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import qs
import qs.common
import qs.components

Scope {
    id: root
    property bool detach: false
    property Component contentComponent: SidebarComponent {}
    property Item sidebarContent

    Component.onCompleted: {
        root.sidebarContent = contentComponent.createObject(null, {
            "scopeRoot": root
        });
        sidebarLoader.item.contentParent.children = [root.sidebarContent];
    }

    onDetachChanged: {
        if (root.detach) {
            sidebarContent.parent = null;
            sidebarLoader.active = false;
            detachedSidebarLoader.active = true;
            detachedSidebarLoader.item.contentParent.children = [sidebarContent];
        } else {
            sidebarContent.parent = null;
            detachedSidebarLoader.active = false;
            sidebarLoader.active = true;
            sidebarLoader.item.contentParent.children = [sidebarContent];
        }
    }

    Loader {
        id: sidebarLoader
        active: true

        sourceComponent: PanelWindow {
            id: sidebarRoot
            visible: GlobalStates.sidebarLeftOpen

            property bool extend: false
            property real sidebarWidth: sidebarRoot.extend ? (Theme.sidebar.width * 2) : Theme.sidebar.width
            property var contentParent: sidebarLeftBackground
            readonly property real elevationMargin: 8
            readonly property real hyprlandGapsOut: 10

            function hide() {
                GlobalStates.sidebarLeftOpen = false;
            }

            exclusiveZone: 0
            implicitWidth: (Theme.sidebar.width * 2) + elevationMargin
            WlrLayershell.namespace: "quickshell:sidebarLeft"
            WlrLayershell.layer: WlrLayer.Overlay
            color: "transparent"

            anchors {
                top: true
                left: true
                bottom: true
            }

            mask: Region {
                item: sidebarLeftBackground
            }

            HyprlandFocusGrab {
                id: grab
                windows: [sidebarRoot]
                active: sidebarRoot.visible
                onActiveChanged: {
                    if (active)
                        sidebarLeftBackground.children[0].focusActiveItem();
                }
                onCleared: () => {
                    if (!active)
                        sidebarRoot.hide();
                }
            }

            Rectangle {
                id: sidebarLeftBackground
                anchors.top: parent.top
                anchors.left: parent.left
                // anchors.topMargin: hyprlandGapsOut
                // anchors.leftMargin: hyprlandGapsOut
                width: sidebarRoot.sidebarWidth - hyprlandGapsOut - elevationMargin
                height: parent.height
                color: Colors.current.background
                border {
                    width: 1
                    color: Colors.current.secondary_container
                }
                radius: Theme.rounding.xs
                Behavior on width {

                    NumberAnimation {
                        duration: Theme.anim.durations.normal
                        easing.bezierCurve: Theme.anim.curves.emphasized
                    }
                }

                Keys.onPressed: event => {
                    if (event.key === Qt.Key_Escape) {
                        sidebarRoot.hide();
                    }
                    if (event.modifiers === Qt.ControlModifier) {
                        if (event.key === Qt.Key_O) {
                            sidebarRoot.extend = !sidebarRoot.extend;
                        } else if (event.key === Qt.Key_P) {
                            root.detach = !root.detach;
                        }
                        event.accepted = true;
                    }
                }
            }
        }
    }

    Loader {
        id: detachedSidebarLoader
        active: false

        sourceComponent: FloatingWindow {
            id: detachedSidebarRoot
            property var contentParent: detachedSidebarBackground

            visible: GlobalStates.sidebarLeftOpen
            onVisibleChanged: {
                if (!visible)
                    GlobalStates.sidebarLeftOpen = false;
            }

            Rectangle {
                id: detachedSidebarBackground
                anchors.fill: parent
                color: Colors.current.surface

                Keys.onPressed: event => {
                    if (event.modifiers === Qt.ControlModifier) {
                        if (event.key === Qt.Key_P) {
                            root.detach = !root.detach;
                        }
                        event.accepted = true;
                    }
                }
            }
        }
    }

    IpcHandler {
        target: "sidebarLeft"

        function toggle(): void {
            GlobalStates.sidebarLeftOpen = !GlobalStates.sidebarLeftOpen;
        }

        function close(): void {
            GlobalStates.sidebarLeftOpen = false;
        }

        function open(): void {
            GlobalStates.sidebarLeftOpen = true;
        }
    }

    GlobalShortcut {
        name: "sidebarLeftToggle"
        description: "Toggles left sidebar on press"

        onPressed: {
            GlobalStates.sidebarLeftOpen = !GlobalStates.sidebarLeftOpen;
        }
    }

    GlobalShortcut {
        name: "sidebarLeftOpen"
        description: "Opens left sidebar on press"

        onPressed: {
            GlobalStates.sidebarLeftOpen = true;
        }
    }

    GlobalShortcut {
        name: "sidebarLeftClose"
        description: "Closes left sidebar on press"

        onPressed: {
            GlobalStates.sidebarLeftOpen = false;
        }
    }

    GlobalShortcut {
        name: "sidebarLeftToggleDetach"
        description: "Detach left sidebar into a window/Attach it back"

        onPressed: {
            root.detach = !root.detach;
        }
    }
}
