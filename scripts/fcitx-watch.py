#!/usr/bin/env python3
"""fcitx5 input-method bridge for quickshell (event-driven, no polling).

The shell is the only switch path: niri binds the trigger key to
`qs ipc call fcitx toggle`, which lands here as a stdin command. The current
IM is read once at startup, re-read immediately after every command, and
re-read when fcitx5 (re)appears on the bus. fcitx5's own UI (classicui)
stays fully active; with ShareInputState=All there is no other source of
IM changes, so no poll loop is needed.
Commands on stdin: {"cmd":"toggle"} / {"cmd":"set","im":…}.
"""
import json
import sys
import threading

import dbus
import dbus.mainloop.glib
from gi.repository import GLib

FCITX_BUS = "org.fcitx.Fcitx5"
CONTROLLER_IFACE = "org.fcitx.Fcitx.Controller1"


def emit(obj):
    sys.stdout.write(json.dumps(obj, ensure_ascii=False) + "\n")
    sys.stdout.flush()


class Bridge:
    def __init__(self):
        self.bus = dbus.SessionBus()
        self.last_im = None
        self.ready = False

        self.bus.add_signal_receiver(
            self.on_name_owner_changed,
            signal_name="NameOwnerChanged",
            dbus_interface="org.freedesktop.DBus",
            path="/org/freedesktop/DBus",
            arg0=FCITX_BUS)

        self.read_state()

    def controller(self):
        obj = self.bus.get_object(FCITX_BUS, "/controller")
        return dbus.Interface(obj, CONTROLLER_IFACE)

    def read_state(self):
        """Read the current IM from fcitx5 and emit on change."""
        try:
            ctrl = self.controller()
            info = ctrl.CurrentInputMethodInfo()
            # (uniqueName, name, _, icon, label, langCode, addon, …)
            im, name, label = str(info[0]), str(info[1]), str(info[4])
            if im and im != self.last_im:
                index, total = 0, 0
                try:
                    group = str(ctrl.CurrentInputMethodGroup())
                    _layout, items = ctrl.InputMethodGroupInfo(group)
                    total = len(items)
                    for i, (im_name, _l) in enumerate(items):
                        if str(im_name) == im:
                            index = i + 1
                            break
                except dbus.exceptions.DBusException:
                    pass
                self.last_im = im
                emit({"ev": "im", "im": im, "name": name,
                      "label": label, "index": index, "total": total})
                if not self.ready:
                    self.ready = True
                    emit({"ev": "ready", "value": True})
        except dbus.exceptions.DBusException:
            self.mark_down()
        return False  # usable as a one-shot GLib timeout callback

    def mark_down(self):
        if self.ready:
            self.ready = False
            self.last_im = None
            emit({"ev": "ready", "value": False})

    def on_name_owner_changed(self, _name, _old, new):
        if str(new) == "":
            self.mark_down()
        else:
            # fcitx5 (re)appeared; give it a moment to settle, then sync once
            GLib.timeout_add(500, self.read_state)

    def handle_command(self, line):
        try:
            cmd = json.loads(line)
        except ValueError:
            return
        kind = cmd.get("cmd")
        if kind == "toggle":
            try:
                self.controller().Toggle()
            except dbus.exceptions.DBusException:
                pass
        elif kind == "set":
            try:
                self.controller().SetCurrentIM(str(cmd.get("im", "")))
            except dbus.exceptions.DBusException:
                pass
        else:
            return
        # the switch just happened through us — read back and announce now
        self.read_state()


def main():
    dbus.mainloop.glib.DBusGMainLoop(set_as_default=True)
    loop = GLib.MainLoop()
    bridge = Bridge()

    def stdin_reader():
        # EOF alone must not kill the bridge (standalone runs have no stdin)
        for line in sys.stdin:
            line = line.strip()
            if line:
                GLib.idle_add(bridge.handle_command, line)

    threading.Thread(target=stdin_reader, daemon=True).start()

    try:
        loop.run()
    except KeyboardInterrupt:
        pass


if __name__ == "__main__":
    main()
