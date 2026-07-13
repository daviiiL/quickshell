pragma Singleton

import Quickshell
import Quickshell.Io
import qs.common
import qs.common.models
import qs.services

Singleton {
    id: root

    readonly property string homeDir: Quickshell.env("HOME")
    readonly property string scriptsDir: `${homeDir}/.config/quickshell/scripts`
    readonly property string wallpaperSwitchScriptPath: `${scriptsDir}/wallpaper/switch_wall.sh`

    function applyWithCurPreferences(path: string, isDarkMode: bool, scheme: string): void {
        if (!path || path.length === 0)
            return;
        applyProc.exec([wallpaperSwitchScriptPath, "--scheme", scheme, "--mode", isDarkMode ? "dark" : "light", path]);
        Preferences.setWallpaperPath(path);
    }

    Process {
        id: applyProc
    }
}
