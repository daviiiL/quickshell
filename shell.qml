//@ pragma UseQApplication
//@ pragma IconTheme breeze-dark

import Quickshell
import Quickshell.Io
import QtQuick
import qs.common
import qs.services
import qs.modules
import qs.modules.notifications

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

    Loader {
        active: Preferences.isLoaded

        sourceComponent: Component {
            Item {
                MainBar {}
                LeftPanel {}
                RightPanel {}
                NetworkOverlay {}
                Osd {}
                AppLauncherPanel {}
                PopupSurface {}
            }
        }
    }
}
