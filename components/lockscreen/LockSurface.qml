pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.common
import qs.services
import qs.components
import qs.components.lockscreen

MouseArea {
    id: root

    readonly property string username: {
        const user = Quickshell.env("USER");
        return user || "user";
    }

    function forceFieldFocus() {
        passwordField.textInput.forceActiveFocus();
    }

    function onActivity() {
        if (GlobalStates.isLaptop) {
            batteryCard.visible = true;
            batteryCard.opacity = 1.0;
        }
        if (SystemMpris.players.length > 0) {
            mediaControls.visible = true;
            mediaControls.opacity = 1.0;
        }
        mainToolbar.visible = true;
        mainToolbar.opacity = 1.0;
        hideComponentsTimer.restart();
    }

    anchors.fill: parent
    hoverEnabled: true
    acceptedButtons: Qt.AllButtons
    onPressed: mouse => {
        root.onActivity();
        passwordField.textInput.forceActiveFocus();
    }
    Component.onCompleted: {
        forceFieldFocus();
        root.onActivity();
    }
    Keys.onPressed: event => {
        const modifierKeys = [Qt.Key_Shift, Qt.Key_Control, Qt.Key_Alt, Qt.Key_Meta, Qt.Key_CapsLock, Qt.Key_NumLock, Qt.Key_ScrollLock, Qt.Key_AltGr, Qt.Key_Super_L, Qt.Key_Super_R];
        if (modifierKeys.includes(event.key)) {
            event.accepted = false;
            return;
        }

        root.onActivity();
        Authentication.resetClearTimer();
        root.forceFieldFocus();
        event.accepted = false;
    }

    LockClock {}

    Connections {
        function onShouldReFocus() {
            root.forceFieldFocus();
        }

        target: Authentication
    }

    BatteryCard {
        id: batteryCard
        showTitle: false
        anchors {
            top: parent.top
            right: parent.right
            leftMargin: Theme.ui.padding.lg
            rightMargin: Theme.ui.padding.lg
        }

        implicitWidth: 100

        Behavior on opacity {
            NumberAnimation {
                duration: 300
                easing.type: Easing.InOutQuad
                onFinished: {
                    if (batteryCard.opacity === 0) {
                        batteryCard.visible = false;
                    }
                }
            }
        }
    }

    ColumnLayout {
        id: mediaControls
        visible: SystemMpris.players.length > 0

        anchors {
            top: batteryCard.bottom
            right: root.right
            topMargin: Theme.ui.padding.lg
            rightMargin: Theme.ui.padding.lg
        }

        width: 400
        spacing: 12

        Repeater {
            model: SystemMpris.players
            delegate: PlayerControl {
                required property var modelData
                player: modelData
                Layout.fillWidth: true
                implicitHeight: 200
            }
        }

        Behavior on opacity {
            NumberAnimation {
                duration: 300
                easing.type: Easing.InOutQuad
                onFinished: {
                    if (mediaControls.opacity === 0) {
                        mediaControls.visible = false;
                    }
                }
            }
        }
    }

    LockToolbar {
        id: mainToolbar

        border {
            width: 1
            color: Colors.outline_variant
        }

        anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: parent.bottom
            bottomMargin: 40
        }

        Behavior on opacity {
            NumberAnimation {
                duration: 300
                easing.type: Easing.InOutQuad
                onFinished: {
                    if (mainToolbar.opacity === 0) {
                        mainToolbar.visible = false;
                    }
                }
            }
        }

        LockTextField {
            id: passwordField

            implicitWidth: 300
            placeholderText: GlobalStates.screenUnlockFailed ? "Try again" : "Enter password"
        }

        LockButton {
            icon: "arrow_right_alt"
            isActive: true
            enabled: !Authentication.unlockInProgress && Authentication.currentPassword.length > 0
            onClicked: {
                Authentication.tryUnlock();
            }
        }
    }

    Connections {
        target: passwordField.textInput

        function onTextChanged() {
            if (GlobalStates.isLaptop) {
                batteryCard.visible = true;
                batteryCard.opacity = 1.0;
            }
            if (SystemMpris.players.length > 0) {
                mediaControls.visible = true;
                mediaControls.opacity = 1.0;
            }
            mainToolbar.visible = true;
            mainToolbar.opacity = 1.0;
            hideComponentsTimer.restart();
        }
    }

    Timer {
        id: hideComponentsTimer
        interval: 30000

        repeat: false
        onTriggered: {
            batteryCard.opacity = 0;
            mediaControls.opacity = 0;
            mainToolbar.opacity = 0;
        }
    }

    onPositionChanged: {
        root.onActivity();
    }

    Component.onDestruction: {
        hideComponentsTimer.stop();
    }
}
