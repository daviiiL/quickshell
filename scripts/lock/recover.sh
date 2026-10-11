#!/usr/bin/env bash
# Recover from niri's red "locker died" screen.
#
# Run from a TTY (Ctrl+Alt+F3, log in, then):
#   ~/.config/quickshell/scripts/lock/recover.sh
#
# What it does:
#   1. Finds the running niri Wayland socket (or uses $WAYLAND_DISPLAY if set).
#   2. Kills the Quickshell instance on that display, dead or alive.
#   3. Starts a fresh Quickshell and locks it.
# niri keeps the session locked the whole time; the new lock surface replaces
# the stale one. Then switch back to niri's TTY and type your password.
set -u

RUN_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
export XDG_RUNTIME_DIR="$RUN_DIR"

wl_display="${WAYLAND_DISPLAY:-}"
if [[ -z "$wl_display" || ! -S "$RUN_DIR/$wl_display" ]]; then
    wl_display=""
    for sock in "$RUN_DIR"/wayland-*; do
        name="$(basename "$sock")"
        [[ -S "$sock" && "$name" =~ ^wayland-[0-9]+$ ]] || continue
        wl_display="$name"
        break
    done
fi
if [[ -z "$wl_display" ]]; then
    echo "recover: no Wayland socket in $RUN_DIR; is niri running?" >&2
    exit 1
fi
export WAYLAND_DISPLAY="$wl_display"

niri_sock="$(ls "$RUN_DIR"/niri."$wl_display".*.sock 2>/dev/null | head -n1)"
[[ -n "$niri_sock" ]] && export NIRI_SOCKET="$niri_sock"

echo "recover: display=$wl_display"

# Kill only the Quickshell that belongs to this display.
for pid in $(pgrep -x quickshell; pgrep -x qs); do
    if tr '\0' '\n' < "/proc/$pid/environ" 2>/dev/null | grep -qx "WAYLAND_DISPLAY=$wl_display"; then
        echo "recover: killing stale quickshell pid $pid"
        kill "$pid" 2>/dev/null
    fi
done
sleep 1

setsid -f quickshell >/dev/null 2>&1 < /dev/null
for _ in $(seq 1 30); do
    sleep 0.5
    if qs ipc call lock lock >/dev/null 2>&1; then
        echo "recover: new Quickshell is up and locked. Switch back to niri's TTY and enter your password."
        exit 0
    fi
done

echo "recover: Quickshell started but the IPC lock call never succeeded; check 'qs log'." >&2
exit 1
