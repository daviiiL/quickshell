pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pam

import qs.common

Singleton {
    id: root

    signal shouldReFocus
    signal unlocked
    signal failed

    property string currentPassword: ""
    property bool unlockInProgress: false
    property bool showFailure: false

    function resetTargetAction() {
    }

    function clearPassword() {
        root.currentPassword = "";
    }

    function resetClearTimer() {
        passwordClearTimer.restart();
    }

    function reset() {
        root.resetTargetAction();
        root.clearPassword();
        root.unlockInProgress = false;
    }

    function tryUnlock() {
        root.unlockInProgress = true;
        pam.start();
    }

    Timer {
        id: passwordClearTimer
        interval: 10000
        onTriggered: {
            root.reset();
        }
    }

    onCurrentPasswordChanged: {
        if (currentPassword.length > 0) {
            showFailure = false;
            GlobalStates.screenUnlockFailed = false;
        }
        GlobalStates.screenLockContainsCharacters = currentPassword.length > 0;
        passwordClearTimer.restart();
    }

    PamContext {
        id: pam

        onPamMessage: {
            if (this.responseRequired) {
                this.respond(root.currentPassword);
            }
        }

        onCompleted: result => {
            if (result == PamResult.Success) {
                root.unlocked();
            } else {
                root.clearPassword();
                root.unlockInProgress = false;
                GlobalStates.screenUnlockFailed = true;
                root.showFailure = true;
                root.failed();
            }
        }
    }
}
