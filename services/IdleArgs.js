.pragma library

const LOCK_CMD = "qs ipc call lock lock";
const SCREEN_OFF_CMD = "niri msg action power-off-monitors";
const SCREEN_ON_CMD = "niri msg action power-on-monitors";
const SUSPEND_CMD = "systemctl suspend";

function seconds(v) {
    const n = Number(v);
    return Number.isFinite(n) && n > 0 ? Math.round(n) : 0;
}

function isEmpty(set) {
    const s = set || {};
    return seconds(s.lock) === 0 && seconds(s.screenOff) === 0 && seconds(s.suspend) === 0;
}

function build(set) {
    const s = set || {};
    const args = [];
    if (seconds(s.lock) > 0)
        args.push("timeout", String(seconds(s.lock)), LOCK_CMD);
    if (seconds(s.screenOff) > 0)
        args.push("timeout", String(seconds(s.screenOff)), SCREEN_OFF_CMD, "resume", SCREEN_ON_CMD);
    if (seconds(s.suspend) > 0)
        args.push("timeout", String(seconds(s.suspend)), SUSPEND_CMD);
    args.push("before-sleep", LOCK_CMD);
    return args;
}
