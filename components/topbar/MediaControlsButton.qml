pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.common
import qs.widgets
import qs.services

Rectangle {
    id: root

    Layout.fillHeight: true
    Layout.maximumWidth: 200
    Layout.preferredWidth: 200
    Layout.topMargin: 3
    Layout.bottomMargin: 3

    readonly property color iconColor: Colors.primary
    readonly property color textColor: Colors.on_surface
    readonly property color bgColor: Preferences.darkMode ? Colors.surface_container : Colors.primary_container
    readonly property color hoverBgColor: Colors.surface_container_high
    readonly property GradientColors gradientColors: GradientColors {}

    component GradientColors: QtObject {
        readonly property color start: Preferences.darkMode ? "transparent" : root.bgColor
        readonly property color end: Preferences.darkMode ? Colors.surface : Colors.background
    }

    visible: SystemMpris.activePlayer !== null
    radius: Theme.ui.radius.md
    color: bgColor

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

    Rectangle {
        z: 2
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: 25
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop {
                position: 0.0
                color: root.gradientColors.start
            }
            GradientStop {
                position: 1.0
                color: root.gradientColors.end
            }
        }
    }

    RowLayout {
        id: mediaContent
        anchors.fill: parent
        anchors.leftMargin: Theme.ui.padding.sm
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
                    var artist = SystemMpris.activePlayer?.trackArtist || "";
                    return `${title} by ${artist}`;
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
            root.color = root.bgColor;
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
