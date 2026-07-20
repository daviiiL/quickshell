pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.common
import qs.widgets

Item {
    id: root

    ColumnLayout {
        anchors.centerIn: parent
        width: parent.width - 64
        spacing: 10

        MaterialSymbol {
            Layout.alignment: Qt.AlignHCenter
            icon: "key"
            iconSize: 30
            fontColor: Colors.inkDim
        }

        Text {
            Layout.alignment: Qt.AlignHCenter
            text: "No API key set"
            color: Colors.fgSurface
            font.family: Theme.font.family.inter_medium
            font.pixelSize: Theme.font.size.lg
            font.weight: Font.Medium
        }

        Text {
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            text: "Add your Gemini API key in AI settings to start chatting."
            color: Colors.inkDimmer
            font.family: Theme.font.family.inter
            font.pixelSize: Theme.font.size.sm
            lineHeight: 1.4
        }

        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 4
            implicitWidth: openLabel.implicitWidth + 28
            implicitHeight: 32
            radius: Theme.ui.radius.md
            color: openArea.containsMouse ? Qt.alpha(Colors.primary, 0.14) : Colors.surfaceContainer
            border.width: Theme.ui.mainBarHairWidth
            border.color: openArea.containsMouse ? Colors.primary : Colors.hair

            Text {
                id: openLabel
                anchors.centerIn: parent
                text: "AI SETTINGS"
                color: openArea.containsMouse ? Colors.primary : Colors.inkDim
                font.family: Theme.font.family.inter_medium
                font.pixelSize: Theme.font.size.xs
                font.letterSpacing: 1.8
            }

            MouseArea {
                id: openArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    GlobalStates.leftPanelOpen = false;
                    GlobalStates.controlCenterPane = "ai";
                    GlobalStates.openControlCenter("gemini");
                }
            }
        }
    }
}
