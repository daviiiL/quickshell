pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property string service: "quickshell"
    property bool probing: true
    property bool available: false
    property bool locked: true
    property bool ready: false

    property var _queue: []
    property var _job: null
    property int _exitCode: -1
    property bool _exited: false
    property bool _outDone: false
    property bool _errDone: false

    signal changed(string key)

    Component.onCompleted: refresh()

    function refresh(): void {
        if (probeProc.running)
            return;
        probeProc.reported = false;
        probeProc.running = true;
    }

    function get(key: string, cb: var): void {
        _enqueue({ op: "lookup", key: key, value: "", cb: cb });
    }

    function set(key: string, value: string, cb: var): void {
        _enqueue({ op: "store", key: key, value: value, cb: cb });
    }

    function clear(key: string, cb: var): void {
        _enqueue({ op: "clear", key: key, value: "", cb: cb });
    }

    function _enqueue(job: var): void {
        if (!ready) {
            if (job.cb)
                job.cb(false, "", available ? "locked" : "unavailable");
            return;
        }
        const q = _queue.slice();
        q.push(job);
        _queue = q;
        _next();
    }

    function _next(): void {
        if (_job || _queue.length === 0)
            return;
        const q = _queue.slice();
        _job = q.shift();
        _queue = q;
        _exitCode = -1;
        _exited = false;
        _outDone = false;
        _errDone = false;

        const attrs = ["service", root.service, "key", _job.key];
        switch (_job.op) {
        case "store":
            toolProc.stdinEnabled = true;
            toolProc.command = ["secret-tool", "store", "--label", "Quickshell: " + _job.key].concat(attrs);
            break;
        case "clear":
            toolProc.stdinEnabled = false;
            toolProc.command = ["secret-tool", "clear"].concat(attrs);
            break;
        default:
            toolProc.stdinEnabled = false;
            toolProc.command = ["secret-tool", "lookup"].concat(attrs);
        }
        toolProc.running = true;
    }

    // Qt does not order exited against the two stream-finished signals.
    function _finishIfDone(): void {
        if (!_exited || !_outDone || !_errDone)
            return;
        const job = _job;
        const code = _exitCode;
        _job = null;

        let value = "";
        if (job.op === "lookup" && code === 0) {
            value = toolOut.text;
            if (value.endsWith("\n"))
                value = value.slice(0, -1);
        }
        const ok = code === 0;
        if (ok && job.op !== "lookup")
            root.changed(job.key);
        console.log(`[Secrets] ${job.op} ${job.key}: ${ok ? "ok" : "failed(" + code + ")"}`);
        if (job.cb)
            job.cb(ok, value, ok ? "" : (code === -1 ? "secret-tool did not run" : toolErr.text.trim()));
        _next();
    }

    Process {
        id: probeProc
        property bool reported: false
        command: ["busctl", "--user", "get-property", "org.freedesktop.secrets",
                  "/org/freedesktop/secrets/aliases/default",
                  "org.freedesktop.Secret.Collection", "Locked"]
        stdout: StdioCollector { id: probeOut }
        onExited: code => {
            reported = true;
            root.available = code === 0;
            root.locked = code !== 0 || probeOut.text.trim() !== "b false";
            root.ready = root.available && !root.locked;
            root.probing = false;
            console.log(`[Secrets] probe: available=${root.available} locked=${root.locked}`);
        }
        // A binary that fails to spawn only flips running; exited never fires.
        onRunningChanged: {
            if (running || reported)
                return;
            reported = true;
            root.available = false;
            root.locked = true;
            root.ready = false;
            root.probing = false;
            console.warn("[Secrets] probe: busctl did not run");
        }
    }

    Process {
        id: toolProc
        stdout: StdioCollector {
            id: toolOut
            onStreamFinished: { root._outDone = true; root._finishIfDone(); }
        }
        stderr: StdioCollector {
            id: toolErr
            onStreamFinished: { root._errDone = true; root._finishIfDone(); }
        }
        onStarted: {
            if (root._job && root._job.op === "store") {
                toolProc.write(root._job.value);
                toolProc.stdinEnabled = false;
            }
        }
        onExited: code => {
            root._exitCode = code;
            root._exited = true;
            root._finishIfDone();
        }
        onRunningChanged: {
            if (running || !root._job || root._exited)
                return;
            root._exitCode = -1;
            root._exited = true;
            root._outDone = true;
            root._errDone = true;
            root._finishIfDone();
        }
    }
}
