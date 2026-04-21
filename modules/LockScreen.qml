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
    }

    Process {
        id: authLogProc
    }

    function unlockKeyring(password: string): void {
        unlockKeyringProc.running = false;
        unlockKeyringProc.environment = { "UNLOCK_PASSWORD": password };
        unlockKeyringProc.command = ["bash", "-c", Quickshell.shellPath("scripts/keyring/unlock.sh")];
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
        authLogProc.environment = { "LOG_LINE": line };
        authLogProc.command = ["bash", "-c", "mkdir -p ~/.local/share/quickshell && echo \"$LOG_LINE\" >> ~/.local/share/quickshell/auth.log"];
        authLogProc.running = true;
    }

    IpcHandler {
        target: "lock"
        function lock():   void { GlobalStates.screenLocked = true }
        function unlock(): void { GlobalStates.screenLocked = false }
        function toggle(): void { GlobalStates.screenLocked = !GlobalStates.screenLocked }
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
