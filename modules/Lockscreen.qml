pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.common
import qs.components.lockscreen
import qs.services

Scope {
    id: root

    Process {
        id: unlockKeyringProc
    }

    function unlockKeyring(password) {
        unlockKeyringProc.exec({
            environment: ({
                    "UNLOCK_PASSWORD": password
                }),
            command: ["bash", "-c", Quickshell.shellPath("scripts/keyring/unlock.sh")]
        });
    }

    property var windowData: []
    function saveWindowPositionAndTile() {
        Quickshell.execDetached(["hyprctl", "keyword", "dwindle:pseudotile", "true"]);
    }

    function restoreWindowPositionAndTile() {
        Quickshell.execDetached(["hyprctl", "keyword", "dwindle:pseudotile", "false"]);
    }

    Connections {
        target: Authentication
        function onUnlocked() {
            const password = Authentication.currentPassword;
            root.unlockKeyring(password);
            GlobalStates.screenLocked = false;
            Quickshell.execDetached(["bash", "-c", "sleep 0.2; hyprctl --batch \"dispatch togglespecialworkspace; dispatch togglespecialworkspace\""]);
            Authentication.reset();
        }
    }

    Connections {
        target: GlobalStates
        function onScreenLockedChanged() {
            if (GlobalStates.screenLocked) {
                Authentication.reset();
            }
        }
    }

    WlSessionLock {
        id: lock
        locked: GlobalStates.screenLocked

        WlSessionLockSurface {
            color: "transparent"

            Loader {
                active: GlobalStates.screenLocked
                anchors.fill: parent
                opacity: active ? 1 : 0

                Behavior on opacity {
                    NumberAnimation {
                        duration: Theme.anim.durations.md
                        easing.type: Easing.OutCubic
                    }
                }

                sourceComponent: LockSurface {}
            }
        }
    }

    Variants {
        model: Quickshell.screens
        delegate: Scope {
            required property ShellScreen modelData
            property bool shouldPush: GlobalStates.screenLocked
            property string targetMonitorName: modelData ? modelData.name : ""
            property int verticalMovementDistance: modelData ? modelData.height : 0
            property int horizontalSqueeze: modelData ? modelData.width * 0.2 : 0

            onShouldPushChanged: {
                if (shouldPush) {
                    root.saveWindowPositionAndTile();
                    Quickshell.execDetached(["bash", "-c", `hyprctl keyword monitor ${targetMonitorName}, addreserved, ${verticalMovementDistance}, ${-verticalMovementDistance}, ${horizontalSqueeze}, ${horizontalSqueeze}`]);
                } else {
                    Quickshell.execDetached(["bash", "-c", `hyprctl keyword monitor ${targetMonitorName}, addreserved, 0, 0, 0, 0`]);
                    root.restoreWindowPositionAndTile();
                }
            }
        }
    }

    function lock() {
        GlobalStates.screenLocked = true;
    }

    IpcHandler {
        target: "lock"

        function activate(): void {
            root.lock();
        }

        function focus(): void {
            Authentication.shouldReFocus();
        }
    }

    GlobalShortcut {
        name: "lock"
        description: "Locks the screen"

        onPressed: {
            root.lock();
        }
    }
}
