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
            Layout.preferredWidth: 200
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

            BluetoothPanel {}
        }
    }

    component ControlCenterMenuItem: Rectangle {
        id: itemRoot
        height: 50
        width: parent.width
        color: "transparent"

        required property int index
        required property string title
        required property int currentIndex

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true

            onPressed: () => {
                listview.currentIndex = itemRoot.index;
            }
        }

        Rectangle {
            anchors.fill: parent
            // anchors {
            //     topMargin: Theme.ui.padding.sm
            //     bottomMargin: Theme.ui.padding.sm
            // }
            radius: Theme.ui.radius.md
            property color highlightBg: Colors.primary_container

            property color targetBgColor: parent.currentIndex === parent.index ? Qt.rgba(highlightBg.r, highlightBg.g, highlightBg.b, 0.3) : "transparent"
            color: targetBgColor

            Behavior on color {
                ColorAnimation {
                    duration: Theme.anim.durations.sm
                    easing.type: Easing.Bezier
                    easing.bezierCurve: Theme.anim.curves.emphasized
                }
            }

            Text {
                text: itemRoot.title
                anchors.centerIn: parent
                font {
                    pixelSize: Theme.font.size.lg
                    family: Theme.font.family.inter_regular
                    // bold: itemRoot.index === itemRoot.currentIndex
                    weight: itemRoot.index === itemRoot.currentIndex ? Font.Bold : Font.Normal
                }

                Behavior on font.weight {
                    NumberAnimation {
                        duration: Theme.anim.durations.sm
                        easing.type: Easing.Bezier
                        easing.bezierCurve: Theme.anim.curves.emphasized
                    }
                }

                property color targetTextColor: itemRoot.currentIndex === itemRoot.index ? Colors.on_primary_container : Colors.on_surface
                color: targetTextColor

                Behavior on color {
                    ColorAnimation {
                        duration: Theme.anim.durations.sm
                        easing.type: Easing.Bezier
                        easing.bezierCurve: Theme.anim.curves.emphasized
                    }
                }
            }
        }
    }
}
