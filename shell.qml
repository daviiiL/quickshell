//@ pragma UseQApplication
//@ pragma IconTheme breeze-dark

import Quickshell
import Quickshell.Io
import QtQuick
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
                // Razer peripheral color sync disabled; palette is now hardcoded, so there is
                // no dynamic source color to drive razer-cli. Configure Razer manually if desired.
                // Connections {
                //     target: Colors
                //     function onSource_colorChanged() {
                //         if (!Preferences.openrazerInstalled)
                //             return;
                //         const toHex = v => Math.round(v * 255).toString(16).padStart(2, "0");
                //         const c = Colors.source_color;
                //         const razercolor = toHex(c.r) + toHex(c.g) + toHex(c.b);
                //         Quickshell.execDetached(["razer-cli", "-c", razercolor]);
                //     }
                // }
            }
        }
    }
}
