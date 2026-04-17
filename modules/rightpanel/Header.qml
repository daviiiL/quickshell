pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.common

RowLayout {
    id: root

    property string userName: Qt.application.organization || "user"
    property string hostLabel: ""
    property string initials: root.userName.substring(0, 2).toUpperCase()

    Layout.fillWidth: true
    Layout.leftMargin: 14
    Layout.rightMargin: 14
    Layout.topMargin: 14
    Layout.bottomMargin: 12
    spacing: 10

    Rectangle {
        id: avatar
        Layout.preferredWidth: 26
        Layout.preferredHeight: 26
        radius: 4
        gradient: Gradient {
            orientation: Gradient.Vertical
            GradientStop { position: 0.0; color: Colors.surfaceContainerHigh }
            GradientStop { position: 1.0; color: Colors.surfaceContainerLow }
        }
        border.color: Colors.hair
        border.width: Theme.ui.mainBarHairWidth

        Text {
            anchors.centerIn: parent
            text: root.initials
            color: Colors.barAccent
            font.family: Theme.font.family.inter_medium
            font.pixelSize: 11
            font.weight: Font.Medium
            font.letterSpacing: 0.6
        }
    }

    ColumnLayout {
        spacing: 2
        Layout.alignment: Qt.AlignVCenter

        Text {
            text: root.userName
            color: Colors.fgSurface
            font.family: Theme.font.family.inter_medium
            font.pixelSize: 13
            font.weight: Font.Medium
            font.letterSpacing: 0.3
        }

        Text {
            visible: root.hostLabel.length > 0
            text: root.hostLabel.toUpperCase()
            color: Colors.inkDimmer
            font.family: Theme.font.family.inter_medium
            font.pixelSize: 10
            font.letterSpacing: 1.4
        }
    }

    Item { Layout.fillWidth: true }
}
