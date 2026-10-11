pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.common

RowLayout {
    id: root

    property string userName: Qt.application.organization || "user"
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
            font.pixelSize: Theme.font.size.body
            font.weight: Font.Medium
        }
    }

    Text {
        Layout.alignment: Qt.AlignVCenter
        text: root.userName
        color: Colors.fgSurface
        font.family: Theme.font.family.inter_medium
        font.pixelSize: Theme.font.size.title
        font.weight: Font.Medium
        font.letterSpacing: 0.3
    }

    Item { Layout.fillWidth: true }
}
