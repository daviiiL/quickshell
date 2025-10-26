import QtQuick
import QtQuick.Layouts
import "../common"
import "../services"
import "./widgets"
import "./notification"

Item {
    id: root
    required property var scopeRoot
    property int sidebarPadding: Theme.ui.padding.large
    anchors.fill: parent

    function focusActiveItem() {
        contentColumn.forceActiveFocus();
    }

    Keys.onPressed: event => {
        if (event.key === Qt.Key_Escape) {
            GlobalStates.sidebarLeftOpen = false;
            event.accepted = true;
        }
    }

    ColumnLayout {
        id: contentColumn
        anchors.fill: parent
        anchors.margins: sidebarPadding
        spacing: sidebarPadding

        // Header
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 40
            radius: Theme.rounding.small

            color: "transparent"
            Text {
                anchors.centerIn: parent
                text: "Notifications"
                font.pixelSize: Theme.font.size.large
                font.family: Theme.font.style.departureMono
                color: Colors.current.secondary
            }
        }

        // Notification list
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "transparent"
            radius: Theme.rounding.small
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

            // Placeholder when list is empty
            Item {
                anchors.fill: listview
                visible: opacity > 0
                opacity: (Notifications.list.length === 0) ? 1 : 0

                Behavior on opacity {
                    NumberAnimation {
                        duration: Theme.anim.durations.normal
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
                        fontColor: Colors.current.outline
                        icon: "empty_dashboard"
                    }

                    StyledText {
                        Layout.alignment: Qt.AlignHCenter
                        font.pixelSize: Theme.font.size.large
                        color: Colors.current.outline
                        horizontalAlignment: Text.AlignHCenter
                        text: "All caught up"
                    }
                }
            }

            // Status buttons row
            ButtonGroup {
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
}
