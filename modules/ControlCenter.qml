pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell

import qs.common
import qs.components.controlcenter

FloatingWindow {
    id: window
    title: "Control Center"
    visible: GlobalStates.controlCenterPanelOpen

    minimumSize: Qt.size(650, 750)
    // Component.onDestruction: {
    //     // console.log("Noooooooooooo");
    //     GlobalStates.controlCenterPanelOpen = false;
    //     console.log(visible);
    // }

    onVisibleChanged: {
        if (!this.visible) {
            // console.log("dismisseddddddddd");
            GlobalStates.controlCenterPanelOpen = false;
            // window.destroy();
        }
    }

    color: Colors.surface_container
    RowLayout {
        anchors.fill: parent

        Rectangle {
            Layout.fillHeight: true
            Layout.preferredWidth: 250
            color: "transparent"
            Layout.leftMargin: Theme.ui.padding.sm

            ListView {
                id: listview
                anchors.fill: parent
                currentIndex: 0

                model: ScriptModel {
                    values: ["Network", "Bluetooth"]
                }

                delegate: ControlCenterMenuItem {
                    required property string modelData
                    currentIndex: listview.currentIndex
                    title: modelData
                }
            }
        }

        Rectangle {
            Layout.fillHeight: true
            Layout.preferredWidth: 2
            color: Colors.secondary_container
        }

        StackLayout {
            Layout.fillHeight: true
            Layout.fillWidth: true
            currentIndex: listview.currentIndex

            NetworkPanel {}

            Rectangle {
                color: "transparent"
                Text {
                    anchors.centerIn: parent
                    text: "Bluetooth Settings"
                    font.pixelSize: Theme.font.size.xl
                    color: Colors.on_surface
                }
            }
        }
    }
}
