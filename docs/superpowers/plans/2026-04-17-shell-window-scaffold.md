# Shell Window Scaffold Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a retractable left panel, retractable right panel, and always-on bottom main bar to the stripped `niri-dark` shell, plus clean up `shell.qml`.

**Architecture:** Three new per-monitor QML modules under a new `modules/` directory. Side panels are slide-in overlays toggled via IPC and a `GlobalStates` flag; the main bar is an exclusive-zone layer that auto-hides when `Preferences.focusedMode` is true. No LazyLoader, no new services, no new widgets. Placeholder labels only.

**Tech Stack:** Quickshell (QML) — `PanelWindow`, `Scope`/`Variants` for per-screen instancing, `WlrLayershell` attached properties for Wayland layer shell, `IpcHandler` for external toggles. Existing singletons (`Colors`, `Theme`, `GlobalStates`, `Preferences`) and `StyledText` from `qs.widgets`.

**User preference for this repo:** Do NOT run `git commit`. Every task below writes files; commits are the user's call. Classic TDD doesn't apply — this is pure display QML with no test harness, so verification steps are manual (launch `qs` + visual check + IPC calls).

**Design spec:** `docs/superpowers/specs/2026-04-17-shell-window-scaffold-design.md`

---

## File plan

| Action | Path | Responsibility |
| --- | --- | --- |
| Modify | `common/Theme.qml` | Add `ui.mainBarHeight`, `ui.sidePanelWidth` tokens |
| Modify | `common/GlobalStates.qml` | Add `leftPanelOpen`, `rightPanelOpen` flags |
| Create | `modules/MainBar.qml` | Always-on bottom bar with focused-mode auto-hide |
| Create | `modules/LeftPanel.qml` | Slide-in retractable left panel + IPC handler |
| Create | `modules/RightPanel.qml` | Slide-in retractable right panel + IPC handler |
| Modify | `shell.qml` | Remove dead Razer/loader cruft; import `qs.modules`; instantiate the three windows |

---

## Task 1: Add Theme tokens

**Files:**
- Modify: `common/Theme.qml` — inside `component ThemeStyle: QtObject { … }` block (around line 47–55)

- [ ] **Step 1: Read current `ThemeStyle` block**

Open `common/Theme.qml`. Confirm `component ThemeStyle: QtObject { … }` currently contains `topBarHeight: 48`, `leftBarWidth: 76`, `borderWidth: 1`, `iconSize: 24`.

- [ ] **Step 2: Add two new readonly tokens**

Replace:

```qml
    component ThemeStyle: QtObject {
        readonly property ThemeRadius radius: ThemeRadius {}
        readonly property ThemeElevation elevation: ThemeElevation {}
        readonly property ThemePadding padding: ThemePadding {}
        readonly property int topBarHeight: 48
        readonly property int leftBarWidth: 76
        readonly property int borderWidth: 1
        readonly property int iconSize: 24
    }
```

with:

```qml
    component ThemeStyle: QtObject {
        readonly property ThemeRadius radius: ThemeRadius {}
        readonly property ThemeElevation elevation: ThemeElevation {}
        readonly property ThemePadding padding: ThemePadding {}
        readonly property int topBarHeight: 48
        readonly property int leftBarWidth: 76
        readonly property int mainBarHeight: 48
        readonly property int sidePanelWidth: 320
        readonly property int borderWidth: 1
        readonly property int iconSize: 24
    }
```

- [ ] **Step 3: Verify shell still launches**

Run: `qs -p /home/davidas/.config/quickshell shell.qml`

Expected: shell starts without QML warnings referencing `Theme`. The new tokens are unused at this point so there should be zero visual difference. Kill with Ctrl-C.

---

## Task 2: Add GlobalStates flags

**Files:**
- Modify: `common/GlobalStates.qml`

- [ ] **Step 1: Read current singleton**

Open `common/GlobalStates.qml`. Confirm it's a `Singleton { … }` with `property bool` declarations.

- [ ] **Step 2: Add the two new flags**

