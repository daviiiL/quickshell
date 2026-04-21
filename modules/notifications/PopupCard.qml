pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.common
import qs.services

Rectangle {
    id: root

    required property var card   // { id, notif, mergeCount, ... } from PopupStackController
    property string role: "active"   // "active" | "peek1" | "peek2" | "dismissing"

    signal dismissRequested(int id, string reason)
    signal defaultActionRequested(int id)
    signal pauseRequested(int id)
    signal resumeRequested(int id)

    width: 340
    implicitHeight: Math.max(72, layout.implicitHeight)
    radius: 4

    readonly property real slotYOffset: role === "peek1" ? 14 : role === "peek2" ? 28 : 0
    readonly property real slotScale:   role === "peek1" ? 0.96 : role === "peek2" ? 0.92 : 1.0
    readonly property int  slotZ: {
        if (isActiveOrDismissing) return 100;
        if (role === "peek1") return 99;
        if (role === "peek2") return 98;
        return 0;
    }
    readonly property bool isActiveOrDismissing: role === "active" || role === "dismissing"
    property bool exiting: false
    property real dragTranslateX: 0
    signal exitFinished(int id)

    z: slotZ
    transformOrigin: Item.TopRight
    scale: slotScale
    transform: [
        Translate {
            x: root.dragTranslateX
            Behavior on x {
                enabled: !clickArea.dragging
                NumberAnimation { duration: 120; easing.type: Easing.OutCubic }
            }
        },
        Translate {
            y: root.slotYOffset
            Behavior on y {
                NumberAnimation {
                    duration: Theme.anim.durations.promote
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: Theme.anim.curves.standard
                }
            }
        },
        Translate {
            id: exitTranslate
            y: 0
        }
    ]

    onExitingChanged: if (exiting) exitAnim.start()

    SequentialAnimation {
        id: exitAnim
        ParallelAnimation {
            NumberAnimation {
                target: exitTranslate
                property: "y"
                to: -80
                duration: Theme.anim.durations.dismissPopup
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Theme.anim.curves.emphasized
            }
            NumberAnimation {
                target: root
                property: "dragOpacityFactor"
                to: 0
                duration: Theme.anim.durations.dismissPopup
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Theme.anim.curves.emphasized
            }
        }
        ScriptAction { script: root.exitFinished(root.card.id) }
    }

    Behavior on scale {
        NumberAnimation {
            duration: Theme.anim.durations.promote
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Theme.anim.curves.standard
        }
    }
    Behavior on color {
        ColorAnimation { duration: Theme.anim.durations.promote }
    }
    Behavior on border.color {
        ColorAnimation { duration: Theme.anim.durations.promote }
    }

    color: isActiveOrDismissing    ? Colors.panelBg
         : role === "peek1"        ? Colors.surfaceContainerHigh
         : Colors.surfaceContainer
    border.color: urgency === "critical" ? Colors.criticalHalo
                : isActiveOrDismissing   ? Colors.hair
                : Colors.hairHot
    border.width: 1

    readonly property string urgency: root.card.urgency ?? "normal"

    readonly property var    _notif:   root.card.notif
    readonly property string summary: (_notif?.summary ?? "").length > 0 ? _notif.summary : (_notif?.appName ?? "")
    readonly property string body:    _notif?.body ?? ""
    readonly property string appName: _notif?.appName ?? ""
    readonly property string imageSrc: (_notif?.image ?? "").length > 0 ? _notif.image : (_notif?.appIcon ?? "")

    property real dragOpacityFactor: 1.0
    opacity: (urgency === "low" ? 0.78 : 1.0) * dragOpacityFactor

    MouseArea {
        id: clickArea
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.MiddleButton
        hoverEnabled: false

        property real dragStartX: 0
        property bool dragging: false
        property real dragOffset: 0

        onPressed: mouse => {
            dragStartX = mouse.x;
            dragging = false;
            dragOffset = 0;
        }
        onPositionChanged: mouse => {
            const dx = mouse.x - dragStartX;
            if (dx > 4) dragging = true;
            if (dragging) {
                dragOffset = Math.max(0, dx);
                root.dragTranslateX = dragOffset;
                root.dragOpacityFactor = Math.max(0, 1.0 - dragOffset / 120);
            }
        }
        onReleased: mouse => {
            if (dragging && dragOffset >= 40) {
                root.dismissRequested(root.card.id, "drag");
            } else {
                dragOffset = 0;
                root.dragTranslateX = 0;
                root.dragOpacityFactor = 1.0;
            }
            dragging = false;
        }
        onClicked: mouse => {
            if (dragging) return;
            if (mouse.button === Qt.MiddleButton) {
                root.dismissRequested(root.card.id, "middle-click");
            } else if (mouse.button === Qt.LeftButton) {
                if (root.role === "active") {
                    root.defaultActionRequested(root.card.id);
                } else {
                    root.dismissRequested(root.card.id, "peek-click");
                }
            }
        }
    }

    ColumnLayout {
        id: layout
        anchors.fill: parent
        spacing: 0

        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: root.urgency === "critical" ? 26 : 12
            Layout.rightMargin: 12
            Layout.topMargin: 11
            Layout.bottomMargin: 8
            spacing: 10

            Rectangle {
                Layout.preferredWidth: 22
                Layout.preferredHeight: 22
                radius: 3
                color: urgency === "critical" ? Colors.criticalChipFill : Colors.surfaceContainerHigh
                border.color: urgency === "critical" ? Colors.criticalHalo : Colors.hair
                border.width: 1
                Text {
                    anchors.centerIn: parent
                    text: (root.appName.length > 0 ? root.appName[0] : "?").toUpperCase()
                    color: urgency === "critical" ? Colors.error : Colors.primary
                    font.pixelSize: 10
                    font.family: Theme.font.family.inter_medium
                    font.weight: Font.Medium
                }
            }

            Text {
                Layout.fillWidth: true
                text: root.appName.toUpperCase()
                elide: Text.ElideRight
                color: Colors.inkDimmer
                font.pixelSize: 10
                font.family: Theme.font.family.inter_medium
                font.weight: Font.Medium
                font.letterSpacing: 1.8
            }

            Rectangle {
                visible: root.card.mergeCount > 0
                Layout.preferredHeight: 16
                Layout.preferredWidth: countText.implicitWidth + 10
                radius: 8
                color: Colors.surfaceContainerHigh
                border.color: Colors.hair
                border.width: 1
                Text {
                    id: countText
                    anchors.centerIn: parent
                    text: "+" + (root.card.mergeCount + 1)
                    color: Colors.inkDim
                    font.pixelSize: 9
                    font.family: Theme.font.family.inter_medium
                    font.weight: Font.Medium
                }
            }

            Text {
                text: StringUtils.relativeTime(_notif?.time ?? Date.now())
                color: Colors.inkDimmer
                font.pixelSize: 10
                font.family: Theme.font.family.inter_regular
            }

            Text {
                text: "×"
                color: dismissMa.containsMouse ? Colors.fgSurface : Colors.inkFaint
                font.pixelSize: 14
                MouseArea {
                    id: dismissMa
                    anchors.fill: parent
                    anchors.margins: -6
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.dismissRequested(root.card.id, "user-x")
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: root.urgency === "critical" ? 26 : 12
            Layout.rightMargin: 12
            Layout.bottomMargin: 12
            spacing: 12

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4

                Text {
                    Layout.fillWidth: true
                    text: root.summary
                    color: Colors.fgSurface
                    font.pixelSize: 13
                    font.family: urgency === "low" ? Theme.font.family.inter_regular : Theme.font.family.inter_medium
                    font.weight: urgency === "low" ? Font.Normal : Font.Medium
                    elide: Text.ElideRight
                }

                Text {
                    Layout.fillWidth: true
                    visible: root.body.length > 0
                    text: root.body
                    color: root.role === "active" ? Colors.inkDim : Colors.inkDimmer
                    font.pixelSize: 11
                    font.family: Theme.font.family.inter_regular
                    wrapMode: Text.Wrap
                    lineHeight: 1.4
                    maximumLineCount: 2
                    elide: Text.ElideRight
                }
            }

            Rectangle {
                visible: root.imageSrc.length > 0
                      && (root.urgency !== "critical" || (_notif?.image ?? "").length > 0)
                Layout.preferredWidth: 56
                Layout.preferredHeight: 56
                radius: 3
                color: "transparent"
                border.color: Colors.hair
                border.width: 1
                clip: true
                Image {
                    anchors.fill: parent
                    anchors.margins: 1
                    source: root.imageSrc
                    fillMode: Image.PreserveAspectCrop
                }
            }
        }
    }

    Rectangle {
        id: progressBar
        visible: root.role === "active" && root.urgency !== "critical"
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        height: 1
        color: Colors.primary
        opacity: 0.9
        width: parent.width * progressFraction

        property real progressFraction: 1.0

        NumberAnimation on progressFraction {
            id: progressAnim
            from: 1.0
            to: 0.0
            duration: Math.max(root.card.timeoutMs ?? 7000, 1)
            running: root.role === "active" && root.urgency !== "critical"
        }
    }

    Rectangle {
        visible: root.urgency === "critical"
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        width: 2
        height: parent.height - 16
        color: Colors.error
        radius: 1
    }

    Rectangle {
        visible: root.isActiveOrDismissing
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        width: 1
        height: 100
        z: 4
        gradient: Gradient {
            orientation: Gradient.Vertical
            GradientStop { position: 0.0; color: "transparent" }
            GradientStop { position: 1.0; color: Colors.hairCatch }
        }
    }

    Rectangle {
        visible: root.isActiveOrDismissing
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        width: 110
        height: 1
        z: 4
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: "transparent" }
            GradientStop { position: 1.0; color: Colors.hairCatch }
        }
    }

    MouseArea {
        id: hoverArea
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.NoButton
        propagateComposedEvents: true
        onEntered: if (root.role === "active" && root.urgency !== "critical") {
            progressAnim.paused = true;
            root.pauseRequested(root.card.id);
        }
        onExited: if (root.role === "active" && root.urgency !== "critical") {
            progressAnim.paused = false;
            root.resumeRequested(root.card.id);
        }
    }
}
