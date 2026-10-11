pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.common

Rectangle {
    id: root

    required property PickerNav nav
    required property string homeDir

    signal closeRequested()

    implicitHeight: 44
    color: Colors.surfaceContainerLowest

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: Theme.ui.mainBarHairWidth
        color: Colors.hair
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 14
        anchors.rightMargin: 14
        spacing: 6

        NavButton { icon: "arrow_back";    enabled: root.nav.canGoBack;    onActivated: root.nav.back() }
        NavButton { icon: "arrow_forward"; enabled: root.nav.canGoForward; onActivated: root.nav.forward() }
        NavButton { icon: "arrow_upward";  enabled: root.nav.canGoUp;      onActivated: root.nav.up() }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 26
            Layout.leftMargin: 6
            radius: 3
            color: Colors.surfaceContainerLow
            border.color: Colors.hair
            border.width: Theme.ui.mainBarHairWidth

            Text {
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                verticalAlignment: Text.AlignVCenter
                text: root.nav.display(root.homeDir)
                color: Colors.fgSurface
                font.family: Theme.font.family.inter
                font.pixelSize: Theme.font.size.body
                elide: Text.ElideLeft
            }
        }

        Text {
            Layout.leftMargin: 6
            text: "Wallpaper"
            color: Colors.inkDimmer
            font.family: Theme.font.family.inter_medium
            font.pixelSize: Theme.font.size.body
            font.weight: Font.Medium
            font.letterSpacing: Theme.font.tracking.none
        }

        NavButton {
            Layout.leftMargin: 6
            icon: "close"
            onActivated: root.closeRequested()
        }
    }
}