Add these lines inside the `Singleton { … }` block, just under the existing `// Panels / overlays` group (around line 18–19):

```qml
    property bool leftPanelOpen: false
    property bool rightPanelOpen: false
```

The surrounding block should then read:

```qml
    // Panels / overlays
    property bool sidebarOpen: false
    property bool notificationCenterOpen: false
    property bool powerPanelOpen: false
    property bool controlCenterPanelOpen: false
    property bool wallpaperPickerOpen: false
    property bool appLauncherOpen: false
    property bool leftPanelOpen: false
    property bool rightPanelOpen: false
```

- [ ] **Step 3: Verify shell still launches**

Run: `qs -p /home/davidas/.config/quickshell shell.qml`

Expected: clean launch, no QML warnings. Kill with Ctrl-C.

---

## Task 3: Create `modules/MainBar.qml`

**Files:**
- Create: `modules/MainBar.qml`

- [ ] **Step 1: Create the `modules/` directory**

Run: `mkdir -p /home/davidas/.config/quickshell/modules`

- [ ] **Step 2: Write `modules/MainBar.qml`**

Create the file with exactly this content:

```qml
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.common
import qs.services
import qs.widgets

Scope {
    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: root
            required property var modelData
            screen: modelData

            WlrLayershell.layer: WlrLayer.Top
            WlrLayershell.namespace: "quickshell:mainbar"

            anchors {
                bottom: true
                left: true
                right: true
            }

            implicitHeight: Theme.ui.mainBarHeight
            exclusiveZone: Preferences.focusedMode ? 0 : implicitHeight
            visible: !Preferences.focusedMode

            color: "transparent"

            Rectangle {
                anchors.fill: parent
                color: Colors.surface

                StyledText {
                    anchors.centerIn: parent
                    text: "Main Bar"
                }
            }
        }
    }
}
```

- [ ] **Step 3: Verify file parses (no shell change yet)**

Run: `qs -p /home/davidas/.config/quickshell shell.qml`

Expected: the file isn't imported yet so it won't instantiate, but the shell should still launch cleanly. Kill with Ctrl-C. (Full verification happens in Task 7 after wiring.)

---

## Task 4: Create `modules/LeftPanel.qml`

**Files:**
- Create: `modules/LeftPanel.qml`

- [ ] **Step 1: Write `modules/LeftPanel.qml`**

Create the file with exactly this content:

```qml
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.common
import qs.services
import qs.widgets

Scope {
    IpcHandler {
        target: "leftpanel"

        function toggle(): void {
            GlobalStates.leftPanelOpen = !GlobalStates.leftPanelOpen;
        }

        function open(): void {
            GlobalStates.leftPanelOpen = true;
        }

        function close(): void {
            GlobalStates.leftPanelOpen = false;
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: root
            required property var modelData
            screen: modelData

            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.namespace: "quickshell:leftpanel"

            anchors {
                top: true
                bottom: true
                left: true
            }

            implicitWidth: Theme.ui.sidePanelWidth
            exclusiveZone: 0
            visible: GlobalStates.leftPanelOpen || slideAnim.running

            color: "transparent"

            Rectangle {
                id: panelSurface
                anchors.fill: parent
                color: Colors.surface
                focus: true

                Keys.onEscapePressed: GlobalStates.leftPanelOpen = false

                transform: Translate {
                    id: slideT
                    x: GlobalStates.leftPanelOpen ? 0 : -Theme.ui.sidePanelWidth

                    Behavior on x {
                        NumberAnimation {
                            id: slideAnim
                            duration: Theme.anim.durations.sm
                            easing.type: Easing.BezierSpline
                            easing.bezierCurve: Theme.anim.curves.standard
                        }
                    }
                }

                StyledText {
                    anchors.centerIn: parent
                    text: "Left Panel"
                }
            }
        }
    }
}
```

- [ ] **Step 2: Verify file parses (no shell change yet)**

Run: `qs -p /home/davidas/.config/quickshell shell.qml`

