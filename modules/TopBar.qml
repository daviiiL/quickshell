import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.common
import qs.components
import qs.widgets
import qs.services

Scope {

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: root
            required property var modelData

            screen: modelData
            color: "transparent"

            implicitHeight: Theme.ui.topBarHeight

            WlrLayershell.layer: WlrLayer.Top
            WlrLayershell.exclusiveZone: implicitHeight

            anchors {
                right: true
                left: true
                top: true
            }

            visible: !GlobalStates.powerPanelOpen

            Rectangle {
                anchors.fill: parent
                radius: Theme.ui.radius.md

                anchors.margins: Theme.ui.padding.sm / 2

                color: Qt.rgba(Colors.background.r, Colors.background.g, Colors.background.b, 0.9)

                RowLayout {
                    anchors.fill: parent
                    spacing: Theme.ui.padding.md

                    Workspaces {
                        Layout.fillHeight: true
                        Layout.leftMargin: Theme.ui.padding.sm
                    }

                    Item {
                        id: osdContainer
                        Layout.fillHeight: true
                        Layout.fillWidth: true

                        TopProgressBar {
                            id: progressbar
                            property bool showing: false
                            visible: opacity > 0
                            opacity: showing ? 1 : 0
                            scale: showing ? 1 : 0.95

                            Behavior on opacity {
                                NumberAnimation {
                                    duration: Theme.anim.durations.sm
                                    easing.type: Easing.Bezier
                                    easing.bezierCurve: Theme.anim.curves.emphasized
                                }
                            }

                            Behavior on scale {
                                NumberAnimation {
                                    duration: Theme.anim.durations.sm
                                    easing.type: Easing.Bezier
                                    easing.bezierCurve: Theme.anim.curves.emphasized
                                }
                            }
                        }

                        Timer {
                            id: hideTopProgressBar
                            interval: 1000
                            running: false

                            onTriggered: progressbar.showing = false
                        }

                        Connections {
                            target: Audio.defaultSinkAudio

                            function onVolumeChanged() {
                                progressbar.value = Audio.volume;
                                progressbar.max = 1;
                                progressbar.text = "Volume";
                                progressbar.showing = true;
                                hideTopProgressBar.restart();
                            }

                            function onMutedChanged() {
                                progressbar.value = Audio.volume;
                                progressbar.max = 1;
                                progressbar.text = "Volume";
                                progressbar.showing = true;
                                hideTopProgressBar.restart();
                            }
                        }

                        Connections {
                            target: Brightness

                            function onBrightnessChanged() {
                                progressbar.value = Brightness.brightness;
                                progressbar.max = 100;
                                progressbar.text = "Brightness";
                                progressbar.showing = true;
                                hideTopProgressBar.restart();
                            }
                        }
                    }

                    SystemStatusCard {
                        Layout.fillHeight: true
                        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                    }

                    Rectangle {
                        Layout.preferredHeight: icon.implicitHeight + 4
                        Layout.rightMargin: Theme.ui.padding.sm
                        Layout.preferredWidth: icon.implicitWidth
                        color: Qt.rgba(Colors.primary_container.r, Colors.primary_container.g, Colors.primary_container.b, 0)
                        radius: Theme.ui.radius.md
                        MaterialSymbol {
                            id: icon
                            anchors.fill: parent
                            fontColor: Colors.secondary
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.verticalCenter: parent.verticalCenter
                            icon: "settings_power"
                            iconSize: 15
                        }

                        Behavior on color {
                            ColorAnimation {
                                easing.type: Easing.Bezier
                                easing.bezierCurve: Theme.anim.curves.standard
                                duration: 200
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true

                            onEntered: {
                                icon.fontColor = Colors.on_primary_container;
                                parent.color = Colors.primary_container;
                            }

                            onExited: {
                                icon.fontColor = Colors.secondary;
                                parent.color = Qt.rgba(Colors.primary_container.r, Colors.primary_container.g, Colors.primary_container.b, 0);
                            }

                            onPressed: {
                                GlobalStates.powerPanelOpen = true;
                            }
                        }
                    }
                }
            }
        }
    }
}
