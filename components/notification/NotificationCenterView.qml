pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import qs.common
import qs.services
import qs.widgets
import qs.components.notification

ColumnLayout {
    id: contentColumn
    property int sidebarPadding: Theme.ui.padding.lg

    anchors.fill: parent
    anchors.margins: sidebarPadding
    spacing: sidebarPadding

    Rectangle {
        Layout.fillWidth: true
        Layout.fillHeight: true
        color: "transparent"
        radius: Theme.ui.radius.md
        clip: true

        NotificationListView {
            id: listview
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: statusRow.top
            anchors.margins: 5
            anchors.bottomMargin: 5

            popup: false
        }

        Item {
            anchors.fill: listview
            visible: opacity > 0
            opacity: (Notifications.list.length === 0) ? 1 : 0

            Behavior on opacity {
                NumberAnimation {
                    duration: Theme.anim.durations.sm
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: Theme.anim.curves.standard
                }
            }

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 5

                MaterialSymbol {
                    Layout.alignment: Qt.AlignHCenter
                    iconSize: 55
                    fontColor: Colors.outline
                    icon: "empty_dashboard"
                }

                StyledText {
                    Layout.alignment: Qt.AlignHCenter
                    font.pixelSize: Theme.font.size.lg
                    color: Colors.outline
                    horizontalAlignment: Text.AlignHCenter
                    text: "All caught up"
                }
            }
        }

        RowLayout {
            id: statusRow
            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom
                margins: 5
            }

            NotificationStatusButton {
                Layout.fillWidth: false
                Layout.preferredWidth: 40
                buttonIcon: "notifications_paused"
                toggled: Notifications.silent
                onClicked: () => {
                    Notifications.silent = !Notifications.silent;
                }
            }

            NotificationStatusButton {
                enabled: false
                Layout.fillWidth: true
                buttonText: Notifications.list.length + " notifications"
            }

            NotificationStatusButton {
                Layout.fillWidth: false
                Layout.preferredWidth: 40
                buttonIcon: "delete_sweep"
                onClicked: () => {
                    Notifications.discardAllNotifications();
                }
            }
        }
    }
}
