pragma ComponentBehavior: Bound
pragma Singleton

import Quickshell
import Quickshell.Io as Io
import QtQuick
import qs.services

Singleton {
    id: root

    property bool darkMode: defaultAdapter.darkMode || true
    property string wallpaperPath: defaultAdapter.wallpaperPath || ""
    property string matugenScheme: defaultAdapter.matugenScheme || "scheme-tonal-spot"
    readonly property string username: Quickshell.env("USER")
    readonly property string homeDir: Quickshell.env("HOME")
    readonly property string filePath: root.homeDir + "/.cache/quickshell_preferences.json"
    readonly property string defaultWallpaperPath: `${homeDir}/.config/quickshell/assets/default_paper.jpg`

    function toggleDarkMode(value: int) {
        root.darkMode = value === 0 ? true : false;
        defaultAdapter.darkMode = root.darkMode;
        Wallpapers.apply(root.wallpaperPath);
        prefFileView.writeAdapter();
    }

    function setWallpaperPath(path: string) {
        root.wallpaperPath = path;
        defaultAdapter.wallpaperPath = path;
    }

    function setMatugenScheme(scheme: string) {
        root.matugenScheme = scheme;
        defaultAdapter.matugenScheme = scheme;
    }

    Io.JsonAdapter {
        id: defaultAdapter

        property bool darkMode
        property string wallpaperPath
        property string matugenScheme
    }

    Io.FileView {
        id: prefFileView

        path: root.filePath
        adapter: defaultAdapter

        onAdapterUpdated: {
            console.log("adapter updated");
            this.writeAdapter();
        }

        onLoaded: {
            console.debug("Preferences loaded");
            root.darkMode = defaultAdapter.darkMode;
            root.wallpaperPath = defaultAdapter.wallpaperPath;
            root.matugenScheme = defaultAdapter.matugenScheme;
            console.debug(root.darkMode);
        }

        onLoadFailed: {
            console.debug("load failed - creating default preferences");
            defaultAdapter.darkMode = true;
            defaultAdapter.wallpaperPath = root.defaultWallpaperPath;
            defaultAdapter.matugenScheme = "scheme-tonal-spot";
            prefFileView.writeAdapter();

            Wallpapers.apply(root.defaultWallpaperPath, true, "scheme-tonal-spot");
        }
    }
}
