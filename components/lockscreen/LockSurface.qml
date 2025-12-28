import QtQuick
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

    anchors.fill: parent
    hoverEnabled: true
    acceptedButtons: Qt.AllButtons
    onPressed: mouse => {
        passwordField.textInput.forceActiveFocus();
    }
    Component.onCompleted: {
        forceFieldFocus();
    }
    Keys.onPressed: event => {
        const modifierKeys = [Qt.Key_Shift, Qt.Key_Control, Qt.Key_Alt, Qt.Key_Meta, Qt.Key_CapsLock, Qt.Key_NumLock, Qt.Key_ScrollLock, Qt.Key_AltGr, Qt.Key_Super_L, Qt.Key_Super_R];
        if (modifierKeys.includes(event.key)) {
            event.accepted = false;
            return;
        }
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
        showTitle: false
        anchors {
            top: parent.top
            right: parent.right
        }

        implicitWidth: 100
    }

    LockToolbar {
        id: mainToolbar

        anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: parent.bottom
            bottomMargin: 40
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
}
