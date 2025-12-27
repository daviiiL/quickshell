import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Notifications
import qs.common
import qs.services
import qs.widgets
import qs.components

Item {
    id: root
    property var notificationObject
    property bool expanded: false
    property bool onlyNotification: false
    property real fontSize: Theme.font.size.md
    property real padding: onlyNotification ? 0 : 8
    property real summaryElideRatio: 0.85

    property real dragConfirmThreshold: 70
    property real dismissOvershoot: 50
    property var qmlParent: root?.parent?.parent
    property var parentDragIndex: qmlParent?.dragIndex ?? -1
    property var parentDragDistance: qmlParent?.dragDistance ?? 0
    property var dragIndexDiff: Math.abs(parentDragIndex - index)
    property real xOffset: dragIndexDiff == 0 ? parentDragDistance : Math.abs(parentDragDistance) > dragConfirmThreshold ? 0 : dragIndexDiff == 1 ? (parentDragDistance * 0.3) : dragIndexDiff == 2 ? (parentDragDistance * 0.1) : 0

    implicitHeight: background.implicitHeight

    function processNotificationBody(body, appName) {
        let processedBody = body;

        if (appName) {
            const lowerApp = appName.toLowerCase();
            const chromiumBrowsers = ["brave", "chrome", "chromium", "vivaldi", "opera", "microsoft edge"];

            if (chromiumBrowsers.some(name => lowerApp.includes(name))) {
                const lines = body.split('\n\n');

                if (lines.length > 1 && lines[0].startsWith('<a')) {
                    processedBody = lines.slice(1).join('\n\n');
                }
            }
        }

        return processedBody;
    }

    function destroyWithAnimation(left = false) {
        root.qmlParent.resetDrag();
        destroyAnimation.left = left;
        destroyAnimation.running = true;
    }

    TextMetrics {
        id: summaryTextMetrics
        font.pixelSize: root.fontSize
        text: root.notificationObject.summary || ""
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
            Notifications.discardNotification(notificationObject.notificationId);
        }
    }

    DragManager {
        id: dragManager
        anchors.fill: root
        anchors.leftMargin: 0
        interactive: expanded
        automaticallyReset: false
        acceptedButtons: Qt.LeftButton | Qt.MiddleButton

        onClicked: mouse => {
            if (mouse.button === Qt.MiddleButton) {
                root.destroyWithAnimation();
            }
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

    Rectangle {
        id: background
        width: parent.width
        radius: Theme.ui.radius.md
        anchors.leftMargin: root.xOffset

        Behavior on anchors.leftMargin {
            enabled: !dragManager.dragging
            NumberAnimation {
                duration: Theme.anim.durations.sm
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Theme.anim.curves.expressiveFastSpatial
            }
        }

        color: (expanded && !onlyNotification) ? (notificationObject.urgency == NotificationUrgency.Critical) ? Colors.error_container : Qt.rgba(Colors.primary.r, Colors.primary.g, Colors.primary.b, 0.12) : Qt.rgba(Colors.primary.r, Colors.primary.g, Colors.primary.b, 0.08)

        implicitHeight: expanded ? (contentColumn.implicitHeight + padding * 2) : summaryRow.implicitHeight

        Behavior on implicitHeight {
            NumberAnimation {
                duration: Theme.anim.durations.sm
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Theme.anim.curves.emphasized
            }
        }

        ColumnLayout {
            id: contentColumn
            anchors.fill: parent
            anchors.margins: expanded ? root.padding : 0
            spacing: 3

            Behavior on anchors.margins {
                NumberAnimation {
                    duration: Theme.anim.durations.xs
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: Theme.anim.curves.emphasized
                }
            }

            RowLayout {
                id: summaryRow
                visible: !root.onlyNotification || !root.expanded
                Layout.fillWidth: true
                implicitHeight: summaryText.implicitHeight

                StyledText {
                    id: summaryText
                    Layout.fillWidth: summaryTextMetrics.width >= summaryRow.implicitWidth * root.summaryElideRatio
                    visible: !root.onlyNotification
                    font.pixelSize: root.fontSize
                    color: Colors.on_primary_container
                    elide: Text.ElideRight
                    text: root.notificationObject.summary || ""
                }

                StyledText {
                    opacity: !root.expanded ? 1 : 0
                    visible: opacity > 0
                    Layout.fillWidth: true

                    Behavior on opacity {
                        NumberAnimation {
                            duration: Theme.anim.durations.xs
                            easing.type: Easing.BezierSpline
                            easing.bezierCurve: Theme.anim.curves.emphasized
                        }
                    }

                    font.pixelSize: root.fontSize
                    color: Colors.on_primary_container
                    elide: Text.ElideRight
                    wrapMode: Text.Wrap
                    maximumLineCount: 1
                    textFormat: Text.StyledText
                    text: {
                        return processNotificationBody(notificationObject.body, notificationObject.appName || notificationObject.summary).replace(/\n/g, "<br/>");
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                opacity: root.expanded ? 1 : 0
                visible: opacity > 0

                StyledText {
                    id: notificationBodyText
                    Layout.fillWidth: true
                    font.pixelSize: root.fontSize
                    color: root.notificationObject.urgency == NotificationUrgency.Critical ? Colors.on_error_container : Colors.on_primary_container
                    wrapMode: Text.Wrap
                    elide: Text.ElideRight
                    textFormat: Text.RichText
                    text: {
                        return processNotificationBody(notificationObject.body, notificationObject.appName || notificationObject.summary).replace(/\n/g, "<br/>");
                    }

                    onLinkActivated: link => {
                        Qt.openUrlExternally(link);
                        GlobalStates.sidebarOpen = false;
                    }
                }

                RowLayout {
                    id: actionRowLayout
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignBottom

                    NotificationActionButton {
                        Layout.fillWidth: true
                        buttonText: "Close"
                        urgency: notificationObject.urgency
                        onClicked: {
                            root.destroyWithAnimation();
                        }
                    }
                }
            }
        }
    }
}
