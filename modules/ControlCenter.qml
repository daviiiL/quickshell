pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Io

import qs.common
import qs.components.controlcenter

Scope {
    id: root

    IpcHandler {
        target: "controlcenter"

        function toggle(): void {
            GlobalStates.controlCenterPanelOpen = !GlobalStates.controlCenterPanelOpen;
        }
    }

    Variants {
        model: Quickshell.screens

        FloatingWindow {
            id: window
            required property var modelData

            property bool closing: false

            function closePanel(): void {
                GlobalStates.controlCenterPanelOpen = false;
                window.closing = false;
            }

            Timer {
                id: closePanelTimer
                running: false
                repeat: false
                interval: 400
                onTriggered: () => {
                    window.closePanel();
                }
            }

            screen: modelData
            visible: GlobalStates.controlCenterPanelOpen || closing

            onVisibleChanged: {
                if (!visible)
                    closePanel();
            }

            width: 670
            height: 770

            color: "transparent"

            Rectangle {
                id: contentRect

                Keys.onEscapePressed: {
                    window.closing = true;
                    closePanelTimer.running = true;
                }

                anchors.fill: parent

                color: Colors.surface_translucent

                RowLayout {
                    anchors.fill: parent

                    Rectangle {
                        id: menuContainer
                        Layout.topMargin: 10
                        Layout.fillHeight: true
                        Layout.preferredWidth: 200
                        color: "transparent"
                        Layout.leftMargin: Theme.ui.padding.sm

                        ListView {
                            id: listview
                            anchors.fill: parent
                            currentIndex: 0

                            model: ScriptModel {
                                values: {
                                    var items = ["Network", "Bluetooth", "Preferences"];
                                    if (GlobalStates.isLaptop) {
                                        items.push("Battery");
                                    } else
                                        items.push("Power");

                                    items.push("System Info");
                                    return items;
                                }
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
                        Layout.fillWidth: true
                        Layout.margins: Theme.ui.padding.sm
                        radius: Theme.ui.radius.lg
                        color: Colors.surface_container
                        StackLayout {
                            anchors.fill: parent
                            currentIndex: listview.currentIndex

                            NetworkPanel {}
                            BluetoothPanel {}
                            PreferencesPanel {}
                            PowerPanel {}
                            AboutSystemPanel {}
                        }
                    }
                }

                opacity: window.closing ? 0 : (GlobalStates.controlCenterPanelOpen ? 1 : 0)
                scale: window.closing ? 0.9 : (GlobalStates.controlCenterPanelOpen ? 1 : 0.9)

                Behavior on opacity {
                    NumberAnimation {
                        duration: 350
                        easing.type: Easing.OutCubic
                    }
                }

                Behavior on scale {
                    NumberAnimation {
                        duration: 350
                        easing.type: Easing.OutBack
                        easing.overshoot: 1.2
                    }
                }
            }

            Component.onCompleted: {
                contentRect.forceActiveFocus();
            }
        }
    }

    component ControlCenterMenuItem: Rectangle {
        id: itemRoot
        height: 50
        width: menuContainer.width
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

        Canvas {
            id: topIndicator
            anchors {
                top: parent.top
                horizontalCenter: parent.horizontalCenter
            }
            width: parent.width * 0.6
            height: 3
            opacity: itemRoot.currentIndex === itemRoot.index ? 1 : 0

            Connections {
                target: Colors

                function onPrimaryChanged() {
                    topIndicator.requestPaint();
                }
            }

            Behavior on opacity {
                NumberAnimation {
                    duration: Theme.anim.durations.sm
                    easing.type: Easing.Bezier
                    easing.bezierCurve: Theme.anim.curves.emphasized
                }
            }

            onPaint: {
                var ctx = getContext("2d");
                ctx.clearRect(0, 0, width, height);
                ctx.fillStyle = Colors.primary;
                ctx.fillRect(0, 0, width, height);
            }

            onOpacityChanged: requestPaint()
        }

        Rectangle {
            anchors.fill: parent

            radius: Theme.ui.radius.md
            property color highlightBg: Colors.primary_container
            property color targetBgColor: parent.currentIndex === parent.index ? Qt.rgba(highlightBg.r, highlightBg.g, highlightBg.b, 0.3) : "transparent"
            color: targetBgColor

            border {
                color: listview.currentIndex === itemRoot.index ? Colors.primary_container : "transparent"
            }

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
