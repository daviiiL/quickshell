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
    property string wallpaperPath
    property string matugenScheme
    readonly property string homeDir: Quickshell.env("HOME")
    readonly property string preferenceCacheFile: root.homeDir + "/.cache/quickshell_preferences.json"
    readonly property string defaultWallpaperPath: `${homeDir}/.config/quickshell/assets/default_paper.jpg`
    property bool isLoaded: false

    signal colorSchemeChanged

    function toggleOpenRazerInstalled(): void {
        root.openrazerInstalled = !root.openrazerInstalled;
        defaultAdapter.openrazerInstalled = root.openrazerInstalled;
    }

    function setColorMode(value: int) {
        root.darkMode = value === 0 ? true : false;
        defaultAdapter.darkMode = root.darkMode;

        if (root.usePreferredScheme) {
            if (root.darkMode)
                root.setColorScheme("scheme-tonal-spot", true);
            else
                root.setColorScheme("scheme-neutral", true);

            applySelectedVisualPreferences();
        }
    }

    function toggleUsePreferredScheme() {
        root.usePreferredScheme = !root.usePreferredScheme;
        defaultAdapter.usePreferredScheme = root.usePreferredScheme;

        if (root.usePreferredScheme) {
            if (root.darkMode)
                root.setColorScheme("scheme-tonal-spot", true);
            else
                root.setColorScheme("scheme-neutral", true);

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

    Io.JsonAdapter {
        id: defaultAdapter

        property bool darkMode
        property string storedWallpaperPath
        property string storedMatugenScheme
        property bool usePreferredScheme
        property bool openrazerInstalled
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
            root.isLoaded = true;
        }

        onLoadFailed: {
            defaultAdapter.darkMode = true;
            defaultAdapter.storedWallpaperPath = root.defaultWallpaperPath;
            defaultAdapter.storedMatugenScheme = "scheme-tonal-spot";
            defaultAdapter.usePreferredScheme = true;
            defaultAdapter.openrazerInstalled = false;

            root.darkMode = true;
            root.wallpaperPath = root.defaultWallpaperPath;
            root.matugenScheme = "scheme-tonal-spot";
            root.usePreferredScheme = true;
            root.openrazerInstalled = false;

            root.isLoaded = true;
            prefFileView.writeAdapter();
            Wallpapers.applyWithCurPreferences(root.defaultWallpaperPath, true, "scheme-tonal-spot");
        }
    }
}
