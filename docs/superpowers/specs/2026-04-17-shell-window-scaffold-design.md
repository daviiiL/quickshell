# Shell Window Scaffold — Design Spec

**Date:** 2026-04-17
**Status:** Approved (pending user re-review)
**Scope:** Rebuild a minimal top-level UI surface on top of the current bare `shell.qml`, giving the shell three windows: a bottom `MainBar` (always on, auto-hides in focused mode) and two retractable side panels (`LeftPanel`, `RightPanel`) that slide in from their edges on IPC toggle.

## Goals

1. Restore a functional shell layout on the `niri-dark` branch without reintroducing legacy content.
2. Provide a consistent scaffolding pattern for future UI work: `modules/` holds top-level windows, services/widgets stay untouched.
3. Match the legacy conventions documented in `docs/legacy-ui-reference.md` so future modules can be added without surprise.
4. Clean up dead scaffolding left behind in `shell.qml` after the strip.

## Non-Goals

- No real widget content. Each window gets a single placeholder label. Populating content is a separate follow-up.
- No `LazyLoader` chains, no paint-priority tricks. All three windows mount eagerly under the existing `Preferences.isLoaded` gate.
- No new services, no new widgets, no theme overhaul.
- No reintroduction of legacy modules (`ControlCenter`, `NotificationCenterPanel`, `WallpaperPicker`, etc.) — their `GlobalStates` fields remain but are unused by the new surface.

## Architecture

```
/home/davidas/.config/quickshell/
├── shell.qml                 ← cleaned up; loads the three modules
├── common/
│   ├── GlobalStates.qml      ← + leftPanelOpen, rightPanelOpen
│   └── Theme.qml             ← + ui.mainBarHeight, ui.sidePanelWidth
└── modules/                  ← NEW
    ├── MainBar.qml
    ├── LeftPanel.qml
    └── RightPanel.qml
```

Each module file is a self-contained `Scope { Variants { model: Quickshell.screens; PanelWindow { … } } }`. This is the legacy per-monitor pattern. Each side-panel module owns its own `IpcHandler`.

## Component specs

### `modules/MainBar.qml`

| Field | Value |
| --- | --- |
| Layer | `WlrLayer.Top` |
| Namespace | `quickshell:mainbar` |
| Anchors | `bottom`, `left`, `right` |
| Implicit height | `Theme.ui.mainBarHeight` (new token, 48) |
| Exclusive zone | `Preferences.focusedMode ? 0 : implicitHeight` |
| Visible | `!Preferences.focusedMode` |
| Window color | transparent |
| Inner surface | `Rectangle { color: Colors.surface }` filling the window |
| Content | centered `StyledText { text: "Main Bar" }` |
| IPC | none |

Behavior summary: always mounted per monitor; present as an exclusive-zone strip at the bottom; disappears entirely when `Preferences.focusedMode` is true so tiled windows can reclaim the pixels.

### `modules/LeftPanel.qml` and `modules/RightPanel.qml`

The two files are mirror images on the X axis; described together here.

| Field | Value (LeftPanel) | Value (RightPanel) |
| --- | --- | --- |
| Layer | `WlrLayer.Overlay` | `WlrLayer.Overlay` |
| Namespace | `quickshell:leftpanel` | `quickshell:rightpanel` |
| Anchors | `top`, `bottom`, `left` (edge-hugging vertical strip, **not** full-screen) | `top`, `bottom`, `right` |
| Implicit width | `Theme.ui.sidePanelWidth` (new token, 320) | same |
| Exclusive zone | `0` | `0` |
| Window `visible` | `GlobalStates.leftPanelOpen \|\| slide.running` — keeps the Wayland surface alive during the slide-out animation, then destroys it | same, gated on `rightPanelOpen` |
| Content root | inner `Rectangle` filling the window, color `Colors.surface` | same |
| Slide animation | inner rectangle has `transform: Translate { id: slideT; x: GlobalStates.leftPanelOpen ? 0 : -Theme.ui.sidePanelWidth }` with `Behavior on x { NumberAnimation { id: slide; duration: Theme.anim.durations.sm; easing.type: Easing.BezierSpline; easing.bezierCurve: Theme.anim.curves.standard } }` | same, with closed `x: +Theme.ui.sidePanelWidth` |
| Keyboard focus | `focus: true` on the inner rectangle; `Keys.onEscapePressed: GlobalStates.leftPanelOpen = false` | same, closing `rightPanelOpen` |
| Content | centered `StyledText { text: "Left Panel" }` | `"Right Panel"` |
| IPC | `IpcHandler { target: "leftpanel"; function toggle(){...} function open(){...} function close(){...} }` | `target: "rightpanel"`; same three functions |

