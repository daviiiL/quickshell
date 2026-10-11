# Control Center — Design Notes

Companion to `preview/control-center.html`. Captures *why* the mockup looks the way it does and *what's needed* to turn it into a real QML surface.

## Goal

A settings-style window for the shell — sidebar-driven navigation, grouped rows, full-width panes. Inspired by macOS System Settings (post-Ventura) more than GNOME. Distinct from the existing `RightPanel`, which stays as the slim sidebar surface.

## Decisions (locked in)

1. **Window type:** centered modal with a dim backdrop. Not anchored to the bar, not full-screen. Sized ~880×600.
2. **Visual style:** macOS-flavored — rounded grouped lists with quiet group labels above each. (Considered: GNOME-style boxed groups with header strips; rejected as denser/heavier than this shell's existing surfaces.)
3. **Sidebar:** ~224px, hairline-separated from pane, holds a `signed-in` chip at top + 2 category sections (`QUICK`, `SYSTEM`). (The former `SESSION` section is gone — session actions live in Quick Settings now, see 5.) Active item gets `surface-container-low` background + 2px accent border-left.
4. **Header bar:** 44px strip with breadcrumb-style title (`SYSTEM · NETWORK`), search input, close button. The 1px-tall gradient hair across the top edge matches the bar / right panel.
5. **Categories included** (in order):
   - Quick Settings — toggle grid (7 tiles in a 4-column grid; the old LOCK tile is gone) + brightness + volume sliders + a **`SESSION` strip**: one row of six compact buttons — Lock / Suspend / Hibernate / Log Out / Restart / Shut Down. Restart and Shut Down carry a subtle `warn` tint on the label. This replaces the old dedicated Power pane.
   - Network — Wi-Fi list, current connection details, Ethernet status
   - Bluetooth — on/off, paired devices with battery, nearby
   - Sound — output/input device pickers, volumes, per-app mix, **system-events toggle** (one checkbox controlling whether unlock + startup sounds play)
   - Display — brightness, scale (segmented), resolution, color appearance, night light, accent-from-wallpaper
   - Battery / Power — **one dual-mode pane**, keyed on whether the machine has a battery. The mockup has a developer switch in the header (`Laptop` / `Desktop` `.seg`) that sets `data-device` on `<body>`; anything marked `data-only="laptop"` disappears in desktop mode.
     - *Laptop:* sidebar `Battery · 85%` with a battery glyph, crumb `SYSTEM · BATTERY`, H1 `Battery` / `Power Profile · Usage · Auto-Suspend`. Shows the donut + remaining + discharge watts, `POWER PROFILE` (Saver / Balanced / Performance), `AUTOMATIC` with **two `.select` columns per row** (`PLUGGED IN` / `ON BATTERY` captions inline on the group label) for Lock after / Screen off after / Suspend after, a `Show percentage in bar` switch, and `BATTERY HEALTH` (maximum capacity only — cycle count dropped).
     - *Desktop:* sidebar `Power` with a ⏻ glyph and no meta, crumb `SYSTEM · POWER`, H1 `Power` / `Power Profile · Automatic`. Same `POWER PROFILE` group; `AUTOMATIC` has a single picker per row; donut, bar-percentage switch and health group are hidden. Every timer picker offers `Never` (the desktop Suspend row shows it).
6. **Typography:** one name per pane (header only; the breadcrumb in 4 and the sidebar section headers in 3 are gone), sentence-case group labels, no decorative uppercase or tracking, five type roles (11/13/15/20/28 px). See docs/superpowers/specs/2026-10-10-design-language-design.md.

## Reusable atoms

All defined in the preview's `<style>` block — port these to QML widgets, ideally living under `widgets/`:

| Atom            | What it is                                              | Existing equivalent          |
| --------------- | ------------------------------------------------------- | ---------------------------- |
| `.switch`       | 32×18 pill toggle, on/off                               | none — new                   |
| `.slider`       | 4px-thick bar with fill + circular thumb                | `widgets/StyledSlider.qml`   |
| `.seg`          | segmented control (e.g. `Saver / Balanced / Performance`) | none — new                 |
| `.select`       | combo-box-looking trigger (`Built-in Speakers ▾`)       | none — new                   |
| `.chip`         | sentence case status chip (`Connected`, `Idle`, `+2 new`) | used inline in RightPanel    |
| `.group`        | rounded grouped list, hairline-separated rows           | none — new                   |
| `.qt-tile`      | 4×2 grid quick-toggle tile, with on-state accent bar    | similar to `QuickToggles.qml`|
| `.session-strip`| one-row strip of six equal-width icon-over-label buttons (`.btn`, `.btn.warn`) | none — new    |
| dual `.select`  | two fixed-width `.select.col` pickers side by side in a row, with inline column captions on the group label (`.group-label.cols-head .col-caps`) | none — new |
| donut           | conic-gradient ring with center cutout, for battery %   | none — new                   |

`.group .row .icon-cell` is a 26×26 sunken square — reuse for any leading-icon pattern.

## Reuse from existing modules (the user's explicit ask)

| Pane         | Reuse                                                                                           |
| ------------ | ----------------------------------------------------------------------------------------------- |
| Network      | `modules/networkoverlay/OverlayContent.qml` (wifi list, scanning, password entry) + `services/Network.qml` |
| Sound        | `modules/rightpanel/SoundSection.qml` + `services/SystemAudio.qml`. Per-app volume is new. **System-events toggle** needs: `Preferences.playSystemSounds` (bool, persisted) + `assets/sounds/unlock.ogg` + `assets/sounds/startup.ogg` (or distro-supplied equivalents) + a Process spawn wrapper (`paplay`/`pw-play`) wired into `LockScreen.qml`'s unlock handler and the shell's startup path. The pane row is just a `ToggleRow` binding to the Preference. |
| Display      | `modules/rightpanel/BrightnessSection.qml` + `services/Brightness.qml`                          |
| Battery / Power | `services/Power.qml` — UPower (presence, %, time remaining, discharge rate, health) + power-profiles-daemon. `hasBattery` picks the pane's mode. Power-profile picker can reuse `preview/power-profile-overlay.html`'s flow |
| Automatic timers | New `services/IdleManager.qml` owning the `swayidle` process; exposes lock / screen-off / suspend timeouts, each with a plugged-in and an on-battery value (desktop uses the plugged-in set), `0` = Never |
| Bluetooth    | **No service exists.** Mocked in preview. Needs `services/Bluetooth.qml` (bluetoothctl / bluez) |
| Session strip | New `services/SessionActions.qml`. Wraps `loginctl lock-session`, `systemctl suspend|hibernate|reboot|poweroff`, niri quit. Rendered in Quick Settings, no pane of its own |
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
       BatteryPane.qml       (dual-mode: Battery on laptops, Power on desktops)
     atoms/                  (until promoted to widgets/)
       SettingsSwitch.qml
       SegmentedControl.qml
       SelectButton.qml
       GroupBox.qml          (the rounded grouped list)
       GroupRow.qml
       BatteryDonut.qml
       SessionStrip.qml
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

- `preview/control-center.html` — interactive mockup (sidebar click swaps pane; header `Laptop` / `Desktop` switch re-renders the Battery/Power pane without reload)
- `preview/control-center.md` — this doc

## Status

**Design phase complete.** No QML implementation yet. The mockup is the source of truth for visuals; this doc captures the rationale and implementation roadmap. Pick this up when ready to build.
