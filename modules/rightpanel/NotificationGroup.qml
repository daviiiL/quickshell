pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.common
import qs.services
import qs.widgets

Item {
    id: root

    required property var group
    property bool open: false
    readonly property int count: (root.group.notifications || []).length
    readonly property var latest: root.count > 0 ? root.group.notifications[0] : null
    readonly property bool hasUnread: (Date.now() - (root.group.time || 0)) < 1000 * 60 * 60 * 6

    readonly property real dragThreshold: 6
    readonly property real dismissThreshold: 80
    readonly property real dismissOvershoot: 40
    property real slideX: 0
    property bool dismissing: false

    implicitHeight: (dismissing ? collapseHeight : (head.implicitHeight + bodyWrap.height))
    property real collapseHeight: head.implicitHeight + bodyWrap.height
    Layout.fillWidth: true
    clip: true

    Behavior on implicitHeight {
        enabled: root.dismissing
        NumberAnimation {
            duration: Theme.anim.durations.xs
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Theme.anim.curves.standard
        }
    }

    transform: Translate {
        x: root.slideX
        Behavior on x {
            enabled: !headDrag.dragging
            NumberAnimation {
                duration: Theme.anim.durations.sm
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Theme.anim.curves.emphasized
            }
        }
    }

    opacity: root.dismissing ? 0 : Math.max(0.25, 1 - Math.abs(root.slideX) / (root.width || 320))
    Behavior on opacity {
        enabled: !headDrag.dragging
        NumberAnimation { duration: Theme.anim.durations.sm }
    }

    SequentialAnimation {
        id: dismissAnim
        property bool toLeft: false

        ParallelAnimation {
            NumberAnimation {
                target: root
                property: "slideX"
                to: (root.width + root.dismissOvershoot) * (dismissAnim.toLeft ? -1 : 1)
                duration: Theme.anim.durations.sm
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Theme.anim.curves.emphasizedAccel
            }
            NumberAnimation {
                target: root
                property: "opacity"
                to: 0
                duration: Theme.anim.durations.sm
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Theme.anim.curves.standard
            }
        }
        PropertyAction { target: root; property: "dismissing"; value: true }
        PauseAnimation { duration: Theme.anim.durations.xs }
        ScriptAction {
            script: {
                const notifs = root.group.notifications || [];
                notifs.forEach(n => {
                    if (n && n.notificationId !== undefined)
                        Notifications.discardNotification(n.notificationId);
                });
            }
        }
    }

    function dismiss(toLeft) {
        dismissAnim.toLeft = toLeft === true;
        dismissAnim.running = true;
    }

    Rectangle {
        visible: root.hasUnread && !root.dismissing
        anchors.left: parent.left
        y: 12
        width: 2
        height: head.implicitHeight - 24
        color: Colors.barAccent
    }

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: Theme.ui.mainBarHairWidth
        color: Colors.hair
    }

    Rectangle {
        id: head
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        implicitHeight: headRow.implicitHeight + 24
        color: headDrag.containsMouse && !headDrag.dragging ? Colors.surfaceContainerLow : "transparent"
        Behavior on color { ColorAnimation { duration: Theme.anim.durations.xs } }

        RowLayout {
            id: headRow
            anchors.fill: parent
            anchors.leftMargin: 14
            anchors.rightMargin: 14
            anchors.topMargin: 12
            anchors.bottomMargin: 12
            spacing: 10

            Rectangle {
                Layout.preferredWidth: 24
                Layout.preferredHeight: 24
                Layout.alignment: Qt.AlignTop
                radius: 4
                color: Colors.surfaceContainerHigh
                border.color: Colors.hair
                border.width: Theme.ui.mainBarHairWidth

                Text {
                    anchors.centerIn: parent
                    text: (root.group.appName || "?").substring(0, 1).toUpperCase()
                    color: Colors.barAccent
                    font.family: Theme.font.family.inter_medium
                    font.pixelSize: 11
                    font.weight: Font.Medium
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 3

                RowLayout {
                    spacing: 8
                    Layout.fillWidth: true

                    Text {
                        text: (root.group.appName || "").toUpperCase()
                        color: Colors.fgSurface
                        font.family: Theme.font.family.inter_medium
                        font.pixelSize: 10
                        font.letterSpacing: 1.4
                        font.weight: Font.Medium
                    }

                    Rectangle {
                        visible: root.count > 1 || root.hasUnread
                        Layout.preferredHeight: 16
                        implicitWidth: countText.implicitWidth + 10
                        radius: 2
                        color: "transparent"
                        border.color: Colors.hair
                        border.width: Theme.ui.mainBarHairWidth

                        Text {
                            id: countText
                            anchors.centerIn: parent
                            text: root.count + (root.hasUnread ? " new" : "")
                            color: Colors.inkDim
                            font.family: Theme.font.family.inter_regular
                            font.pixelSize: 10
                            font.letterSpacing: 0.4
                        }
                    }

                    Item { Layout.fillWidth: true }
                }

                Text {
                    Layout.fillWidth: true
                    visible: root.latest !== null
                    text: (root.latest?.summary || "") +
                          (root.latest?.body ? (root.latest?.summary ? " — " : "") + root.latest.body : "")
                    color: Colors.fgSurface
                    font.family: Theme.font.family.inter_regular
                    font.pixelSize: 12
                    elide: Text.ElideRight
                    maximumLineCount: 1
                }
            }

            Text {
                Layout.alignment: Qt.AlignTop
                text: head.formatRelativeTime(root.group.time)
                color: Colors.inkDimmer
                font.family: Theme.font.family.inter_regular
                font.pixelSize: 10
                font.letterSpacing: 0.4
            }

            MaterialSymbol {
                Layout.alignment: Qt.AlignTop
                Layout.topMargin: 2
                icon: "chevron_right"
                iconSize: 12
                fontColor: root.open ? Colors.fgSurface : Colors.inkDimmer
                colorAnimated: true

                rotation: root.open ? 90 : 0
                Behavior on rotation {
                    NumberAnimation { duration: Theme.anim.durations.xs; easing.type: Easing.OutCubic }
                }
            }
        }

        DragManager {
            id: headDrag
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            automaticallyReset: false

            onDragPressed: (diffX, diffY) => {
                if (!root.dismissing) {
                    root.slideX = diffX;
                }
            }

            onDragReleased: (diffX, diffY) => {
                if (root.dismissing) return;
                const absX = Math.abs(diffX);
                const absY = Math.abs(diffY);
                if (absX < root.dragThreshold && absY < root.dragThreshold) {
                    root.open = !root.open;
                    root.slideX = 0;
                    headDrag.resetDrag();
                    return;
                }
                if (absX > root.dismissThreshold) {
                    root.dismiss(diffX < 0);
                } else {
                    root.slideX = 0;
                }
                headDrag.resetDrag();
            }
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

    Item {
        id: bodyWrap
        anchors.top: head.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        clip: true
        height: root.open && !root.dismissing ? Math.min(body.implicitHeight, 220) : 0
        Behavior on height {
            NumberAnimation {
                duration: Theme.anim.durations.sm
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Theme.anim.curves.standard
            }
        }

        Flickable {
            anchors.fill: parent
            contentWidth: width
            contentHeight: body.implicitHeight
            clip: true
            boundsBehavior: Flickable.StopAtBounds

            ColumnLayout {
                id: body
                width: parent.width
                spacing: 0

                Repeater {
                    model: root.group.notifications

                    NotificationItem {
                        required property var modelData
                        notif: modelData
                    }
                }
            }
        }
    }
}
