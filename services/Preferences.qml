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
    }

    Io.FileView {
        id: prefFileView
        blockLoading: true
        path: root.preferenceCacheFile
        adapter: defaultAdapter

        onAdapterUpdated: {
            if (root.isLoaded) {
                this.writeAdapter();
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
            root.isLoaded = true;
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

            root.isLoaded = true;
            prefFileView.writeAdapter();
            Wallpapers.applyWithCurPreferences(root.defaultWallpaperPath, true, "scheme-tonal-spot");
        }
    }
}
