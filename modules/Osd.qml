import QtQuick
import QtQuick.Layouts
import Quickshell
import "../utils/"
import "../components/"

Scope {
    id: root

    property real currentBrightness: 0
    property bool visible: false

    Connections {
        target: Audio.defaultSinkAudio
        function onVolumeChanged() {
            root.visible = true;
            hideTimer.restart();
        }
    }

    Connections {
        target: Brightness
        function onBrightnessChanged(val) {
            root.visible = true;
            root.currentBrightness = val;
            // console.log("brightness change signal received in osd", root.currentBrightness);
            hideTimer.restart();
        }
    }

    Timer {
        id: hideTimer
        interval: 1000
        onTriggered: root.visible = false
    }

    LazyLoader {
        active: root.visible

        PanelWindow {
            id: osd
            anchors.right: true
            margins.right: 10

            implicitWidth: 120
            implicitHeight: 400
            color: "transparent"

            mask: Region {}

            Rectangle {
                anchors.fill: parent
                radius: Config.rounding.large
                color: Colors.values.background

                RowLayout {
                    anchors {
                        top: parent.top
                        right: parent.right
                        bottom: parent.bottom
                        rightMargin: 10
                    }

                    Rectangle {
                        id: volume
                        implicitHeight: 380
                        implicitWidth: osd.width / 2 - 10
                        radius: Config.rounding.regular
                        color: Colors.values.primary_container

                        Rectangle {
                            anchors {
                                left: parent.left
                                right: parent.right
                                bottom: parent.bottom
                            }

                            implicitHeight: parent.height * (Audio.volume > 1 ? 1 : Audio.volume)
                            radius: parent.radius
                            color: Audio.isOverdrive ? Colors.values.on_primary_container : Colors.values.on_error_container
                        }
                    }

                    Rectangle {
                        id: brightness
                        implicitWidth: osd.width / 2 - 10
                        implicitHeight: 380
                        radius: Config.rounding.regular
                        color: Colors.values.primary_container

                        Rectangle {
                            anchors {
                                left: parent.left
                                right: parent.right
                                bottom: parent.bottom
                            }

                            implicitHeight: parent.height * (root.currentBrightness / 100)
                            radius: parent.radius
                            color: Colors.values.on_primary_container
                        }
                    }
                }
            }
        }
    }
}
