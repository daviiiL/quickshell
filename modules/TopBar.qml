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

            WlrLayershell.namespace: "quickshell:topbar"

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

                    Rectangle {
                        id: mpris
                        Layout.fillHeight: true
                        Layout.maximumWidth: 250
                        Layout.preferredWidth: 250
                        visible: SystemMpris.activePlayer !== null
                        color: "transparent"
                        radius: Theme.ui.radius.md

                        onXChanged: {
                            GlobalStates.mediaControlsX = mpris.x;
                        }

                        onYChanged: {
                            GlobalStates.mediaControlsY = mpris.y;
                        }

                        Component.onCompleted: {
                            GlobalStates.mediaControlsX = mpris.x;
                            GlobalStates.mediaControlsY = mpris.y;
                        }

                        RowLayout {
                            id: mediaContent
                            anchors.fill: parent
                            anchors.margins: Theme.ui.padding.sm
                            spacing: Theme.ui.padding.sm

                            MaterialSymbol {
                                icon: SystemMpris.isPlaying ? "music_note" : "pause"
                                iconSize: 16
                                fontColor: Colors.on_secondary_container
                            }

                            Item {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                clip: true

                                StyledText {
                                    anchors.left: parent.left
                                    anchors.verticalCenter: parent.verticalCenter
                                    font.pixelSize: Theme.font.size.sm
                                    color: Colors.on_secondary_container
                                    text: {
                                        var title = StringUtils.cleanMusicTitle(SystemMpris.activePlayer?.trackTitle || "No media");
                                        var artist = SystemMpris.activePlayer?.trackArtist || "";
                                        return artist ? `${title} • ${artist}` : title;
                                    }
                                }

                                Rectangle {
                                    visible: !mprisMouseArea.containsMouse
                                    anchors.right: parent.right
                                    anchors.top: parent.top
                                    anchors.bottom: parent.bottom
                                    width: 30
                                    gradient: Gradient {
                                        orientation: Gradient.Horizontal
                                        GradientStop {
                                            position: 0.0
                                            color: "transparent"
                                        }
                                        GradientStop {
                                            position: 1.0
                                            color: Colors.background
                                        }
                                    }

                                    // StyledText {
                                    //     anchors.right: parent.right
                                    //     anchors.verticalCenter: parent.verticalCenter
                                    //     font.pixelSize: Theme.font.size.sm
                                    //     color: Colors.on_secondary_container
                                    //     text: "..."
                                    // }
                                }
                            }
                        }

                        MouseArea {
                            id: mprisMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton

                            onEntered: {
                                mpris.color = Qt.rgba(Colors.secondary_container.r, Colors.secondary_container.g, Colors.secondary_container.b, 0.3);
                            }

                            onExited: {
                                mpris.color = "transparent";
                            }

                            onPressed: event => {
                                if (event.button === Qt.MiddleButton) {
                                    SystemMpris.togglePlaying();
                                } else if (event.button === Qt.RightButton) {
                                    SystemMpris.next();
                                } else if (event.button === Qt.LeftButton) {
                                    GlobalStates.mediaControlsOpen = !GlobalStates.mediaControlsOpen;
                                }
                            }
                        }
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
