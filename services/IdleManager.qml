pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.common
import qs.services
import "IdleArgs.js" as IdleArgs

Singleton {
    id: root

    readonly property var allNever: ({ lock: 0, screenOff: 0, suspend: 0 })
    readonly property var activeSet: (Power.isLaptopBattery && Power.onBattery) ? Preferences.idleBattery : Preferences.idleAc
    readonly property var effectiveSet: GlobalStates.caffeinated ? allNever : activeSet
    readonly property var currentArgs: IdleArgs.build(effectiveSet)
    readonly property bool running: idleProc.running

    property bool _started: false
    property bool _respawnAfterExit: false
    property var _pendingArgs: []
    property real _startedAt: 0

    function start(): void {
        if (_started) return;
        _started = true;
        foreignCheck.running = true;
    }

    onEffectiveSetChanged: {
        if (_started) restartTimer.restart();
    }

    function apply(): void {
        if (idleProc.running) {
            _respawnAfterExit = true;
            idleProc.running = false;
            return;
        }
        spawn();
    }

    function spawn(): void {
        const args = IdleArgs.build(effectiveSet);
        _pendingArgs = args;
        idleProc.command = ["setpriv", "--pdeathsig", "SIGTERM", "--", "swayidle", "-w"].concat(args);
        idleProc.running = true;
    }

    Timer {
        id: restartTimer
        interval: 1000
        onTriggered: root.apply()
    }

    IpcHandler {
        target: "caffeine"
        function toggle(): void { GlobalStates.toggleCaffeine() }
        function on(): void { GlobalStates.setCaffeinated(true) }
        function off(): void { GlobalStates.setCaffeinated(false) }
        function status(): string { return GlobalStates.caffeinated ? "on" : "off" }
    }

    Process {
        id: foreignCheck
        command: ["sh", "-c", "pgrep -x swayidle | wc -l"]
        stdout: StdioCollector {
            onStreamFinished: {
                const n = parseInt(this.text.trim()) || 0;
                if (n > 0)
                    console.warn("[IdleManager] another swayidle is running (" + n + "); remove it from ~/.config/niri/configs/autostart.kdl");
                root.apply();
            }
        }
    }

    Process {
        id: idleProc
        onStarted: {
            root._startedAt = Date.now();
            console.log("[IdleManager] swayidle started: " + root._pendingArgs.join(" "));
        }
        onExited: (code, status) => {
            if (root._respawnAfterExit) {
                root._respawnAfterExit = false;
                console.log("[IdleManager] swayidle stopped (" + code + ")");
                root.spawn();
                return;
            }
            if (Date.now() - root._startedAt < 1000)
                console.warn("[IdleManager] swayidle exited immediately (" + code + "); is swayidle installed?");
            else
                console.warn("[IdleManager] swayidle exited unexpectedly (" + code + "); idle timers are off until the next change or a shell restart");
        }
    }
}
