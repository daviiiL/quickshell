pragma ComponentBehavior: Bound
pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick
import qs.common
import qs.services

Singleton {
    id: root

    readonly property string homeDir: Quickshell.env("HOME")
    readonly property string setSchemeScriptPath: `${homeDir}/.config/quickshell/gtk_theme/set-scheme.sh`
    readonly property string mode: GlobalStates.darkMode ? "dark" : "light"

    property bool _started: false
    property string _target: ""
    property string _running: ""

    function start(): void {
        if (_started)
            return;
        _started = true;
        apply();
    }

    function apply(): void {
        root._target = root.mode;
        if (!schemeProc.running)
            run();
    }

    function run(): void {
        root._running = root._target;
        schemeProc.command = [root.setSchemeScriptPath, root._running];
        schemeProc.running = true;
        console.log("[ColorScheme] set-scheme " + root._running);
    }

    Connections {
        target: GlobalStates
        function onDarkModeChanged(): void {
            Preferences.setDarkMode(GlobalStates.darkMode);
            if (root._started)
                root.apply();
        }
    }

    Process {
        id: schemeProc
        onExited: (code, status) => {
            if (code !== 0)
                console.warn("[ColorScheme] set-scheme " + root._running + " exited " + code);
            if (root._target !== root._running)
                root.run();
        }
    }
}
