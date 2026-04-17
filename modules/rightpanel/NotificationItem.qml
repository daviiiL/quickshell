pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.common
import qs.services

Rectangle {
    id: root

    required property var notif  // Notifications.Notif wrapper

    readonly property string title: root.notif.summary && root.notif.summary.length > 0
                                      ? root.notif.summary
                                      : (root.notif.appName || "")
    readonly property string message: root.notif.body || ""
    readonly property string subLabel: {
        const u = (root.notif.urgency || "").toString().toLowerCase();
        if (u.indexOf("critical") !== -1) return "urgent";
        return root.notif.appName || "";
    }
    readonly property bool isUnread: (Date.now() - (root.notif.time || 0)) < 1000 * 60 * 60 * 6

    Layout.fillWidth: true
    implicitHeight: itemRow.implicitHeight + 20
    color: ma.containsMouse ? Colors.surfaceContainerLow : "transparent"
    Behavior on color { ColorAnimation { duration: Theme.anim.durations.xs } }

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: Theme.ui.mainBarHairWidth
        color: Colors.hair
    }

    Rectangle {
        visible: root.isUnread
        x: 38
        anchors.verticalCenter: parent.verticalCenter
        width: 2
        height: parent.height - 20
        color: Colors.barAccent
        opacity: 0.55
    }

    RowLayout {
        id: itemRow
        anchors.fill: parent
        anchors.leftMargin: 48
        anchors.rightMargin: 14
        anchors.topMargin: 10
        anchors.bottomMargin: 10
        spacing: 10

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 3

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Text {
                    text: root.title
                    color: Colors.fgSurface
                    font.family: Theme.font.family.inter_medium
                    font.pixelSize: 12
                    font.weight: Font.Medium
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }

                Text {
                    visible: root.subLabel.length > 0
                    text: root.subLabel.toUpperCase()
                    color: Colors.inkDimmer
                    font.family: Theme.font.family.inter_medium
                    font.pixelSize: 10
                    font.letterSpacing: 1.4
                }
            }

            Text {
                visible: root.message.length > 0
                Layout.fillWidth: true
                text: root.message
                color: Colors.inkDim
                font.family: Theme.font.family.inter_regular
                font.pixelSize: 11
                lineHeight: 1.35
                wrapMode: Text.Wrap
                elide: Text.ElideRight
                maximumLineCount: 2
            }
        }

        ColumnLayout {
            Layout.alignment: Qt.AlignTop
            spacing: 2

            Text {
                text: root.formatRelativeTime(root.notif.time)
                color: Colors.inkDimmer
                font.family: Theme.font.family.inter_regular
                font.pixelSize: 10
                font.letterSpacing: 0.4
            }

            Text {
                text: "×"
                color: dismissMa.containsMouse ? Colors.fgSurface : Colors.inkFaint
                opacity: ma.containsMouse ? 1 : 0
                font.pixelSize: 14
                horizontalAlignment: Text.AlignRight
                Layout.alignment: Qt.AlignRight
                Behavior on opacity { NumberAnimation { duration: 150 } }
                Behavior on color  { ColorAnimation  { duration: 150 } }

                MouseArea {
                    id: dismissMa
                    anchors.fill: parent
                    anchors.margins: -6
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Notifications.discardNotification(root.notif.notificationId)
                }
            }
        }
    }

    MouseArea {
        id: ma
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.NoButton
    }

    function formatRelativeTime(t) {
        if (!t) return "";
        const diff = Math.max(0, Date.now() - t);
        const m = Math.floor(diff / 60000);
        if (m < 1)   return "now";
        if (m < 60)  return m + "m";
        const h = Math.floor(m / 60);
        if (h < 24)  return h + "h";
        const d = Math.floor(h / 24);
        return d + "d";
    }
}
