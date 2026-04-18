pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.common
import qs.services

MainBarButton {
    id: root

    readonly property int unread: (typeof Notifications !== "undefined"
                                   && Notifications.unread !== undefined)
                                    ? Notifications.unread
                                    : 3

    readonly property string srcId: "notifications"
    active: GlobalStates.rightPanelOpen && GlobalStates.rightPanelSource === srcId

    onActivated: {
        if (GlobalStates.rightPanelOpen && GlobalStates.rightPanelSource === srcId) {
            GlobalStates.rightPanelOpen = false;
            GlobalStates.rightPanelSource = "";
        } else {
            GlobalStates.rightPanelSource = srcId;
            GlobalStates.rightPanelOpen = true;
        }
    }

    contentPadX: 9

    Item {
        id: bellWrap
        Layout.preferredWidth:  Theme.ui.mainBarIconSize
        Layout.preferredHeight: Theme.ui.mainBarIconSize

        Image {
            anchors.fill: parent
            source: Icons.bell
            sourceSize.width: Theme.ui.mainBarIconSize * 2
            sourceSize.height: Theme.ui.mainBarIconSize * 2
            smooth: true
            opacity: root.hovered ? 1.0 : 0.56
            Behavior on opacity { NumberAnimation { duration: 150; easing.type: Easing.InOutQuad } }
        }

        Rectangle {
            id: badge
            visible: root.unread > 0
            readonly property string label: root.unread > 9 ? "9+" : String(root.unread)

            height: 10
            width: Math.max(height, badgeText.implicitWidth + 6)
            radius: height / 2

            anchors.right: parent.right
            anchors.top: parent.top
            anchors.rightMargin: -width / 3
            anchors.topMargin: -2

            color: Colors.barAccent
            border.width: 1
            border.color: Colors.barBg

            Text {
                id: badgeText
                anchors.centerIn: parent
                text: badge.label
                color: "#0a0a0a"
                font.family: Theme.font.family.inter_bold
                font.weight: Font.Bold
                font.pixelSize: 7
            }
        }
    }
}
