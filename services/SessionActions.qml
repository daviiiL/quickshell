pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import qs.common

Singleton {
    id: root

    Process { id: _proc }

    function run(cmd: var): void {
        if (_proc.running) return;
        _proc.command = cmd;
        _proc.running = true;
    }

    function lock(): void {
        GlobalStates.screenLocked = true;
    }

    function suspend():   void { root.run(["systemctl", "suspend"]); }
    function reboot():    void { root.run(["systemctl", "reboot"]); }
    function poweroff():  void { root.run(["systemctl", "poweroff"]); }
    function hibernate(): void { root.run(["systemctl", "hibernate"]); }
    function logout():    void { root.run(["niri", "msg", "action", "quit", "--skip-confirmation"]); }
}
