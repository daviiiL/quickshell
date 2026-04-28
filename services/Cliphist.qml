pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property list<var> entries: []
    property string query: ""

    readonly property list<var> results: {
        if (root.query.length === 0)
            return root.entries;
        const q = root.query.toLowerCase();
        return root.entries.filter(e => e.preview.toLowerCase().indexOf(q) !== -1);
    }

    readonly property int count: root.results.length

    property bool available: true

    property var decoded: ({})
    property var pendingDecode: ({})

    property int _queuedDecode: -1

    readonly property int _decodeMaxBytes: 64 * 1024

    signal picked(int id)
    signal entryDecoded(int id, string text)

    function refresh() {
        listProc.running = false;
        listProc.running = true;
    }

    function pickEntry(id: int) {
        if (!Number.isFinite(id)) return;
        pickProc.command = ["sh", "-c", 'cliphist decode "$ID" | wl-copy'];
        pickProc.environment = { "ID": String(id) };
        pickProc.running = true;
        root.picked(id);
    }

    function deleteEntry(id: int) {
        if (!Number.isFinite(id)) return;
        const rec = root.entries.find(e => e.id === id);
        if (!rec) return;
        deleteProc.command = ["sh", "-c", 'printf "%s\t%s\n" "$ID" "$PREV" | cliphist delete'];
        deleteProc.environment = { "ID": String(id), "PREV": rec.preview };
        deleteProc.running = true;
    }

    function decodeEntry(id: int) {
        if (!Number.isFinite(id)) return;
        if (root.decoded[id] !== undefined) {
            root.entryDecoded(id, root.decoded[id]);
            return;
        }
        if (root.pendingDecode[id]) return;

        if (decodeProc.running) {
            // Don't clobber an in-flight call's _pendingId; onExited drains this later.
            root._queuedDecode = id;
            return;
        }
        root.pendingDecode = Object.assign({}, root.pendingDecode, { [id]: true });

        decodeProc._pendingId = id;
        decodeProc.command = ["sh", "-c", 'cliphist decode "$ID"'];
        decodeProc.environment = { "ID": String(id) };
        decodeProc.running = true;
    }

    // Order matters: more-specific tests first.
    function _classify(preview) {
        if (/^\[\[\s*binary\b/i.test(preview)) return "img";
        if (/^https?:\/\//i.test(preview))     return "url";
        if (/^(ERROR|FATAL|panic)\b/i.test(preview)) return "err";
        if (/^WARN\b/i.test(preview) || /\bwarn(ing)?\b/i.test(preview.slice(0, 24))) return "warn";
        if (/^\//.test(preview)) return "cmd";
        if (/^(curl|git|npm|sudo|cd|rm|cp|mv|cat|echo|qs|cliphist) /i.test(preview)) return "cmd";
        return "txt";
    }

    // cliphist list emits "<numericId>\t<preview>" per line.
    function _parseLine(line) {
        if (line.length === 0) return null;
        const tab = line.indexOf("\t");
        if (tab <= 0) return null;
        const id = parseInt(line.slice(0, tab));
        if (!Number.isFinite(id)) return null;
        const preview = line.slice(tab + 1);
        return { id: id, preview: preview, type: root._classify(preview) };
    }

    Process {
        id: listProc
        // -preview-width 10000 lets the substring filter match past cliphist's default 100-char cap.
        command: ["cliphist", "list", "-preview-width", "10000"]
        stdout: StdioCollector {
            onStreamFinished: {
                const text = this.text || "";
                const lines = text.split("\n");
                const next = [];
                for (let i = 0; i < lines.length; i++) {
                    const rec = root._parseLine(lines[i]);
                    if (rec) next.push(rec);
                }
                root.entries = next;
                root.available = true;
            }
        }
        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0) {
                root.entries = [];
                root.available = false;
            }
        }
    }

    Process {
        id: pickProc
    }

    Process {
        id: deleteProc
        // Refresh on any exit code so the UI reflects cliphist's actual state even when the delete itself fails.
        onExited: (exitCode, exitStatus) => {
            root.refresh();
        }
    }

    Process {
        id: decodeProc
        property int _pendingId: -1

        stdout: StdioCollector {
            onStreamFinished: {
                const id = decodeProc._pendingId;
                if (id < 0) return;

                let text = this.text || "";
                const cap = root._decodeMaxBytes;
                if (text.length > cap) {
                    text = `[truncated · ${text.length} bytes]`;
                }

                const next = Object.assign({}, root.decoded);
                next[id] = text;
                root.decoded = next;

                const pending = Object.assign({}, root.pendingDecode);
                delete pending[id];
                root.pendingDecode = pending;

                root.entryDecoded(id, text);
            }
        }
        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0) {
                const id = decodeProc._pendingId;
                if (id >= 0) {
                    const pending = Object.assign({}, root.pendingDecode);
                    delete pending[id];
                    root.pendingDecode = pending;
                }
            }
            decodeProc._pendingId = -1;

            // Defer so decodeEntry sees decodeProc.running settled to false.
            const queued = root._queuedDecode;
            root._queuedDecode = -1;
            if (queued >= 0 && root.decoded[queued] === undefined) {
                Qt.callLater(() => root.decodeEntry(queued));
            }
        }
    }
}
