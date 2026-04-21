pragma ComponentBehavior: Bound

import QtQuick
import qs.common
import qs.services

Item {
    id: root

    implicitHeight: column.implicitHeight
    implicitWidth: 560

    property bool cooldown: false
    property int cooldownRemaining: 0

    Timer {
        id: cooldownTimer
        interval: 1000
        repeat: true
        onTriggered: {
            root.cooldownRemaining--;
            if (root.cooldownRemaining <= 0) {
                root.cooldown = false;
                cooldownTimer.stop();
            }
        }
    }

    Rectangle {
        id: accent
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: 2
        color: Colors.barAccent
    }

    Column {
        id: column
        anchors.left: accent.right
        anchors.right: parent.right
        anchors.leftMargin: 10
        spacing: 8

        Text {
            id: label
            text: root.cooldown
                    ? ("RETRY IN " + root.cooldownRemaining)
                    : (Authentication.showFailure ? "INCORRECT" : "PASSWORD")
            font.pixelSize: 14
            font.letterSpacing: 2.5
            font.family: Theme.font.family.inter_regular
            color: (root.cooldown || Authentication.showFailure)
                     ? Colors.fgError
                     : Colors.inkDimmer
        }

        Rectangle {
            id: field
            width: parent.width
            height: 46
            radius: Theme.ui.radius.sm
            border.width: 1
            border.color: Colors.hairHot
            color: Colors.surfaceContainerLow

            transform: Translate { id: shake; x: 0 }

            TextInput {
                id: input
                anchors.fill: parent
                leftPadding: 14
                rightPadding: 14
                verticalAlignment: TextInput.AlignVCenter
                echoMode: TextInput.Password
                color: Colors.fgSurface
                selectionColor: Colors.barAccent
                selectedTextColor: Colors.surfaceContainerLowest
                font.pixelSize: 16
                font.family: Theme.font.family.inter_regular

                text: Authentication.currentPassword
                onTextChanged: {
                    if (text !== Authentication.currentPassword)
                        Authentication.currentPassword = text;
                }

                Keys.onReturnPressed: {
                    if (input.text.length > 0 && !Authentication.unlockInProgress && !root.cooldown)
                        Authentication.tryUnlock();
                }
                Keys.onEnterPressed: {
                    if (input.text.length > 0 && !Authentication.unlockInProgress && !root.cooldown)
                        Authentication.tryUnlock();
                }
                Keys.onEscapePressed: Authentication.reset()

                Component.onCompleted: input.forceActiveFocus()
            }
        }
    }

    Connections {
        target: Authentication

        function onShouldReFocus(): void {
            input.forceActiveFocus();
        }

        function onFailed(): void {
            failAnim.restart();
            root.cooldown = true;
            root.cooldownRemaining = 5;
            cooldownTimer.restart();
            input.forceActiveFocus();
        }

        function onUnlocked(): void {
            successAnim.restart();
        }
    }

    ParallelAnimation {
        id: failAnim

        SequentialAnimation {
            NumberAnimation { target: shake; property: "x"; to:  8; duration: 50; easing.type: Easing.OutQuad }
            NumberAnimation { target: shake; property: "x"; to: -8; duration: 50; easing.type: Easing.OutQuad }
            NumberAnimation { target: shake; property: "x"; to:  6; duration: 50; easing.type: Easing.OutQuad }
            NumberAnimation { target: shake; property: "x"; to: -6; duration: 50; easing.type: Easing.OutQuad }
            NumberAnimation { target: shake; property: "x"; to:  3; duration: 40; easing.type: Easing.OutQuad }
            NumberAnimation { target: shake; property: "x"; to: -3; duration: 40; easing.type: Easing.OutQuad }
            NumberAnimation { target: shake; property: "x"; to:  0; duration: 40; easing.type: Easing.OutQuad }
        }

        SequentialAnimation {
            ColorAnimation { target: accent; property: "color"; to: Colors.fgError; duration: 80 }
            PauseAnimation { duration: 200 }
            ColorAnimation { target: accent; property: "color"; to: Colors.barAccent; duration: 300 }
        }

        SequentialAnimation {
            ColorAnimation { target: field; property: "border.color"; to: Colors.fgError; duration: 80 }
            PauseAnimation { duration: 200 }
            ColorAnimation { target: field; property: "border.color"; to: Colors.hairHot; duration: 300 }
        }
    }

    SequentialAnimation {
        id: successAnim
        ColorAnimation { target: accent; property: "color"; to: Colors.live; duration: 120 }
        PauseAnimation { duration: 150 }
        ColorAnimation { target: accent; property: "color"; to: Colors.barAccent; duration: 250 }
    }
}
