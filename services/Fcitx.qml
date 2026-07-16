pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    // -- state ------------------------------------------------------------
    property bool ready: false
    property string currentIm: ""
    property string currentName: ""
    property string currentLabel: ""
    property int groupIndex: 0
    property int groupTotal: 0

    readonly property bool isCjk: currentLabel !== ""
        && !/^[\x20-\x7e]+$/.test(currentLabel)
    readonly property string currentCode: {
        if (currentIm === "keyboard-us") return "EN";
        if (currentIm === "pinyin") return "拼";
        return isCjk ? currentLabel : currentLabel.toUpperCase();
    }
    readonly property string currentDisplay: {
        if (currentIm === "keyboard-us") return "ENGLISH";
        if (currentIm === "pinyin") return "拼音";
        return isCjk ? currentName : currentName.toUpperCase();
    }

    property bool announcing: false
    signal switched()

    property bool _synced: false   // first im event is initial sync, not a switch

    // -- helper lifecycle ---------------------------------------------------
    Process {
        id: helper
        running: true
        command: [Quickshell.shellPath("scripts/fcitx-watch.py")]
        stdinEnabled: true

        stdout: SplitParser {
            onRead: line => root._handleEvent(line)
        }

        onExited: (exitCode, exitStatus) => {
            root.ready = false;
            root._synced = false;
            restartTimer.interval = 2000;
            restartTimer.restart();
        }
    }

    Timer {
        id: restartTimer
        onTriggered: helper.running = true
    }

    Timer {
        id: announceTimer
        interval: 1500
        onTriggered: root.announcing = false
    }

    function _handleEvent(line: string): void {
        let ev;
        try { ev = JSON.parse(line); } catch (e) { return; }

        switch (ev.ev) {
        case "ready":
            ready = ev.value === true && currentIm !== "";
            if (ev.value === false) _synced = false;
            break;
        case "im": {
            const changed = _synced && ev.im !== currentIm;
            currentIm = ev.im ?? "";
            currentName = ev.name ?? "";
            currentLabel = ev.label ?? "";
            groupIndex = ev.index ?? 0;
            groupTotal = ev.total ?? 0;
            ready = currentIm !== "";
            if (changed) {
                announcing = true;
                announceTimer.restart();
                switched();
            }
            _synced = true;
            break;
        }
        }
    }

    function _send(obj: var): void {
        if (helper.running) helper.write(JSON.stringify(obj) + "\n");
    }

    function toggle(): void { _send({ cmd: "toggle" }); }
    function setIM(im: string): void { _send({ cmd: "set", im: im }); }
}