Behavior summary: the panel's `PanelWindow` only occupies its own `sidePanelWidth`-wide strip — it never covers the rest of the screen and so cannot intercept input outside its own bounds. While closed, the window is destroyed (no Wayland surface). Opening sets `*Open = true`, which makes the window visible and drives the inner `Translate` from off-screen to 0 via the standard animation curve. Closing sets `*Open = false`, which animates the translate off-screen; the `visible` binding stays true while `slide.running`, so the slide-out animation completes before the surface is destroyed. `Escape` dismisses. External callers trigger via `qs ipc call leftpanel toggle` (or `rightpanel`), and `open` / `close` for explicit states.

## State

### `common/GlobalStates.qml` — additions

```qml
property bool leftPanelOpen: false
property bool rightPanelOpen: false
```

Leave every other existing flag (`controlCenterPanelOpen`, `notificationCenterOpen`, `wallpaperPickerOpen`, `appLauncherOpen`, `mediaControlsOpen`, `screenLocked*`, `isLaptop`, `debugMode`) in place — still referenced by the `Preferences` / `Authentication` services and orthogonal to this change.

### `common/Theme.qml` — additions

Append inside `component ThemeStyle: QtObject { … }` alongside the existing `topBarHeight` / `leftBarWidth`:

```qml
readonly property int mainBarHeight: 48
readonly property int sidePanelWidth: 320
```

Animation tokens are reused from the existing `Theme.anim` subtree — no additions there.

## IPC surface

| Target | Function | Effect |
| --- | --- | --- |
| `leftpanel` | `toggle()` | `GlobalStates.leftPanelOpen = !GlobalStates.leftPanelOpen` |
| `leftpanel` | `open()` | `GlobalStates.leftPanelOpen = true` |
| `leftpanel` | `close()` | `GlobalStates.leftPanelOpen = false` |
| `rightpanel` | `toggle()` | `GlobalStates.rightPanelOpen = !GlobalStates.rightPanelOpen` |
| `rightpanel` | `open()` | `GlobalStates.rightPanelOpen = true` |
| `rightpanel` | `close()` | `GlobalStates.rightPanelOpen = false` |

`MainBar` has no IPC. Focused-mode behavior is driven entirely by `Preferences.focusedMode`, which already has its own control path.

## `shell.qml` cleanup

Dead weight to remove while rewiring:

1. The commented-out Razer `Connections` block inside the current `Loader`'s `Item`. Pure dead code post-strip.
2. `property bool preferencesLoaded: Preferences.isLoaded` — unused (nothing external reads `shell.qml`'s root properties).
3. `asynchronous: false` on the `Loader` — that's the default.

Final shape of the file:

```qml
//@ pragma UseQApplication
//@ pragma IconTheme breeze-dark

import Quickshell
import Quickshell.Io
import QtQuick
import qs.common
import qs.services
import qs.modules

ShellRoot {
    Process {
        running: true
        command: ["sh", "-c", "[ -d /proc/acpi/button/lid ] && echo 'laptop' || echo 'desktop'"]
        stdout: StdioCollector {
            onStreamFinished: GlobalStates.isLaptop = this.text.trim() === "laptop"
        }
    }

    Loader {
        active: Preferences.isLoaded
        sourceComponent: Component {
            Item {
                MainBar {}
                LeftPanel {}
                RightPanel {}
            }
        }
    }
}
```

The laptop-detection `Process` remains because `GlobalStates.isLaptop` is load-bearing elsewhere.

## Verification plan

Manual, since this is a display-layer change and there is no test harness in the repo:

1. `qs -p /home/davidas/.config/quickshell shell.qml` launches cleanly (no QML warnings in stderr).
2. `MainBar` renders as a 48-px strip at the bottom of each monitor; Niri tiles above it; toggling `Preferences.focusedMode` hides the bar and releases its exclusive zone.
3. `qs ipc call leftpanel toggle` slides the left panel in from the left; a second call slides it back out. `open` and `close` are idempotent.
4. Same for `qs ipc call rightpanel toggle` / `open` / `close` from the right edge.
5. `Escape` while a side panel has focus closes it.
6. Closed side panels leave no Wayland surface (`wayland-info` / `swaymsg -t get_tree`-equivalent under Niri shows no `quickshell:leftpanel` surface while closed).
7. Multi-monitor: each module renders one instance per screen. (Can only be checked if a second monitor is attached; otherwise visual verification is limited to the primary.)

## Open questions

None at time of writing. All three brainstorming questions (retractable mechanism, main-bar exclusive behavior, content depth) were answered by the user: **A / C / A**.
