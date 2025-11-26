import ".."
pragma Singleton
import QtQuick
import Quickshell

Singleton {
    id: root

    function suspend() {
        Quickshell.execDetached(["bash", "-c", "systemctl suspend || loginctl suspend"]);
    }

    function poweroff() {
        Quickshell.execDetached(["bash", "-c", "systemctl poweroff || loginctl poweroff"]);
    }

    function reboot() {
        Quickshell.execDetached(["bash", "-c", "systemctl reboot || loginctl reboot"]);
    }
}
