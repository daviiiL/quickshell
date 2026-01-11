pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Notifications
import "notification_utils.js" as NotificationUtils
import qs.components.notification
import qs.components
import qs.services
import qs.common
import qs.widgets

MouseArea {
    id: root

    property var notificationGroup
    property var notifications: notificationGroup?.notifications ?? []
    property int notificationCount: notifications.length
    property bool multipleNotifications: notificationCount > 1
    property bool expanded: popup ?? false
    property bool popup: false
    property real padding: 10
    property real dragConfirmThreshold: 70
    property real dismissOvershoot: 20
    property var qmlParent: root?.parent?.parent
    property var parentDragIndex: qmlParent?.dragIndex ?? -1
    property var parentDragDistance: qmlParent?.dragDistance ?? 0
    property var dragIndexDiff: Math.abs(parentDragIndex - index)
    property real xOffset: dragIndexDiff == 0 ? parentDragDistance : Math.abs(parentDragDistance) > dragConfirmThreshold ? 0 : dragIndexDiff == 1 ? (parentDragDistance * 0.3) : dragIndexDiff == 2 ? (parentDragDistance * 0.1) : 0

    implicitHeight: background.implicitHeight
    hoverEnabled: true

    function destroyWithAnimation(left = false) {
        root.qmlParent.resetDrag();
        destroyAnimation.left = left;
        destroyAnimation.running = true;
    }

    function toggleExpanded() {
        if (!root.popup) {
            if (expanded)
                implicitHeightAnim.enabled = true;
            else
                implicitHeightAnim.enabled = false;
        }
        root.expanded = !root.expanded;
    }

    onContainsMouseChanged: {
        if (!root.popup)
            return;

        root.notifications.forEach(notif => {
            if (root.containsMouse) {
                Notifications.cancelTimeout(notif.notificationId);
            } else {
                Notifications.timeoutNotification(notif.notificationId);
            }
        });
    }

    DragManager {
        id: dragManager
        anchors.fill: parent
        interactive: !root.expanded
        automaticallyReset: false
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

        onPressed: mouse => {
            if (mouse.button === Qt.RightButton)
                root.toggleExpanded();
        }

        onClicked: mouse => {
            if (mouse.button === Qt.MiddleButton)
                root.destroyWithAnimation();
        }

        onDraggingChanged: () => {
            if (dragging) {
                root.qmlParent.dragIndex = root.index ?? root.parent.children.indexOf(root);
            }
        }

        onDragDiffXChanged: () => {
            root.qmlParent.dragDistance = dragDiffX;
        }

        onDragReleased: (diffX, diffY) => {
            if (Math.abs(diffX) > root.dragConfirmThreshold)
                root.destroyWithAnimation(diffX < 0);
            else
                dragManager.resetDrag();
        }
    }

    SequentialAnimation {
        id: destroyAnimation
        property bool left: true
        running: false

        NumberAnimation {
            target: background.anchors
            property: "leftMargin"
            to: (root.width + root.dismissOvershoot) * (destroyAnimation.left ? -1 : 1)
            duration: Theme.anim.durations.sm
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Theme.anim.curves.emphasized
        }

        onFinished: () => {
            root.notifications.forEach(notif => {
                Qt.callLater(() => {
                    Notifications.discardNotification(notif.notificationId);
                });
            });
        }
    }

    Rectangle {
        id: background
        anchors.left: parent.left
        width: parent.width
        color: Colors.surface_container
        radius: Theme.ui.radius.md
        anchors.leftMargin: root.xOffset

        border {
            width: 1
            color: Qt.lighter(Colors.surface_container, 1.2)
        }

        Behavior on anchors.leftMargin {
            enabled: !dragManager.dragging
            NumberAnimation {
                duration: Theme.anim.durations.sm
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Theme.anim.curves.expressiveFastSpatial
            }
        }

        clip: true
        implicitHeight: root.expanded ? row.implicitHeight + padding * 2 : Math.min(90, row.implicitHeight + padding * 2)

        Behavior on implicitHeight {
            id: implicitHeightAnim
            enabled: !root.popup
            NumberAnimation {
                duration: Theme.anim.durations.xs
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Theme.anim.curves.emphasized
            }
        }

        RowLayout {
            id: row
            anchors.fill: parent
            spacing: 10

            NotificationAppIcon {
                Layout.leftMargin: root.padding
                Layout.topMargin: root.padding
                Layout.alignment: Qt.AlignTop
                Layout.fillWidth: false
                Layout.preferredWidth: implicitWidth
                Layout.preferredHeight: implicitHeight
                Layout.maximumWidth: implicitWidth
                Layout.maximumHeight: implicitHeight
                image: root?.multipleNotifications ? "" : root.notificationGroup?.notifications[0]?.image ?? ""
                appIcon: root.notificationGroup?.appIcon
                summary: root.notificationGroup?.notifications[root.notificationCount - 1]?.summary
                urgency: root.notifications.some(n => n.urgency === NotificationUrgency.Critical.toString()) ? NotificationUrgency.Critical : NotificationUrgency.Normal

                Behavior on Layout.preferredHeight {
                    NumberAnimation {
                        duration: Theme.anim.durations.sm
                        easing.type: Easing.BezierSpline
                        easing.bezierCurve: Theme.anim.curves.emphasized
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: root.expanded ? (root.multipleNotifications ? 5 : 0) : 0

                Behavior on spacing {
                    enabled: !root.popup
                    NumberAnimation {
                        duration: Theme.anim.durations.xs
                        easing.type: Easing.BezierSpline
                        easing.bezierCurve: Theme.anim.curves.emphasized
                    }
                }

                Item {
                    id: topRow
                    Layout.fillWidth: true
                    Layout.preferredHeight: implicitHeight
                    property real fontSize: Theme.font.size.md
                    property bool showAppName: root.multipleNotifications
                    implicitHeight: Math.max(topTextRow.implicitHeight, expandButton.implicitHeight)

                    RowLayout {
                        id: topTextRow
                        anchors.left: parent.left
                        anchors.right: expandButton.left
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 5

                        StyledText {
                            id: appName
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                            text: (topRow.showAppName ? root.notificationGroup?.appName : root.notificationGroup?.notifications[0]?.summary) || ""
                            font.pixelSize: topRow.showAppName ? topRow.fontSize : Theme.font.size.md
                            color: Colors.on_surface
                        }

                        StyledText {
                            id: timeText
                            Layout.rightMargin: 10
                            horizontalAlignment: Text.AlignLeft
                            text: NotificationUtils.getFriendlyNotifTimeString(root.notificationGroup?.time)
                            font.pixelSize: topRow.fontSize
                            color: Colors.on_surface_variant

                            opacity: 0.7
                        }
                    }

                    NotificationGroupExpandButton {
                        id: expandButton
                        visible: !root.popup
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.rightMargin: Theme.ui.padding.sm
                        count: root.notificationCount
                        expanded: root.expanded
                        fontSize: topRow.fontSize
                        onClicked: {
                            root.toggleExpanded();
                        }
                        onAltAction: {
                            root.toggleExpanded();
                        }
                    }
                }

                StyledListView {
                    id: notificationsColumn
                    Layout.topMargin: 15
                    implicitHeight: contentHeight
                    Layout.fillWidth: true
                    spacing: root.expanded ? 5 : 3
                    interactive: false

                    Behavior on spacing {
                        enabled: !root.popup
                        NumberAnimation {
                            duration: Theme.anim.durations.xs
                            easing.type: Easing.BezierSpline
                            easing.bezierCurve: Theme.anim.curves.emphasized
                        }
                    }

                    model: ScriptModel {
                        values: root.expanded ? root.notifications.slice().reverse() : root.notifications.slice().reverse().slice(0, 2)
                    }

                    delegate: NotificationItem {
                        required property int index
                        required property var modelData
                        notificationObject: modelData
                        expanded: root.expanded
                        onlyNotification: (root.notificationCount === 1)
                        singleChild: (root.notificationCount === 1)
                        opacity: (!root.expanded && index == 1 && root.notificationCount > 2) ? 0.5 : 1
                        visible: root.expanded || (index < 2)
                        anchors.left: parent?.left
                        anchors.right: parent?.right
                    }
                }
            }
        }
    }
}
