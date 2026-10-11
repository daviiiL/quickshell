pragma ComponentBehavior: Bound

import QtQuick
import qs.common

// Browser-style directory history: go() truncates forward entries, up() is go(parent).
QtObject {
    id: root

    property var _history: []
    property int _index: -1

    readonly property string current: (_index >= 0 && _index < _history.length) ? _history[_index] : ""
    readonly property bool canGoBack: _index > 0
    readonly property bool canGoForward: _index >= 0 && _index < _history.length - 1
    readonly property bool canGoUp: current.length > 0 && current !== "/"

    function _normalize(dir: string): string {
        if (!dir) return "";
        let d = FileUtils.trimFileProtocol(dir);
        while (d.length > 1 && d.endsWith("/"))
            d = d.slice(0, -1);
        return d;
    }

    function reset(dir: string): void {
        const d = root._normalize(dir);
        root._history = d.length > 0 ? [d] : [];
        root._index = d.length > 0 ? 0 : -1;
    }

    function go(dir: string): void {
        const d = root._normalize(dir);
        if (d.length === 0 || d === root.current)
            return;
        const next = root._history.slice(0, root._index + 1);
        next.push(d);
        root._history = next;
        root._index = next.length - 1;
    }

    function back(): void {
        if (root.canGoBack) root._index -= 1;
    }

    function forward(): void {
        if (root.canGoForward) root._index += 1;
    }

    function up(): void {
        if (!root.canGoUp) return;
        let parent = FileUtils.parentDirectory(root.current);
        if (parent.length === 0) parent = "/";
        root.go(parent);
    }

    function display(homeDir: string): string {
        const c = root.current;
        if (homeDir && homeDir.length > 0) {
            if (c === homeDir) return "~";
            if (c.startsWith(homeDir + "/")) return "~" + c.slice(homeDir.length);
        }
        return c;
    }
}