Expected: clean launch, `qs ipc list` now shows a `leftpanel` target (the `IpcHandler` lives at Scope root, not inside `Variants`, so it registers regardless of screen count). Test:

Run: `qs ipc list`
Expected output contains a line with `leftpanel`.

Run: `qs ipc call leftpanel toggle`
Expected: no visible change (panel window isn't instantiated yet because `modules/LeftPanel.qml` isn't imported in `shell.qml`). But the call should not error — the handler just flips a bool.

Run: `qs ipc call leftpanel close` (to reset state before continuing).

Kill the shell with Ctrl-C.

---

## Task 5: Create `modules/RightPanel.qml`

**Files:**
- Create: `modules/RightPanel.qml`

- [ ] **Step 1: Write `modules/RightPanel.qml`**

Create the file with exactly this content (mirror of LeftPanel — anchors right, closed translate is positive, IPC target is `rightpanel`, uses `rightPanelOpen`):

```qml
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.common
import qs.services
import qs.widgets

Scope {
    IpcHandler {
        target: "rightpanel"

        function toggle(): void {
            GlobalStates.rightPanelOpen = !GlobalStates.rightPanelOpen;
        }

        function open(): void {
            GlobalStates.rightPanelOpen = true;
        }

        function close(): void {
            GlobalStates.rightPanelOpen = false;
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: root
            required property var modelData
            screen: modelData

            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.namespace: "quickshell:rightpanel"

            anchors {
                top: true
                bottom: true
                right: true
            }

            implicitWidth: Theme.ui.sidePanelWidth
            exclusiveZone: 0
            visible: GlobalStates.rightPanelOpen || slideAnim.running

            color: "transparent"

            Rectangle {
                id: panelSurface
                anchors.fill: parent
                color: Colors.surface
                focus: true

                Keys.onEscapePressed: GlobalStates.rightPanelOpen = false

                transform: Translate {
                    id: slideT
                    x: GlobalStates.rightPanelOpen ? 0 : Theme.ui.sidePanelWidth

                    Behavior on x {
                        NumberAnimation {
                            id: slideAnim
                            duration: Theme.anim.durations.sm
                            easing.type: Easing.BezierSpline
                            easing.bezierCurve: Theme.anim.curves.standard
                        }
                    }
                }

                StyledText {
                    anchors.centerIn: parent
                    text: "Right Panel"
                }
            }
        }
    }
}
```

- [ ] **Step 2: Verify file parses and IPC registers**

Run: `qs -p /home/davidas/.config/quickshell shell.qml`

Expected: clean launch. `qs ipc list` now shows both `leftpanel` and `rightpanel`.

Run: `qs ipc list`
Expected output contains both `leftpanel` and `rightpanel`.

Kill with Ctrl-C.

---

## Task 6: Rewire and clean up `shell.qml`

**Files:**
- Modify: `shell.qml`

- [ ] **Step 1: Read current `shell.qml`**

Current content (48 lines) includes:
- `Process` for laptop detection → `GlobalStates.isLaptop`
- Unused `property bool preferencesLoaded: Preferences.isLoaded`
- `Loader { asynchronous: false; … }` wrapping an empty `Item` with a commented-out Razer block

- [ ] **Step 2: Replace `shell.qml` with the cleaned-up, wired version**

Overwrite the whole file with:

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

Changes versus the prior file:
- Added `import qs.modules`.
- Dropped the unused `property bool preferencesLoaded: Preferences.isLoaded`.
- Dropped `asynchronous: false` (it was the default).
- Replaced the empty `Item` (with its commented-out Razer block) with `Item { MainBar {}; LeftPanel {}; RightPanel {} }`.
- The laptop-detection `Process` stays — `GlobalStates.isLaptop` is read elsewhere.

- [ ] **Step 3: Relaunch and confirm all three windows mount**

Run: `qs -p /home/davidas/.config/quickshell shell.qml`

Expected: shell starts cleanly; a 48-px bar appears along the bottom of every connected monitor; side panels are not yet visible (closed by default). No QML warnings in stderr.

Leave the shell running for Task 7.

---

## Task 7: End-to-end manual verification

