pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pam
import qs

Singleton {
    id: root

    signal shouldReFocus
    signal unlocked
    signal failed

    property string currentPassword: ""
    property bool unlockInProgress: false
    property bool showFailure: false
    property bool fingerprintsConfigured: false

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
        stopFingerPam();
    }

    function tryUnlock() {
        root.unlockInProgress = true;
        pam.start();
    }

    function tryFingerprintUnlock() {
        if (root.fingerprintsConfigured) {
            fingerPam.start();
        }
    }

    function stopFingerPam() {
        if (fingerPam.running) {
            fingerPam.abort();
        }
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

    Process {
        id: fingerprintCheckProc
        running: true
        command: ["bash", "-c", "fprintd-list $(whoami)"]
        stdout: StdioCollector {
            id: fingerprintOutputCollector
            onStreamFinished: {
                root.fingerprintsConfigured = fingerprintOutputCollector.text.includes("Fingerprints for user");
            }
        }
        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0) {
                root.fingerprintsConfigured = false;
            }
        }
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
                stopFingerPam();
            } else {
                root.clearPassword();
                root.unlockInProgress = false;
                GlobalStates.screenUnlockFailed = true;
                root.showFailure = true;
                root.failed();
            }
        }
    }

    PamContext {
        id: fingerPam

        configDirectory: "pam"
        config: "fprintd.conf"

        onCompleted: result => {
            if (result == PamResult.Success) {
                root.unlocked();
                stopFingerPam();
            } else if (result == PamResult.Error) {
                tryFingerprintUnlock();
            }
        }
    }
}
