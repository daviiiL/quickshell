pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
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

    function clearPassword() {
        root.currentPassword = "";
    }

    function reset() {
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
        onTriggered: root.reset()
    }

    onCurrentPasswordChanged: {
        if (currentPassword.length > 0)
            showFailure = false;
        passwordClearTimer.restart();
    }

    PamContext {
        id: pam

        onPamMessage: {
            if (this.responseRequired)
                this.respond(root.currentPassword);
        }

        onCompleted: result => {
            if (result == PamResult.Success) {
                root.unlocked();
                Quickshell.execDetached(["bash", "-c", Quickshell.shellPath("scripts/startup-sound.sh")]);
            } else {
                root.clearPassword();
                root.unlockInProgress = false;
                root.showFailure = true;
                root.failed();
            }
        }
    }
}
