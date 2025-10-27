pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

/**
 * A service that provides access to Hyprland keybinds.
 * Uses the `get_keybinds.py` script to parse Hyprland config files.
 */
Singleton {
    id: root
    property string keybindParserPath: {
        const url = Qt.resolvedUrl("../scripts/hyprland/get_keybinds.py").toString();
        return url.replace("file://", "");
    }
    property string keybindConfigPath: {
        const home = Quickshell.env("HOME");
        return home + "/.config/hypr/config/keybinds.conf";
    }
    property var keybinds: {"children": [], "keybinds": []}
    property bool ready: false

    Connections {
        target: Hyprland

        function onRawEvent(event) {
            if (event.name == "configreloaded") {
                getKeybinds.running = true
            }
        }
    }

    Process {
        id: getKeybinds
        running: true
        command: [root.keybindParserPath, "--path", root.keybindConfigPath]

        stdout: SplitParser {
            onRead: data => {
                try {
                    root.keybinds = JSON.parse(data)
                    root.ready = true
                    console.log("[HyprlandKeybinds] Loaded", root.keybinds.keybinds.length, "keybinds")
                } catch (e) {
                    console.error("[HyprlandKeybinds] Error parsing keybinds:", e)
                    console.error("[HyprlandKeybinds] Data:", data)
                }
            }
        }

        stderr: SplitParser {
            onRead: data => {
                console.error("[HyprlandKeybinds] stderr:", data)
            }
        }
    }

    Component.onCompleted: {
        console.log("[HyprlandKeybinds] Parser path:", keybindParserPath)
        console.log("[HyprlandKeybinds] Config path:", keybindConfigPath)
    }
}
