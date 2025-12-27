pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import qs.services
import qs.widgets

StyledListView {
    id: root

    property bool popup: false

    spacing: 3
    clip: true

    model: ScriptModel {
        values: root.popup ? Notifications.popupAppNameList : Notifications.appNameList
    }

    delegate: NotificationGroup {
        required property int index
        required property var modelData

        popup: root.popup
        notificationGroup: popup ? Notifications.popupGroupsByAppName[modelData] : Notifications.groupsByAppName[modelData]

        anchors.left: parent?.left
        anchors.right: parent?.right
    }
}
