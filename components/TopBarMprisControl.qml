import QtQuick
import QtQuick.Layouts
import qs.common
import qs.widgets
import qs.services

Rectangle {
    id: root
    Layout.fillHeight: true
    Layout.maximumWidth: 150
    Layout.preferredWidth: 150
    visible: SystemMpris.activePlayer !== null
    color: "transparent"
    radius: Theme.ui.radius.md

    readonly property color iconColor: Preferences.darkMode ? Colors.on_secondary_container : Colors.on_surface_variant
    readonly property color textColor: Preferences.darkMode ? Colors.on_secondary_container : Colors.on_surface
    readonly property color hoverBgColor: Preferences.darkMode ? Qt.rgba(Colors.secondary_container.r, Colors.secondary_container.g, Colors.secondary_container.b, 0.3) : Qt.rgba(Colors.secondary_container.r, Colors.secondary_container.g, Colors.secondary_container.b, 0.2)
    readonly property color gradientColor: Preferences.darkMode ? "black" : Qt.rgba(Colors.surface.r, Colors.surface.g, Colors.surface.b, 0.9)

    onXChanged: {
        GlobalStates.mediaControlsX = root.x;
    }

    onYChanged: {
        GlobalStates.mediaControlsY = root.y;
    }

    Component.onCompleted: {
        GlobalStates.mediaControlsX = root.x;
        GlobalStates.mediaControlsY = root.y;
    }

    RowLayout {
        id: mediaContent
        anchors.fill: parent
        anchors.margins: Theme.ui.padding.sm
        spacing: Theme.ui.padding.sm

        MaterialSymbol {
            icon: SystemMpris.isPlaying ? "music_note" : "pause"
            iconSize: 16
            fontColor: root.iconColor
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            StyledText {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: Theme.font.size.sm
                color: root.textColor
                text: {
                    var title = StringUtils.cleanMusicTitle(SystemMpris.activePlayer?.trackTitle || "No media");
                    // var artist = SystemMpris.activePlayer?.trackArtist || "";
                    return title;
                }
            }

            Rectangle {
                visible: !mprisMouseArea.containsMouse
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: 25
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop {
                        position: 0.0
                        color: "transparent"
                    }
                    GradientStop {
                        position: 1.0
                        color: root.gradientColor
                    }
                }
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
            root.color = root.hoverBgColor;
        }

        onExited: {
            root.color = "transparent";
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
