pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

import qs.common
import qs.services
import qs.modules.lockscreen

Scope {
    id: root

    Process {
        id: unlockKeyringProc
        property string pending: ""
        command: ["bash", Quickshell.shellPath("scripts/keyring/unlock.sh")]
        onStarted: {
            if (pending.length > 0) {
                write(pending + "\n");
                pending = "";
            }
            stdinEnabled = false;
        }
        onExited: code => {
            console.log("[LockScreen] keyring unlock exit " + code);
            Secrets.refresh();
        }
    }

    Process {
        id: authLogProc
    }

    function unlockKeyring(password: string): void {
        if (unlockKeyringProc.running)
            return;
        unlockKeyringProc.pending = password;
        unlockKeyringProc.stdinEnabled = true;
        unlockKeyringProc.running = true;
    }

    function logAuth(event: string): void {
        const now = new Date();
        const utc = now.toISOString().replace("T", " ").slice(0, 19) + " UTC";
        const local = Qt.formatDateTime(now, "yyyy-MM-dd hh:mm:ss");
        const tz = DateTime.currentTimezone || "Local";
        const user = Quickshell.env("USER") ?? "unknown";
        const line = `[${utc} | ${local} ${tz}] ${event} user=${user}`;
        authLogProc.running = false;
        authLogProc.command = ["bash", "-c",
            "umask 077; mkdir -p ~/.local/share/quickshell; f=~/.local/share/quickshell/auth.log; printf '%s\\n' \"$1\" >> \"$f\"; chmod 600 \"$f\"",
            "--", line];
        authLogProc.running = true;
    }

    IpcHandler {
        target: "lock"
        function lock():   void { GlobalStates.screenLocked = true }
        function unlock(): void { GlobalStates.screenLocked = false }
        function toggle(): void { GlobalStates.screenLocked = !GlobalStates.screenLocked }
        function status(): string { return JSON.stringify({ locked: sessionLock.locked, secure: sessionLock.secure, state: GlobalStates.screenLocked }) }
    }

    WlSessionLock {
        id: sessionLock
        locked: GlobalStates.screenLocked

        WlSessionLockSurface {
            color: "black"
            LockSurface {
                anchors.fill: parent
            }
        }
    }

    Connections {
        target: GlobalStates
        function onScreenLockedChanged(): void {
            if (GlobalStates.screenLocked)
                Authentication.reset();
        }
    }

    Connections {
        target: Authentication

        function onUnlockInProgressChanged(): void {
            if (Authentication.unlockInProgress)
                root.logAuth("AUTH_ATTEMPT");
        }

        function onUnlocked(): void {
            root.logAuth("AUTH_SUCCESS");
            const password = Authentication.currentPassword;
            root.unlockKeyring(password);
            Authentication.reset();
            GlobalStates.screenDismissing = true;
        }

        function onFailed(): void {
            root.logAuth("AUTH_FAILURE");
        }
    }
}
