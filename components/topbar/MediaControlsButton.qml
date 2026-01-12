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
    readonly property color bgColor: Preferences.focusedMode ? Qt.alpha(Colors.surface_container, 0.25) : (Preferences.darkMode ? Colors.surface_container : Colors.primary_container)
    readonly property color hoverBgColor: Preferences.focusedMode ? Qt.alpha(Colors.surface_container_high, 0.4) : Colors.surface_container_high
    readonly property GradientColors gradientColors: GradientColors {}

    component GradientColors: QtObject {
        readonly property color start: Preferences.focusedMode ? "transparent" : (Preferences.darkMode ? "transparent" : root.bgColor)
        readonly property color end: Preferences.focusedMode ? "transparent" : (Preferences.darkMode ? Colors.surface : Colors.background)
    }

    visible: SystemMpris.activePlayer !== null
    radius: Preferences.focusedMode ? 2 : Theme.ui.radius.md
    color: bgColor

    border {
        width: Preferences.focusedMode ? 1 : 0
        color: Preferences.focusedMode ? Qt.alpha(Colors.primary, 0.5) : Colors.outline
    }

    Rectangle {
        visible: Preferences.focusedMode
        width: 2
        height: parent.height * 0.6
        anchors.left: parent.left
        anchors.leftMargin: -1
        anchors.verticalCenter: parent.verticalCenter
        color: Colors.primary
        opacity: 0.7
    }

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
        anchors.leftMargin: Preferences.focusedMode ? Theme.ui.padding.xs : Theme.ui.padding.sm
        spacing: Preferences.focusedMode ? 6 : Theme.ui.padding.sm

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
