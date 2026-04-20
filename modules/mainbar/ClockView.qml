pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.common
import qs.services

Rectangle {
    id: root

    property bool syncing: false
    readonly property bool hovered: mouseArea.containsMouse

    signal activated()

    implicitWidth: row.implicitWidth
    implicitHeight: row.implicitHeight
    radius: Theme.ui.mainBarButtonRadius

    color: root.hovered ? Colors.surfaceContainerLow : "transparent"
    border.width: Theme.ui.mainBarHairWidth
    border.color: root.hovered ? Colors.hair : "transparent"

    Behavior on color        { ColorAnimation { duration: 150; easing.type: Easing.InOutQuad } }
    Behavior on border.color { ColorAnimation { duration: 150; easing.type: Easing.InOutQuad } }

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: 10

        RowLayout {
            spacing: 0

            Text {
                text: DateTime.hrs
                font.family: Theme.font.family.inter_medium
                font.pixelSize: 16
                font.weight: Font.Medium
                color: Colors.fgSurface
                font.letterSpacing: 0.4
            }

            Text {
                text: ":"
                font.family: Theme.font.family.inter_medium
                font.pixelSize: 16
                font.weight: Font.Medium
                color: Colors.barAccent

                SequentialAnimation on opacity {
                    loops: Animation.Infinite
                    NumberAnimation { from: 1;    to: 0.35; duration: 1000 }
                    NumberAnimation { from: 0.35; to: 1;    duration: 1000 }
                }
            }

            Text {
                text: DateTime.mins
                font.family: Theme.font.family.inter_medium
                font.pixelSize: 16
                font.weight: Font.Medium
                color: Colors.fgSurface
                font.letterSpacing: 0.4
            }
        }

        Rectangle {
            Layout.preferredHeight: 14
            Layout.preferredWidth: 1
            color: Colors.hair
        }

        Text {
            text: DateTime.date.toUpperCase()
            font.family: Theme.font.family.inter_medium
            font.pixelSize: 13
            color: Colors.inkDim
            font.letterSpacing: 1.0
            Layout.preferredWidth: 62
            horizontalAlignment: Text.AlignLeft
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            if (!root.syncing)
                root.activated();
        }
    }
}
