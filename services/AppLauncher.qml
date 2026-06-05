pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import qs.common
import qs.services

Singleton {
    id: root

    property string query: ""

    // ── Search results (unchanged behaviour; launch now records usage) ──
    property list<var> results: {
        if (root.query === "")
            return [];

        return AppSearch.fuzzyQuery(root.query).map(entry => ({
            "name": entry.name,
            "iconName": entry.icon,
            "comment": entry.description || "",
            "entry": entry,
            "execute": () => root.launch(entry)
        }));
    }

    // ── Grid data sources ──
    readonly property var allApps: AppSearch.list
        .slice()
        .sort((a, b) => (a.name || "").localeCompare(b.name || ""))

    readonly property var pinnedApps: {
        const byId = {};
        for (const e of AppSearch.list)
            byId[e.id] = e;
        return (Preferences.pinnedApps || []).map(id => byId[id]).filter(e => !!e);
    }

    readonly property var frequentApps: {
        const usage = Preferences.appUsage || {};
        const pinned = Preferences.pinnedApps || [];
        const now = Date.now();
        return AppSearch.list
            .filter(e => usage[e.id] && usage[e.id].count > 0 && pinned.indexOf(e.id) === -1)
            .map(e => ({ "entry": e, "score": root.frecencyScore(usage[e.id], now) }))
            .sort((a, b) => (b.score - a.score) || (a.entry.name || "").localeCompare(b.entry.name || ""))
            .slice(0, 8)
            .map(o => o.entry);
    }

    function frecencyScore(rec, now): real {
        const days = (now - (rec.last || 0)) / 86400000;
        let w = 1;
        if (days <= 1)
            w = 4;
        else if (days <= 3)
            w = 3;
        else if (days <= 7)
            w = 2;
        else if (days <= 30)
            w = 1.5;
        return (rec.count || 0) * w;
    }

    function isPinned(entry): bool {
        return entry ? Preferences.isPinned(entry.id) : false;
    }

    function togglePin(entry): void {
        if (!entry)
            return;
        Preferences.setPinned(entry.id, !Preferences.isPinned(entry.id));
    }

    function launch(entry): void {
        if (!entry)
            return;
        Preferences.recordLaunch(entry.id);
        if (!entry.runInTerminal) {
            entry.execute();
            return;
        }
        const terminalCmd = Quickshell.env("TERMINAL") || "kitty";
        Quickshell.execDetached(["bash", "-c", `${terminalCmd} -e '${StringUtils.shellSingleQuoteEscape(entry.command.join(" "))}'`]);
    }
}
