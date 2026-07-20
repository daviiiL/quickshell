//@ pragma UseQApplication
//@ pragma IconTheme Adwaita

import Quickshell
import Quickshell.Io
import QtQuick
import qs.common
import qs.services
import qs.modules
import qs.modules.notifications
import qs.modules.keybindhints

ShellRoot {
    Process {
        running: true
        command: ["sh", "-c", "[ -d /proc/acpi/button/lid ] && echo 'laptop' || echo 'desktop'"]

        stdout: StdioCollector {
            onStreamFinished: GlobalStates.isLaptop = this.text.trim() === "laptop"
        }
    }

    IpcHandler {
        target: "theme"

        function toggle(): void { GlobalStates.toggleDarkMode(); }
        function dark():   void { GlobalStates.darkMode = true; }
        function light():  void { GlobalStates.darkMode = false; }
    }

    IpcHandler {
        target: "fcitx"

        // the interceptor entry point: niri binds Ctrl+Space to this call
        function toggle(): void { Fcitx.toggle(); }

        function status(): string {
            return JSON.stringify({
                ready: Fcitx.ready,
                im: Fcitx.currentIm,
                code: Fcitx.currentCode,
                display: Fcitx.currentDisplay,
                index: Fcitx.groupIndex,
                total: Fcitx.groupTotal,
                announcing: Fcitx.announcing
            });
        }
    }

    Loader {
        active: Preferences.isLoaded

        sourceComponent: Component {
            Item {
                MainBar {}
                LeftPanel {}
                RightPanel {}
                NetworkOverlay {}
                PowerProfileOverlay {}
                Osd {}
                AppLauncherPanel {}
                ControlCenter {}
                CliphistOverlay {}
                KeybindHintsOverlay {}
                PopupSurface {}
                LockScreen {}
            }
        }
    }
}

