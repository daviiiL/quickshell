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

                Connections {
                    target: Colors

                    function onSource_colorChanged() {
                        if (Preferences.openrazerInstalled) {
                            const sourceColor = Colors.source_color;
                            const r = sourceColor.r;
                            const g = sourceColor.g;
                            const b = sourceColor.b;

                            const to255 = v => Math.round(v * 255);
                            const toHex2 = v => v.toString(16).padStart(2, "0");

                            const R = to255(r);
                            const G = to255(g);
                            const B = to255(b);

                            const razercolor = toHex2(R) + toHex2(G) + toHex2(B);

                            const cmd = ["razer-cli", '-c', razercolor];
                            Quickshell.execDetached(cmd);
                            // Quickshell.execDetached(["notify-send", "-a", "Razer CLI", "Syncing peripheral lighting", "Applying theme color to razer devices"]);
                        }
                    }
                }
            }
        }
    }
}
