# Control Center — Design Notes

Companion to `preview/control-center.html`. Captures *why* the mockup looks the way it does and *what's needed* to turn it into a real QML surface.

## Goal

A settings-style window for the shell — sidebar-driven navigation, grouped rows, full-width panes. Inspired by macOS System Settings (post-Ventura) more than GNOME. Distinct from the existing `RightPanel`, which stays as the slim sidebar surface.

## Decisions (locked in)

1. **Window type:** centered modal with a dim backdrop. Not anchored to the bar, not full-screen. Sized ~880×600.
2. **Visual style:** macOS-flavored — rounded grouped lists with quiet group labels above each. (Considered: GNOME-style boxed groups with header strips; rejected as denser/heavier than this shell's existing surfaces.)
3. **Sidebar:** ~224px, hairline-separated from pane, holds a `signed-in` chip at top + 3 category sections (`QUICK`, `SYSTEM`, `SESSION`). Active item gets `surface-container-low` background + 2px accent border-left.
4. **Header bar:** 44px strip with breadcrumb-style title (`SYSTEM · NETWORK`), search input, close button. The 1px-tall gradient hair across the top edge matches the bar / right panel.
5. **Categories included** (in order):
   - Quick Settings — 4×2 toggle grid + brightness + volume sliders (the "control center" feel)
   - Network — Wi-Fi list, current connection details, Ethernet status
   - Bluetooth — on/off, paired devices with battery, nearby
   - Sound — output/input device pickers, volumes, per-app mix, **system-events toggle** (one checkbox controlling whether unlock + startup sounds play)
   - Display — brightness, scale (segmented), resolution, color appearance, night light, accent-from-wallpaper
   - Battery — donut + time remaining, power profile (segmented), auto-suspend timers, battery health
   - Power (session) — Lock / Suspend / Log Out / Restart / Shut Down / Hibernate as 3×2 button grid

## Reusable atoms

All defined in the preview's `<style>` block — port these to QML widgets, ideally living under `widgets/`:

| Atom            | What it is                                              | Existing equivalent          |
| --------------- | ------------------------------------------------------- | ---------------------------- |
| `.switch`       | 32×18 pill toggle, on/off                               | none — new                   |
| `.slider`       | 4px-thick bar with fill + circular thumb                | `widgets/StyledSlider.qml`   |
| `.seg`          | segmented control (e.g. `SAVER / BALANCED / PERF`)      | none — new                   |
| `.select`       | combo-box-looking trigger (`Built-in Speakers ▾`)       | none — new                   |
| `.chip`         | small-caps status chip (`CONNECTED`, `IDLE`, `+2 NEW`)  | used inline in RightPanel    |
| `.group`        | rounded grouped list, hairline-separated rows           | none — new                   |
| `.qt-tile`      | 4×2 grid quick-toggle tile, with on-state accent bar    | similar to `QuickToggles.qml`|
| `.session-btn`  | tall square button (icon + label + sub)                 | none — new                   |
| donut           | conic-gradient ring with center cutout, for battery %   | none — new                   |

`.group .row .icon-cell` is a 26×26 sunken square — reuse for any leading-icon pattern.

## Reuse from existing modules (the user's explicit ask)

| Pane         | Reuse                                                                                           |
| ------------ | ----------------------------------------------------------------------------------------------- |
| Network      | `modules/networkoverlay/OverlayContent.qml` (wifi list, scanning, password entry) + `services/Network.qml` |
| Sound        | `modules/rightpanel/SoundSection.qml` + `services/SystemAudio.qml`. Per-app volume is new. **System-events toggle** needs: `Preferences.playSystemSounds` (bool, persisted) + `assets/sounds/unlock.ogg` + `assets/sounds/startup.ogg` (or distro-supplied equivalents) + a Process spawn wrapper (`paplay`/`pw-play`) wired into `LockScreen.qml`'s unlock handler and the shell's startup path. The pane row is just a `ToggleRow` binding to the Preference. |
| Display      | `modules/rightpanel/BrightnessSection.qml` + `services/Brightness.qml`                          |
| Battery      | `modules/mainbar/BatteryButton.qml` battery state. Power-profile picker can reuse `preview/power-profile-overlay.html`'s flow |
| Bluetooth    | **No service exists.** Mocked in preview. Needs `services/Bluetooth.qml` (bluetoothctl / bluez) |
| Session      | New. Wraps `loginctl lock-session`, `systemctl suspend|reboot|poweroff`, niri quit              |
| Quick Settings | Existing `modules/rightpanel/QuickToggles.qml` patterns                                       |

## Implementation sketch (for a future session)

When picking this up:

1. **Create the module file** `modules/ControlCenter.qml` — `Scope` containing a `Variants { model: Quickshell.screens }` with a `PanelWindow` per output. Layer `WlrLayer.Overlay`, namespace `quickshell:controlcenter`, no anchors (centered). Use `implicitWidth: 880; implicitHeight: 600`.
2. **Add a `GlobalStates.controlCenterOpen` flag** in `common/GlobalStates.qml` + a `controlCenterSource` string (mirroring `rightPanelSource`).
3. **Add IPC handler** in the new module: `target: "controlcenter"`, functions `toggle/open/close`. Wire to a niri keybind (Super+, would be natural).
4. **Backdrop:** a full-screen `Rectangle` with `Qt.alpha("#000", 0.45)` + a `MouseArea` that closes on click. Sits behind the window, above everything else.
5. **Subdirectory layout** for the pane components — mirror RightPanel's convention:
   ```
   modules/controlcenter/
     Sidebar.qml
     panes/
       QuickPane.qml
       NetworkPane.qml
       BluetoothPane.qml
       SoundPane.qml
       DisplayPane.qml
       BatteryPane.qml
       SessionPane.qml
     atoms/                  (until promoted to widgets/)
       SettingsSwitch.qml
       SegmentedControl.qml
       SelectButton.qml
       GroupBox.qml          (the rounded grouped list)
       GroupRow.qml
       BatteryDonut.qml
       SessionButton.qml
   ```
6. **Pane switching:** the sidebar writes to a `currentPane` string property on the ControlCenter root. Each pane is a `Loader` gated by `active: currentPane === "network"` etc. Or use a `StackLayout`/`SwipeView` if you want transitions.
7. **Open/close animation:** match the right panel's pattern — `opacity` on the panel surface + a `scale` transform from 0.97 to 1.0. Use `Theme.anim.durations.xs * 1.6` + `Easing.OutCubic` (consistent with the recently-tuned right panel).
8. **Bluetooth service** is a prereq. Spike it on its own first: `services/Bluetooth.qml` wrapping `bluetoothctl` (subscribe to `--monitor` for changes) and exposing `enabled`, `discoverable`, `pairedDevices`, `nearbyDevices`, `scanning`. If you don't want to build BT support yet, ship the control center with the Bluetooth pane stubbed/disabled.

## Open questions for next session

- **Search input** — placeholder only in the mockup. Real impl would filter sidebar items, or do system-wide setting search. Decide scope.
- **Power profile** — does the user have `power-profiles-daemon` installed? Confirm before wiring. `preview/power-profile-overlay.html` already exists, suggesting prior intent.
- **Per-app volume** — needs PipeWire/PulseAudio per-stream introspection (`pactl list sink-inputs`). Worth the work, or drop?
- **Sidebar `meta` text** ("60%", "85%", "my-net") — these reactively follow service state. Easy in QML but verify it doesn't cause re-paint thrash with many bindings.
- **Header search field width** — current 220px feels right at 880px window; revisit if window width changes.
- **System-events sound (Sound pane)** — one combined checkbox or split into unlock-vs-startup? Default: combined (single `Preferences.playSystemSounds`). Sound asset source: shell-bundled (`assets/sounds/`) or freedesktop theme (`/usr/share/sounds/freedesktop/stereo/`)? Default: bundled, falling back to freedesktop if assets missing. Playback binary: `paplay` (PulseAudio compat layer, present on most distros) or `pw-play` (PipeWire native)? Default: `paplay` for compatibility; the wrapper can prefer `pw-play` if available.

## Files

- `preview/control-center.html` — interactive mockup (sidebar click swaps pane)
- `preview/control-center.md` — this doc

## Status

**Design phase complete.** No QML implementation yet. The mockup is the source of truth for visuals; this doc captures the rationale and implementation roadmap. Pick this up when ready to build.
