//@ pragma UseQApplication
//@ pragma IconTheme breeze-dark

import Quickshell
import Quickshell.Io
import QtQuick
import qs.modules
import qs.common
import qs.services

ShellRoot {

    Process {
        running: true

        command: ["sh", "-c", "[ -d /proc/acpi/button/lid ] && echo 'laptop' || echo 'desktop'"]

        stdout: StdioCollector {
            onStreamFinished: {
                GlobalStates.isLaptop = this.text.trim() === "laptop";
            }
        }
    }

    property bool preferencesLoaded: Preferences.isLoaded

    Loader {
        active: Preferences.isLoaded
        asynchronous: false

        sourceComponent: Component {
            Item {
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
                MediaControls {}
                AppLauncherPanel {}
            }
        }
    }
}
