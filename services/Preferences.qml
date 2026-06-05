pragma ComponentBehavior: Bound
pragma Singleton

import Quickshell
import Quickshell.Io as Io
import QtQuick
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
    readonly property string homeDir: Quickshell.env("HOME")
    readonly property string preferenceCacheFile: root.homeDir + "/.cache/quickshell_preferences.json"
    readonly property string defaultWallpaperPath: `${homeDir}/.config/quickshell/assets/default_paper.jpg`
    property bool isLoaded: false

    signal colorSchemeChanged

    function toggleFocusMode(): void {
        root.focusedMode = !root.focusedMode;
        defaultAdapter.focusedMode = root.focusedMode;
    }

    function toggleOpenRazerInstalled(): void {
        root.openrazerInstalled = !root.openrazerInstalled;
        defaultAdapter.openrazerInstalled = root.openrazerInstalled;
    }

    function setColorMode(value: int) {
        root.darkMode = value === 0;
        defaultAdapter.darkMode = root.darkMode;

        if (root.usePreferredScheme) {
            root.setColorScheme(root.darkMode ? "scheme-tonal-spot" : "scheme-neutral", true);
            applySelectedVisualPreferences();
        }
    }

    function toggleUsePreferredScheme() {
        root.usePreferredScheme = !root.usePreferredScheme;
        defaultAdapter.usePreferredScheme = root.usePreferredScheme;

        if (root.usePreferredScheme) {
            root.setColorScheme(root.darkMode ? "scheme-tonal-spot" : "scheme-neutral", true);
            applySelectedVisualPreferences();
        }
    }

    function getUsePreferredScheme(): bool {
        return root.usePreferredScheme;
    }

    function setWallpaperPath(path: string) {
        root.wallpaperPath = path;
        defaultAdapter.storedWallpaperPath = path;
    }

    function getColorScheme(): string {
        return isLoaded ? root.matugenScheme : "unknown";
    }

    function setColorScheme(scheme: string, internal: bool) {
        if (root.usePreferredScheme && !internal)
            console.warn("Preferences: Using preferred scheme... Shouldn't set custom color scheme");

        root.matugenScheme = scheme;
        defaultAdapter.storedMatugenScheme = scheme;
        root.colorSchemeChanged();
    }

    function applySelectedVisualPreferences() {
        Wallpapers.applyWithCurPreferences(root.wallpaperPath, root.darkMode, root.matugenScheme);
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

            root.darkMode = true;
            root.wallpaperPath = root.defaultWallpaperPath;
            root.matugenScheme = "scheme-tonal-spot";
            root.usePreferredScheme = true;
            root.openrazerInstalled = false;
            root.focusedMode = false;

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
