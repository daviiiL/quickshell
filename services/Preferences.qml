pragma ComponentBehavior: Bound
pragma Singleton

import Quickshell
import Quickshell.Io as Io
import QtQuick
import qs.services

Singleton {
    id: root

    property bool darkMode
    property string wallpaperPath
    property string matugenScheme
    readonly property string homeDir: Quickshell.env("HOME")
    readonly property string preferenceCacheFile: root.homeDir + "/.cache/quickshell_preferences.json"
    readonly property string defaultWallpaperPath: `${homeDir}/.config/quickshell/assets/default_paper.jpg`
    property bool isLoaded: false

    signal colorSchemeChanged

    function setColorMode(value: int) {
        root.darkMode = value === 0 ? true : false;
        defaultAdapter.darkMode = root.darkMode;
    }

    function setWallpaperPath(path: string) {
        root.wallpaperPath = path;
        defaultAdapter.storedWallpaperPath = path;
    }

    function getColorScheme(): string {
        return isLoaded ? root.matugenScheme : "unknown";
    }

    function setColorScheme(scheme: string) {
        // console.debug("[Preferences.qml]: Switching matugen scheme to: " + scheme);
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
    }

    Io.FileView {
        id: prefFileView
        blockLoading: true
        path: root.preferenceCacheFile
        adapter: defaultAdapter

        onAdapterUpdated: {
            if (root.isLoaded) {
                // console.debug(`[Preferences.qml]: Preferences JSON adapter wrote to ${root.preferenceCacheFile}`);
                this.writeAdapter();
            }
        }

        onLoaded: {
            // console.debug("[Preferences.qml]: Preferences loaded");
            root.darkMode = defaultAdapter.darkMode;
            root.matugenScheme = defaultAdapter.storedMatugenScheme;
            root.wallpaperPath = defaultAdapter.storedWallpaperPath;
            root.isLoaded = true;
        }

        onLoadFailed: {
            // console.debug("[Preferences.qml]: load failed - creating default preferences");
            defaultAdapter.darkMode = true;
            defaultAdapter.storedWallpaperPath = root.defaultWallpaperPath;
            defaultAdapter.storedMatugenScheme = "scheme-tonal-spot";

            root.darkMode = true;
            root.wallpaperPath = root.defaultWallpaperPath;
            root.matugenScheme = "scheme-tonal-spot";
            root.isLoaded = true;
            prefFileView.writeAdapter();
            Wallpapers.applyWithCurPreferences(root.defaultWallpaperPath, true, "scheme-tonal-spot");
        }
    }
}
