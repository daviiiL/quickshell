//@ pragma UseQApplication
//@ pragma IconTheme breeze-dark

import Quickshell
import Quickshell.Io

import qs.modules
import qs.common

ShellRoot {

    Process {
        running: true

        command: ["sh", "-c", "[ -d /proc/acpi/button/lid ] && echo 'laptop' || echo 'desktop'"]

        stdout: StdioCollector {
            onStreamFinished: {
                GlobalStates.isLaptop = this.text.trim() === "laptop";
                // console.debug(this.text.trim() == "laptop");
            }
        }
    }

    PowerPanel {}
    LeftBar {
        id: leftBar

        onInstantiated: () => {
            topBarLoader.loading = true;
        }
    }
    LazyLoader {
        id: topBarLoader
        TopBar {}
    }
    Lockscreen {}
    NotificationPopup {}
    NotificationCenterPanel {}
    ControlCenter {}
    WallpaperPicker {}
}