**Files:** none (runtime-only checks)

- [ ] **Step 1: Bottom bar sanity**

With `qs` still running from Task 6:

- Visually confirm the bottom bar is present on every monitor.
- Confirm the text "Main Bar" is centered.
- Resize / move a Niri window so it fills the screen; verify it tiles above the bar (exclusive zone working).

- [ ] **Step 2: Focused-mode auto-hide**

If a `Preferences.focusedMode` toggle is wired in the app, exercise it. Otherwise, edit the pref file manually to flip the flag:

Run: `jq '.focusedMode = true' ~/.cache/quickshell_preferences.json > /tmp/qs-pref.json && mv /tmp/qs-pref.json ~/.cache/quickshell_preferences.json`

Expected: on next `qs` restart (or live if the shell watches the file) the `MainBar` is hidden and its exclusive zone is released — a full-screen Niri window covers the whole monitor.

Restore with: `jq '.focusedMode = false' ~/.cache/quickshell_preferences.json > /tmp/qs-pref.json && mv /tmp/qs-pref.json ~/.cache/quickshell_preferences.json`

- [ ] **Step 3: Left panel IPC**

Run: `qs ipc call leftpanel toggle`
Expected: panel slides in from the left over ~400 ms and comes to rest at the left edge, showing "Left Panel" centered on a `Colors.surface` rectangle. Niri windows behind it are unaffected (no exclusive zone).

Run: `qs ipc call leftpanel toggle`
Expected: panel slides back out to the left; after the animation completes the window is destroyed (no `quickshell:leftpanel` Wayland surface remains).

Run: `qs ipc call leftpanel open` followed by `qs ipc call leftpanel close`
Expected: same visual behavior, idempotent — repeated `open` or `close` calls do nothing on the second call.

- [ ] **Step 4: Left panel escape dismissal**

With the left panel open (`qs ipc call leftpanel open`), press `Esc` while hovering the panel to give it focus.

Expected: panel slides out. `GlobalStates.leftPanelOpen` is now `false`.

- [ ] **Step 5: Right panel IPC and escape dismissal**

Repeat Steps 3–4 with `rightpanel` (slides from the right, closes on `Esc`).

- [ ] **Step 6: Multi-monitor (if applicable)**

If a second monitor is attached:
- Confirm `MainBar` renders on both monitors.
- Confirm `qs ipc call leftpanel toggle` opens a left panel on each monitor (one `Variants` instance per screen).

Skip if only one monitor is attached; note in the PR description that this path is untested.

- [ ] **Step 7: Stop the shell**

`Ctrl-C` in the `qs` terminal.

- [ ] **Step 8: Commit (optional — user preference)**

Per the project's feedback memory, do **not** run `git commit` automatically. Summarize the set of changes for the user and let them decide:

```
Changed files:
  modified:   common/GlobalStates.qml
  modified:   common/Theme.qml
  modified:   shell.qml
  new file:   modules/MainBar.qml
  new file:   modules/LeftPanel.qml
  new file:   modules/RightPanel.qml
```

Tell the user: "All verification steps passed; ready to commit when you are."

---

## Notes for the executor

- **No test harness:** this codebase has no Jest / pytest / QML test runner wired up. Every "verify" step is a manual `qs` launch + visual/IPC check. If a step fails, fix inline and re-run before moving on.
- **Quickshell API version drift:** if `WlrLayershell.layer` / `WlrLayershell.namespace` fail to resolve, the installed quickshell may expose these under a different attached type. Cross-check with `qs --version` and the installed `quickshell-wayland` QML module; the property names in the legacy reference (`docs/legacy-ui-reference.md`) were the last-known-working set for this repo.
- **Preferences.focusedMode:** the `MainBar` binds to this flag. If there's no UI to toggle it and you can't edit the cache file, verification Step 2 can be deferred without blocking the rest of the plan — the binding itself is correct.
- **Commits are manual:** the `feedback_no_autocommits.md` memory is explicit. Do not invoke `git add` / `git commit` unless the user asks in-session.
