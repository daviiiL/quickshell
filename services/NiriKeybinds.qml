pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import qs.common

Singleton {
    id: root

    // Curated actions: id → { section, label, order, group?, lastKeyChip?, keysOverride? }
    //  - only the FIRST bind found for an id is shown (drops vim-key / alternate chords)
    //  - rows sharing `group` merge into one row; their last keys combine into "a/b"
    //  - `lastKeyChip` replaces the last key of the chord (index ranges like "1–9")
    //  - `keysOverride` replaces the chips entirely
    // Ids resolve as: hotkey-overlay-title → "title:…" (shell section),
    // spawn qs ipc call <target> → "ipc:<target>", XF86 spawn → "media",
    // otherwise the niri action name.
    readonly property var curation: ({
        "ipc:keybindhints": { section: "shell", label: "show important hotkeys", order: 0 },
        "ipc:lock": { section: "shell", label: "lock screen", order: 9 },

        "close-window": { section: "windows", label: "close window", order: 0 },
        "focus-column-left": { section: "windows", label: "focus column", group: "focus-col", order: 1 },
        "focus-column-right": { section: "windows", label: "focus column", group: "focus-col", order: 1 },
        "focus-window-up": { section: "windows", label: "focus window", group: "focus-win", order: 2 },
        "focus-window-down": { section: "windows", label: "focus window", group: "focus-win", order: 2 },
        "move-column-left": { section: "windows", label: "move column", group: "move-col", order: 3 },
        "move-column-right": { section: "windows", label: "move column", group: "move-col", order: 3 },
        "move-window-up": { section: "windows", label: "move window", group: "move-win", order: 4 },
        "move-window-down": { section: "windows", label: "move window", group: "move-win", order: 4 },
        "toggle-window-floating": { section: "windows", label: "toggle floating", order: 5 },
        "switch-focus-between-floating-and-tiling": { section: "windows", label: "focus floating ↔ tiling", order: 6 },

        "toggle-overview": { section: "workspaces", label: "toggle overview", order: 0 },
        "focus-workspace-down": { section: "workspaces", label: "switch workspace", group: "ws-switch", order: 1 },
        "focus-workspace-up": { section: "workspaces", label: "switch workspace", group: "ws-switch", order: 1 },
        "move-column-to-workspace-down": { section: "workspaces", label: "move column to workspace", group: "ws-move", order: 2 },
        "move-column-to-workspace-up": { section: "workspaces", label: "move column to workspace", group: "ws-move", order: 2 },
        "focus-workspace": { section: "workspaces", label: "focus workspace by index", lastKeyChip: "1–9", order: 3 },
        "move-column-to-workspace": { section: "workspaces", label: "move column to workspace by index", lastKeyChip: "1–9", order: 4 },

        "switch-preset-column-width": { section: "columns", label: "preset column widths", order: 0 },
        "maximize-column": { section: "columns", label: "maximize column", order: 1 },
        "fullscreen-window": { section: "columns", label: "fullscreen window", order: 2 },
        "center-column": { section: "columns", label: "center column", order: 3 },
        "consume-or-expel-window-left": { section: "columns", label: "consume / expel window", group: "consume", order: 4 },
        "consume-or-expel-window-right": { section: "columns", label: "consume / expel window", group: "consume", order: 4 },
        "set-column-width": { section: "columns", label: "column width ±10%", lastKeyChip: "−/=", order: 5 },
        "toggle-column-tabbed-display": { section: "columns", label: "tabbed column display", order: 6 },

        "screenshot": { section: "session", label: "screenshot", order: 0 },
        "screenshot-screen": { section: "session", label: "screenshot screen", order: 1 },
        "screenshot-window": { section: "session", label: "screenshot window", order: 2 },
        "toggle-keyboard-shortcuts-inhibit": { section: "session", label: "shortcut inhibit", order: 3 },
        "quit": { section: "session", label: "exit niri", order: 4 },
        "power-off-monitors": { section: "session", label: "power off monitors", order: 5 },
        "media": { section: "session", label: "volume & brightness", keysOverride: ["vol ±", "bright ±"], order: 6 }
    })

    // Key label mapping
    readonly property var keyLabels: ({
        "Mod": "super",
        "Ctrl": "ctrl",
        "Alt": "alt",
        "Shift": "shift",
        "Return": "↵",
        "Slash": "/",
        "Escape": "esc",
        "Print": "prtsc",
        "Left": "←",
        "Right": "→",
        "Up": "↑",
        "Down": "↓",
        "Space": "space",
        "BracketLeft": "[",
        "BracketRight": "]",
        "Minus": "−",
        "Equal": "="
    })

    readonly property list<string> sectionOrder: ["shell", "windows", "workspaces", "columns", "session"]

    // Reads keybinds.kdl via cat — same Process + StdioCollector pattern as Cliphist.qml.
    // reload() re-runs it; the overlay calls reload() on every open.
    Process {
        id: catProc
        command: ["cat", Quickshell.env("HOME") + "/.config/niri/configs/keybinds.kdl"]
        stdout: StdioCollector {
            onStreamFinished: {
                root._parse(this.text || "")
            }
        }
        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0)
                root._sections = []
        }
    }

    property var _sections: []

    readonly property var sections: root._sections

    function _normalizeKey(key: string): string {
        if (root.keyLabels[key] !== undefined)
            return root.keyLabels[key]
        return key.toLowerCase()
    }

    function _parse(content: string): void {
        if (typeof content !== "string" || content.length === 0) {
            root._sections = []
            return
        }

        const bindsMatch = content.match(/binds\s*\{([\s\S]*)\n\}/)
        if (!bindsMatch) {
            root._sections = []
            return
        }

        const rowsById = {}
        let seq = 0

        const lines = bindsMatch[1].split("\n")
        for (const raw of lines) {
            const line = raw.replace(/\/\/.*$/, "").trim()
            // [chord] [properties] { [action]; }
            const m = line.match(/^([A-Za-z0-9_+]+)([^{]*)\{\s*([^}]*?);?\s*\}$/)
            if (!m) continue

            const chord = m[1]
            const props = m[2]
            const body = m[3].trim()

            if (/WheelScroll|TouchpadScroll/i.test(chord)) continue

            const actionMatch = body.match(/^([a-z-]+)/)
            if (!actionMatch) continue
            const action = actionMatch[1]

            const titleMatch = props.match(/hotkey-overlay-title="([^"]+)"/)
            const title = titleMatch ? titleMatch[1] : ""

            let id
            let entry
            if (title) {
                id = "title:" + title
                entry = { section: "shell", label: title.toLowerCase().replace(": ", " · "), order: 1 }
            } else if (action === "spawn") {
                const ipcMatch = body.match(/^spawn\s+"qs"\s+"ipc"\s+"call"\s+"([^"]+)"/)
                if (ipcMatch)
                    id = "ipc:" + ipcMatch[1]
                else if (chord.startsWith("XF86"))
                    id = "media"
                else
                    continue
                entry = root.curation[id]
            } else {
                id = action
                entry = root.curation[id]
            }
            if (!entry) continue
            if (rowsById[id]) continue // first chord for an action wins

            const keys = entry.keysOverride
                ? entry.keysOverride.slice()
                : chord.split("+").map(k => root._normalizeKey(k))
            if (entry.lastKeyChip && !entry.keysOverride)
                keys[keys.length - 1] = entry.lastKeyChip

            rowsById[id] = {
                section: entry.section,
                label: entry.label,
                group: entry.group ?? null,
                order: entry.order ?? 99,
                seq: seq++,
                keys: keys
            }
        }

        // Merge grouped rows: keep the first row's modifiers, combine last keys as "a/b"
        const mergedByGroup = {}
        const rows = []
        for (const id in rowsById) {
            const row = rowsById[id]
            if (row.group) {
                const base = mergedByGroup[row.group]
                if (base) {
                    base.keys[base.keys.length - 1] += "/" + row.keys[row.keys.length - 1]
                    continue
                }
                mergedByGroup[row.group] = row
            }
            rows.push(row)
        }

        const result = []
        root.sectionOrder.forEach(name => {
            const sectionRows = rows.filter(r => r.section === name)
            if (sectionRows.length === 0) return
            sectionRows.sort((a, b) => (a.order - b.order) || (a.seq - b.seq))
            result.push({
                name: name,
                rows: sectionRows.map(r => ({ keys: r.keys, label: r.label }))
            })
        })

        root._sections = result
    }

    function reload(): void {
        // Restart trick from Cliphist.refresh(): forces a fresh cat on every call.
        catProc.running = false
        catProc.running = true
    }

    Component.onCompleted: {
        root.reload()
    }
}
