import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Widgets
import Quickshell.Wayland
import "../../common/"

PanelWindow {
    id: root

    Component.onDestruction: {
        console.log("tray menu destroyed");
    }

    onVisibleChanged: {
        console.log("fromtray", root.menuX, root.menuY);
    }

    property alias handle: menuContainer.handle
    property bool menuVisible: false
    property int menuX: 0
    property int menuY: 0
    visible: menuVisible
    color: "transparent"

    anchors.left: true
    anchors.top: true

    margins.top: menuY
    margins.left: menuX

    implicitWidth: 200
    implicitHeight: 300

    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    WlrLayershell.exclusionMode: ExclusionMode.Ignore

    function show() {
        menuVisible = true;
    }

    function hide() {
        menuVisible = false;
    }

    Rectangle {
        anchors.fill: parent
        color: Colors.current.surface
        radius: Theme.rounding.normal
        border.width: 1
        border.color: Colors.current.outline

        Column {
            id: menuContainer

            required property QsMenuHandle handle

            anchors.fill: parent
            anchors.margins: 8
            spacing: 4

            QsMenuOpener {
                id: menuOpener
                menu: menuContainer.handle
            }

            Repeater {
                model: menuOpener.children

                Rectangle {
                    id: item

                    required property QsMenuEntry modelData

                    width: parent.width
                    height: modelData.isSeparator ? 1 : 32
                    color: modelData.isSeparator ? Colors.current.outline : mouseArea.containsMouse ? Colors.current.primary_container : "transparent"
                    radius: Theme.rounding.small

                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        enabled: !item.modelData.isSeparator && item.modelData.enabled
                        hoverEnabled: true
                        onClicked: {
                            // Log the actual coordinates
                            console.log("Menu item clicked:");
                            console.log("  Local x, y:", item.x, item.y);
                            console.log("  Mapped to window:", item.mapToItem(root, 0, 0));
                            console.log("  Mapped to screen:", item.mapToItem(null, 0, 0));
                            console.log("  Item text:", item.modelData.text);

                            item.modelData.triggered();
                            root.hide();
                        }
                    }

                    Row {
                        anchors.centerIn: parent
                        spacing: 8
                        visible: !item.modelData.isSeparator

                        Text {
                            text: item.modelData.text
                            color: item.modelData.enabled ? Colors.current.on_surface : Colors.current.outline
                        }

                        Text {
                            text: ">"
                            color: item.modelData.enabled ? Colors.current.on_surface : Colors.current.outline
                            visible: item.modelData.hasChildren
                        }
                    }
                }
            }
        }
    }
}
