pragma ComponentBehavior: Bound

import QtQuick
import qs.common
import qs.services

Item {
    id: root

    Item {
        id: hero
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }
        height: 200

        OrbitalAvatar {
            anchors.fill: parent
            state: Gemini.state
            running: GlobalStates.leftPanelOpen
        }

        Text {
            anchors {
                left: parent.left
                top: parent.top
                leftMargin: 18
                topMargin: 16
            }
            text: "◆ GEMINI"
            color: Colors.inkDimmer
            font.family: Theme.font.family.inter_medium
            font.pixelSize: Theme.font.size.xs
            font.letterSpacing: 3.0
        }

        Rectangle {
            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }
            height: Theme.ui.mainBarHairWidth
            color: Colors.hair
        }
    }

    StatusLine {
        id: status
        anchors {
            top: hero.bottom
            left: parent.left
            right: parent.right
        }
    }

    Composer {
        id: composer
        anchors {
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }
    }

    ChatLog {
        anchors {
            top: status.bottom
            bottom: composer.top
            left: parent.left
            right: parent.right
        }
        visible: Gemini.state !== "needs-key"
    }

    NeedsKeyPrompt {
        anchors {
            top: status.bottom
            bottom: composer.top
            left: parent.left
            right: parent.right
        }
        visible: Gemini.state === "needs-key"
    }
}
