pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.common
import qs.services

ColumnLayout {
    id: root

    Layout.fillWidth: true
    Layout.fillHeight: true
    spacing: 0

    RowLayout {
        Layout.fillWidth: true
        Layout.leftMargin: 14
        Layout.rightMargin: 14
        Layout.topMargin: 10
        Layout.bottomMargin: 8
        spacing: 8

        Text {
            text: "Notifications"
            color: Colors.inkDimmer
            font.family: Theme.font.family.inter_medium
            font.pixelSize: Theme.font.size.caption
            font.weight: Font.Medium
            font.letterSpacing: Theme.font.tracking.none
        }

        Text {
            text: Notifications.list.length
            color: Colors.inkDim
            font.family: Theme.font.family.inter_regular
            font.pixelSize: Theme.font.size.caption
            font.letterSpacing: 0.4
        }

        Item { Layout.fillWidth: true }

        Rectangle {
            Layout.preferredHeight: 22
            implicitWidth: muteLabel.implicitWidth + 16
            radius: 3
            color: muteMa.containsMouse ? Colors.surfaceContainerLow : "transparent"
            border.color: Notifications.silent ? Colors.hairHot : Colors.hair
            border.width: Theme.ui.mainBarHairWidth
            Behavior on color        { ColorAnimation { duration: Theme.anim.durations.xs } }
            Behavior on border.color { ColorAnimation { duration: Theme.anim.durations.xs } }

            Text {
                id: muteLabel
                anchors.centerIn: parent
                text: Notifications.silent ? "Muted" : "Mute"
                color: Notifications.silent ? Colors.fgSurface : Colors.inkDim
                font.family: Theme.font.family.inter_medium
                font.pixelSize: Theme.font.size.caption
                font.letterSpacing: Theme.font.tracking.none
            }

            MouseArea {
                id: muteMa
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: Notifications.silent = !Notifications.silent
            }
        }

        Rectangle {
            Layout.preferredHeight: 22
            implicitWidth: clearLabel.implicitWidth + 16
            radius: 3
            color: clearMa.containsMouse ? Colors.surfaceContainerLow : "transparent"
            border.color: clearMa.containsMouse ? Colors.hairHot : Colors.hair
            border.width: Theme.ui.mainBarHairWidth
            Behavior on color        { ColorAnimation { duration: Theme.anim.durations.xs } }
            Behavior on border.color { ColorAnimation { duration: Theme.anim.durations.xs } }

            Text {
                id: clearLabel
                anchors.centerIn: parent
                text: "Clear"
                color: clearMa.containsMouse ? Colors.fgSurface : Colors.inkDim
                font.family: Theme.font.family.inter_medium
                font.pixelSize: Theme.font.size.caption
                font.letterSpacing: Theme.font.tracking.none
                Behavior on color { ColorAnimation { duration: Theme.anim.durations.xs } }
            }

            MouseArea {
                id: clearMa
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: Notifications.discardAllNotifications()
            }
        }
    }

    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: Theme.ui.mainBarHairWidth
        color: Colors.hair
    }

    Item {
        Layout.fillWidth: true
        Layout.fillHeight: true
        visible: Notifications.appNameList.length === 0

        Text {
            anchors.centerIn: parent
            text: "No notifications"
            color: Colors.inkFaint
            font.family: Theme.font.family.inter_medium
            font.pixelSize: Theme.font.size.body
            font.letterSpacing: Theme.font.tracking.none
        }
    }

    ListView {
        id: list
        visible: Notifications.appNameList.length > 0
        Layout.fillWidth: true
        Layout.fillHeight: true
        clip: true
        spacing: 0
        model: Notifications.appNameList
        boundsBehavior: Flickable.StopAtBounds

        delegate: NotificationGroup {
            required property var modelData
            width: list.width
            group: Notifications.groupsByAppName[modelData]
        }
    }
}
