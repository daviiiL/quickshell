pragma ComponentBehavior: Bound
pragma Singleton

import Quickshell
import Quickshell.Io as Io
import QtQuick
import qs.common
import qs.services

Singleton {
    id: root

    property bool darkMode
    property bool usePreferredScheme
    property bool openrazerInstalled
    property bool focusedMode
    property var appUsage: ({})    // { [appId]: { count: int, last: epochMillis } }
    property var pinnedApps: []     // ordered list of appId strings
    property string wallpaperPath
    property string matugenScheme
    property int fontOffset: 0
    readonly property int minFontOffset: -2
    readonly property int maxFontOffset: 5
    readonly property var defaultIdleSet: ({ lock: 300, screenOff: 360, suspend: 420 })
    property var idleAc: ({ lock: 300, screenOff: 360, suspend: 420 })
    property var idleBattery: ({ lock: 300, screenOff: 360, suspend: 420 })
    property bool showBatteryPercentInBar: true

    property string geminiModel: "gemini-2.5-flash"
    property real geminiTemperature: 1.0
    property int geminiMaxTokens: 0
    property string geminiSystemPrompt: ""
    property bool geminiWebSearch: true
    property string legacyGeminiApiKey: ""
    readonly property string homeDir: Quickshell.env("HOME")
    readonly property string preferenceCacheFile: root.homeDir + "/.cache/quickshell_preferences.json"
    readonly property string defaultWallpaperPath: `${homeDir}/.config/quickshell/assets/default_paper.jpg`
    property bool isLoaded: false

    function toggleFocusMode(): void {
        root.focusedMode = !root.focusedMode;
        defaultAdapter.focusedMode = root.focusedMode;
    }

    function setWallpaperPath(path: string) {
        root.wallpaperPath = path;
        defaultAdapter.storedWallpaperPath = path;
    }

    function clampFontOffset(offset: real): int {
        return Math.max(root.minFontOffset, Math.min(root.maxFontOffset, Math.round(offset)));
    }

    function setFontOffset(offset: real): void {
        const clamped = root.clampFontOffset(offset);
        root.fontOffset = clamped;
        GlobalStates.fontOffset = clamped;
        defaultAdapter.fontOffset = clamped;
    }

    function normalizeIdleSet(raw: var): var {
        const out = Object.assign({}, root.defaultIdleSet);
        if (!raw || typeof raw !== "object")
            return out;
        for (const key of ["lock", "screenOff", "suspend"]) {
            const v = Number(raw[key]);
            if (Number.isInteger(v) && v >= 0)
                out[key] = v;
        }
        return out;
    }

    function parseJsonObject(json: string): var {
        try { return JSON.parse(json || "{}"); } catch (e) { return ({}); }
    }

    function setIdleTimer(which: string, key: string, seconds: int): void {
        if (which !== "ac" && which !== "battery")
            return;
        if (key !== "lock" && key !== "screenOff" && key !== "suspend")
            return;
        const base = which === "ac" ? root.idleAc : root.idleBattery;
        const next = Object.assign({}, base);
        next[key] = Math.max(0, Math.round(seconds));
        if (which === "ac") {
            root.idleAc = next;
            defaultAdapter.idleAcJson = JSON.stringify(next);
        } else {
            root.idleBattery = next;
            defaultAdapter.idleBatteryJson = JSON.stringify(next);
        }
    }

    function setShowBatteryPercentInBar(on: bool): void {
        root.showBatteryPercentInBar = on;
        defaultAdapter.showBatteryPercentInBar = on;
    }

    function clearLegacyGeminiApiKey(): void {
        root.legacyGeminiApiKey = "";
        defaultAdapter.geminiApiKey = "";
    }

    function setGeminiModel(model: string): void {
        const m = model && model.length > 0 ? model : "gemini-2.5-flash";
        root.geminiModel = m;
        defaultAdapter.geminiModel = m;
    }

    function setGeminiTemperature(v: real): void {
        root.geminiTemperature = Math.max(0, Math.min(2, v));
        defaultAdapter.geminiTemperature = root.geminiTemperature;
    }

    function setGeminiMaxTokens(n: int): void {
        root.geminiMaxTokens = Math.max(0, n);
        defaultAdapter.geminiMaxTokens = root.geminiMaxTokens;
    }

    function setGeminiSystemPrompt(s: string): void {
        root.geminiSystemPrompt = s;
        defaultAdapter.geminiSystemPrompt = s;
    }

    function setGeminiWebSearch(on: bool): void {
        root.geminiWebSearch = on;
        defaultAdapter.geminiWebSearch = on;
    }

    function recordLaunch(appId: string): void {
        if (!appId)
            return;
        const usage = Object.assign({}, root.appUsage);
        const prev = usage[appId] || { "count": 0, "last": 0 };
        usage[appId] = { "count": prev.count + 1, "last": Date.now() };
        root.appUsage = usage;
        defaultAdapter.appUsageJson = JSON.stringify(usage);
    }

    function isPinned(appId: string): bool {
        if (!appId)
            return false;
        return root.pinnedApps.indexOf(appId) !== -1;
    }

    function setPinned(appId: string, pinned: bool): void {
        if (!appId)
            return;
        const list = root.pinnedApps.slice();
        const idx = list.indexOf(appId);
        if (pinned && idx === -1)
            list.push(appId);
        else if (!pinned && idx !== -1)
            list.splice(idx, 1);
        else
            return;
        root.pinnedApps = list;
        defaultAdapter.pinnedAppsJson = JSON.stringify(list);
    }

    Io.JsonAdapter {
        id: defaultAdapter

        property bool darkMode
        property string storedWallpaperPath
        property string storedMatugenScheme
        property bool usePreferredScheme
        property bool openrazerInstalled
        property bool focusedMode
        property int fontOffset: 0
        property string appUsageJson: "{}"
        property string pinnedAppsJson: "[]"
        property string idleAcJson: "{}"
        property string idleBatteryJson: "{}"
        property bool showBatteryPercentInBar: true

        property string geminiApiKey: ""
        property string geminiModel: "gemini-2.5-flash"
        property real geminiTemperature: 1.0
        property int geminiMaxTokens: 0
        property string geminiSystemPrompt: ""
        property bool geminiWebSearch: true
    }

    Io.Process {
        id: tightenPrefs
        command: ["chmod", "600", root.preferenceCacheFile]
    }

    Io.FileView {
        id: prefFileView
        blockLoading: true
        path: root.preferenceCacheFile
        adapter: defaultAdapter

        onAdapterUpdated: {
            if (root.isLoaded) {
                this.writeAdapter();
                tightenPrefs.running = true;
            }
        }

        onLoaded: {
            root.darkMode = defaultAdapter.darkMode;
            root.matugenScheme = defaultAdapter.storedMatugenScheme;
            root.wallpaperPath = defaultAdapter.storedWallpaperPath;
            root.usePreferredScheme = defaultAdapter.usePreferredScheme;
            root.openrazerInstalled = defaultAdapter.openrazerInstalled;
            root.focusedMode = defaultAdapter.focusedMode;
            root.fontOffset = root.clampFontOffset(defaultAdapter.fontOffset);
            GlobalStates.fontOffset = root.fontOffset;
            try {
                const usage = JSON.parse(defaultAdapter.appUsageJson || "{}");
                root.appUsage = (usage && typeof usage === "object" && !Array.isArray(usage)) ? usage : ({});
            } catch (e) {
                root.appUsage = ({});
            }
            try {
                const pins = JSON.parse(defaultAdapter.pinnedAppsJson || "[]");
                root.pinnedApps = Array.isArray(pins) ? pins : [];
            } catch (e) {
                root.pinnedApps = [];
            }

            root.idleAc = root.normalizeIdleSet(root.parseJsonObject(defaultAdapter.idleAcJson));
            root.idleBattery = root.normalizeIdleSet(root.parseJsonObject(defaultAdapter.idleBatteryJson));
            root.showBatteryPercentInBar = defaultAdapter.showBatteryPercentInBar;

            root.legacyGeminiApiKey = defaultAdapter.geminiApiKey || "";
            root.geminiModel = defaultAdapter.geminiModel || "gemini-2.5-flash";
            root.geminiTemperature = defaultAdapter.geminiTemperature;
            root.geminiMaxTokens = defaultAdapter.geminiMaxTokens;
            root.geminiSystemPrompt = defaultAdapter.geminiSystemPrompt;
            root.geminiWebSearch = defaultAdapter.geminiWebSearch;

            root.isLoaded = true;
            tightenPrefs.running = true;
        }

        onLoadFailed: {
            defaultAdapter.darkMode = true;
            defaultAdapter.storedWallpaperPath = root.defaultWallpaperPath;
            defaultAdapter.storedMatugenScheme = "scheme-tonal-spot";
            defaultAdapter.usePreferredScheme = true;
            defaultAdapter.openrazerInstalled = false;
            defaultAdapter.focusedMode = false;
            defaultAdapter.fontOffset = 0;

            root.darkMode = true;
            root.wallpaperPath = root.defaultWallpaperPath;
            root.matugenScheme = "scheme-tonal-spot";
            root.usePreferredScheme = true;
            root.openrazerInstalled = false;
            root.focusedMode = false;
            root.fontOffset = 0;
            GlobalStates.fontOffset = 0;

            defaultAdapter.appUsageJson = "{}";
            defaultAdapter.pinnedAppsJson = "[]";
            root.appUsage = ({});
            root.pinnedApps = [];

            defaultAdapter.geminiApiKey = "";
            defaultAdapter.geminiModel = "gemini-2.5-flash";
            defaultAdapter.geminiTemperature = 1.0;
            defaultAdapter.geminiMaxTokens = 0;
            defaultAdapter.geminiSystemPrompt = "";
            defaultAdapter.geminiWebSearch = true;
            root.legacyGeminiApiKey = "";
            root.geminiModel = "gemini-2.5-flash";
            root.geminiTemperature = 1.0;
            root.geminiMaxTokens = 0;
            root.geminiSystemPrompt = "";
            root.geminiWebSearch = true;

            defaultAdapter.idleAcJson = JSON.stringify(root.defaultIdleSet);
            defaultAdapter.idleBatteryJson = JSON.stringify(root.defaultIdleSet);
            defaultAdapter.showBatteryPercentInBar = true;
            root.idleAc = Object.assign({}, root.defaultIdleSet);
            root.idleBattery = Object.assign({}, root.defaultIdleSet);
            root.showBatteryPercentInBar = true;

            root.isLoaded = true;
            prefFileView.writeAdapter();
            tightenPrefs.running = true;
            Wallpapers.applyWithCurPreferences(root.defaultWallpaperPath, true, "scheme-tonal-spot");
        }
    }
}
