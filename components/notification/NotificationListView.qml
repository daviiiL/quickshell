pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import "../../services"
import "../../common"
import "../widgets"

/**
 * Scrollable list of notification groups
 */
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
        anchors.left: parent?.left
        anchors.right: parent?.right
        notificationGroup: popup ? Notifications.popupGroupsByAppName[modelData] : Notifications.groupsByAppName[modelData]
    }
}
