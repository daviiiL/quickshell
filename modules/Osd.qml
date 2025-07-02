import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import "../utils/"

Scope {
    id: root

    Connections {
        target: Audio.defaultSinkAudio
        function onVolumeChanged() {
            root.shouldShowOsd = true;
            console.log(Audio.volume);
            hideTimer.restart();
        }
    }

    property bool shouldShowOsd: false

    Timer {
        id: hideTimer
        interval: 1000
        onTriggered: root.shouldShowOsd = false
    }

    LazyLoader {
        active: root.shouldShowOsd

        PanelWindow {
            anchors.right: true
            margins.right: 10

            implicitWidth: 50
            implicitHeight: 400
            color: "transparent"

            mask: Region {}

            Rectangle {
                anchors.fill: parent
                radius: Config.rounding.large
                color: Colors.values.background

                RowLayout {
                    anchors {
                        fill: parent
                        leftMargin: 10
                        rightMargin: 10
                    }

                    Rectangle {
                        Layout.fillWidth: true

                        implicitHeight: 380
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
                            color: Audio.isOverdrive ? Colors.values.on_primary_container : Colors.values.error_container
                        }
                    }
                }
            }
        }
    }
}
