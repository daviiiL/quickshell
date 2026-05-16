# Control Center — Implementation Log

Running notebook of decisions, gotchas, and notable bits during implementation.
Companion to `preview/control-center.md` (design) and `preview/control-center.html` (visual mockup).

## Phase 1 — Window scaffold + IPC + bar button

### What landed
- `common/GlobalStates.qml` — `controlCenterOpen`, `controlCenterSource`, `controlCenterPane`.
- `modules/ControlCenter.qml` — centered 880×600 modal on `WlrLayer.Overlay`, full-screen dim backdrop, fade + scale (0.97 → 1) animation. Renders only on the focused niri output. IPC: `toggle / open / close / openPane`.
- `assets/icons/{gray100,gray900}/tune.svg` — sliders glyph, follows the existing `stroke=#e3e3e3` / `stroke=#1c1820` convention.
- `services/Icons.qml` — `Icons.tune`.
- `modules/mainbar/ControlCenterButton.qml` — icon + "Control Center" label; toggles CC; reuses `MainBarButton`.
- `modules/MainBar.qml` — button inserted as the leftmost item of the right group (left of the network section).
- `shell.qml` — instantiated `ControlCenter {}` inside the `Preferences.isLoaded` loader.

### Debug-logging convention (active through all phases)

Every major component logs its lifecycle to the console so we can see spawn/kill ordering across the Wayland surface, the Loader, and the per-pane subcomponents that come in later phases.

Format: `[ControlCenter.<thing>] <event>` — e.g. `[ControlCenter.window on DP-1] spawned`, `[ControlCenter.content] loaded`, `[ControlCenter.SoundPane] killed`.

These are intentionally **unordered indicators**: lifecycle callbacks fire on multiple objects and Qt doesn't guarantee strict ordering between them. The point is to see which ran, not in what sequence.

When Phase 2+ adds panes / atoms, give each new file a matching pair:
```qml
Component.onCompleted: console.log("[ControlCenter.<Name>] loaded")
Component.onDestruction: console.log("[ControlCenter.<Name>] unloaded")
```

**Remove all `console.log` lines tagged `[ControlCenter.*]` when all phases are done.** Easy to find with a single grep.

### Memory: content is lazy-loaded

The surface's content (currently the Phase 1 placeholder Column; in Phase 2 the sidebar/header/panes tree) lives inside a `Loader` gated by `active: panel.shouldShow || surface.opacity > 0`. When CC is closed AND the closing animation has fully finished, the Loader unloads its content — so pane components and their bindings (e.g. future Sound pane's per-app volume Repeater over PipeWire nodes) won't sit in memory while CC is hidden. The outer `surface` Rectangle and its `Behavior`s stay alive so the open/close animation works.

Note: Quickshell services (`services/*.qml` singletons) are independent of this — they're alive for the whole shell lifetime. The Loader only frees the pane *consumers*, not the services themselves.

### Non-obvious bits worth knowing later

- **Single focus-grab path.** Earlier draft had `focus: panel.shouldShow` + `onFocusChanged: forceActiveFocus()` + `onShouldShowChanged: forceActiveFocus()` racing each other and produced `RangeError: Maximum call stack size exceeded` on every toggle. Only `onShouldShowChanged` now grabs focus. If Esc ever stops working after a future refactor, that's the place to look.
- **Empty `MouseArea` inside `surface` is intentional.** It consumes mouse presses so they don't reach the backdrop's MouseArea (which closes the CC). Looks deletable; isn't.
- **`visible` is bound directly to `shouldShow`.** No "keep alive during close animation" pattern. The CC's layer surface is on `WlrLayer.Overlay` — even when fully transparent, a layer-shell surface still **intercepts mouse clicks at the compositor level** and they do NOT pass through to lower layers (bar, etc.). An earlier draft kept the surface alive for ~320ms during the close fade and produced an "extra click" bug: after closing CC, every other bar button needed one extra click because the first click was caught by the invisible-but-still-alive CC backdrop. Snap-close is the working pattern. To restore the close animation later, the fix is `PanelWindow.mask` (set the input region to empty during close so clicks pass through). Not done in Phase 1 — needs API spike.
- **Focused-screen fallback.** `SystemNiri.focusedOutput === ""` (niri hasn't reported yet) is treated as "show on all screens" so a cold-boot toggle still shows something.

### Known leftovers for next phase

- Surface still contains the Phase 1 placeholder text. Replaced by the real content in Phase 2.
- No header (breadcrumb / search / close button) yet.
- Spec 0 (new services) not started.

### Review pass (post-simplifier)

Simplifier reduced duplication: moved `open/close` state writes into helpers, replaced literal `radius: 6` with `Theme.ui.radius.sm` (= 4) and `border.width: 1` with `Theme.ui.mainBarHairWidth`, deduped a `highlighted` derived prop on the bar button. **Worth flagging: corner radius changed from 6px → 4px during simplification.** If the slightly larger radius was intentional design intent for the modal vs. cards, revert that single line.

Code review surfaced 4 issues. Resolutions:

1. **`WlrKeyboardFocus.Exclusive` was set on every screen instance** (conf 95 — critical). When `SystemNiri.focusedOutput === ""` (cold start, monitor unplug), every per-screen panel would request exclusive keyboard at once. **Fixed:** `keyboardFocus` is now bound to `panel.shouldShow`, so only the visible instance grabs.
2. **Bar button bypassed `closeControlCenter` / `openControlCenter`** (conf 82). Not a bug today but a hazard once Phase 2 helpers grow (pane reset, scroll reset). **Fixed:** the two helpers were moved to `GlobalStates.qml` (since the `ControlCenter` `Scope` id isn't reachable from other files). Bar button + IPC + backdrop + Esc all funnel through `GlobalStates.openControlCenter(source)` / `GlobalStates.closeControlCenter()`.
3. **Multi-monitor: focusedOutput change *while CC is open*** causes both old and new panel surfaces to briefly request exclusive keyboard during the transition (conf 80). **Deferred.** Needs a design call — latch the opening screen vs. follow focus. Not a blocker; revisit in Phase 2 once the panes are in.
4. **`controlCenterPane` not reset on close** — flagged as a bug. **Not a bug — intentional.** Sticky pane state across opens is the design (macOS Settings behavior); also planned to persist via `Preferences.controlCenterPane` in Spec 0.

## Phase 2+3 cleanup pass (simplifier + reviewer)

### Simplifier-driven

- Unified `hot` (mouseArea.containsMouse) + `animMs` (Theme.anim.durations.xs * 0.6 ≈ 120ms) derived props across `SidebarItem`, `SessionButton`, `CloseButton`, `QuickTile`, `SliderRow` (the linter / user kept these intact). Removes ~12 repeated `mouseArea.containsMouse` expressions.
- `SessionPane.qml` extracted `closeAndRun(cmd)` and `closeAndLock()` — each `SessionButton.onActivated` is now a single line.
- `ControlCenter.qml` pulled the repeated `paneEntry(GlobalStates.controlCenterPane)` into a single derived `activePane` (was being computed three times for Header.section, Header.label, Loader.sourceComponent).
- `SystemAudio.muted` corrected from `property real` to `property bool`.
- `SliderRow` renamed `_progress`/`_commit` → `progress`/`commit` (no leading-underscore convention used elsewhere in this codebase).

### Review-driven

1. **CRITICAL: `GroupBox` used `Column` instead of `ColumnLayout`.** `Column` does NOT honor `Layout.fillWidth` on children, so `SliderRow.Layout.fillWidth: true` was silently ignored — both sliders rendered at width 0. **Fixed.** GroupBox now uses `ColumnLayout` anchored left/right/top, `spacing: 0`. SliderRow's `Layout.fillWidth` now resolves correctly. Brightness + Volume sliders are restored to full width.
2. **IMPORTANT: `SessionPane.closeAndRun` lacked a re-entry guard.** A fast double-click (or repeated IPC call) could re-fire a destructive command while the previous spawn was still in flight. **Fixed.** First line of `closeAndRun` is now `if (sessionProc.running) return;`.
3. **IMPORTANT: `SystemAudio.safeVolumeChanged` is a dead signal.** No listener anywhere in the codebase; `OsdController` uses the property-change notification (`onVolumeChanged`) for OSD popups, which fires for both user-driven and external (PipeWire-side) volume changes. The signal was probably *intended* to gate the OSD to user-driven changes only, but that wiring was never completed. **Partially addressed:** `setVolume()` no longer emits it (matches `toggleMuted`'s no-emit behavior). The signal declaration + the two emit sites in the `volume` IpcHandler remain — full cleanup is out of scope here and warrants a deliberate decision on OSD behavior. Add to follow-ups.

### User-feedback fixes

- **QuickTile cards were too tight; the sub text was tiny and pressed against the bottom edge.**
  - Tile height: 78 → 92 (+14)
  - Bottom padding: 12 → 18 (+6)
  - Column spacing: 6 → 8
  - Sub text font: 9 → 11
  - Sub text letter-spacing: 0.2 → 0.3
  - On-state accent bar bottom margin: 8 → 10 (sits a little higher to make room for the larger sub text)

### Follow-ups (carry into a later pass)

- `SystemAudio.safeVolumeChanged`: decide intent (OSD-on-user-only vs. OSD-on-any-change), then either wire `OsdController` to it or remove the signal + the two remaining emit sites.

### Second surgical review — Process lifecycle on suspend/hibernate

Reviewer flagged: `Process { id: sessionProc }` lived inside `SessionPane`, which gets unloaded by the Loader within milliseconds of `closeControlCenter()`. `systemctl suspend` (and `hibernate`) **block** until the system wakes — so destroying the QML `Process` mid-blocking-call can SIGKILL `systemctl` before systemd-logind completes the suspend handshake → silent suspend failure.

**Fixed** by introducing `services/SessionActions.qml` — a singleton owning the `Process` for the shell's lifetime. SessionPane now calls `SessionActions.lock()`, `SessionActions.suspend()`, etc. through a single `closeAnd(action)` helper (closes CC then invokes the action). The re-entry guard moved into `SessionActions.run()` (still `if (_proc.running) return;`).

Bonus: SessionActions is now a clean reusable surface — any future module (a session keybind handler, a bar context menu) can fire the same actions without re-implementing the spawn logic.

## Phase 3 — Quick Settings pane

### What landed

- **Atoms** (4 new): `QuickTile.qml` (the 4×2 tile with hover/on states + on-state accent bar + `available` for stubbing), `SliderRow.qml` (icon-cell + label + drag-slider + value %), `GroupBox.qml` (rounded grouped container with hairline border + clipped Column for rows), `GroupLabel.qml` (small-caps section header).
- `panes/QuickPane.qml` replacing the placeholder. 4×2 tile grid + Brightness GroupBox + Volume GroupBox. Wrapped in a `Flickable` so content overflows safely as more rows are added later.
- `services/SystemAudio.qml` — added `setVolume(v)` and `toggleMuted()` setters so panes don't have to reach into `Pipewire.defaultAudioSink.audio` directly.
- `modules/ControlCenter.qml` — `quickPaneComp` swapped from `PlaceholderPane` to `QuickPane`.

### Tile wiring

| Tile | Backed by | Notes |
| --- | --- | --- |
| Wi-Fi | `Network.wifiEnabled` + `Network.active.ssid` | sub = SSID when connected, "Disconnected" / "Off" otherwise |
| Bluetooth | `SystemBluetooth.enabled` + `connectedDevices.length` | `available: SystemBluetooth.available` so adapter-less machines self-stub |
| **Airplane** | — | stubbed (`available: false`) until `services/Rfkill.qml` lands |
| Do Not Disturb | `Notifications.silent` | direct toggle |
| Dark Mode | `GlobalStates.darkMode` | uses existing `toggleDarkMode()` |
| **Night Light** | — | stubbed (`available: false`) until a `wlsunset` wrapper lands |
| Focused | `Preferences.focusedMode` | uses existing `toggleFocusMode()`; "Bar hidden" / "Off" sub |
| Lock | `GlobalStates.screenLocked` | closes CC first, then locks |

### Slider wiring

| Slider | Source | Setter | `available` |
| --- | --- | --- | --- |
| Brightness | `Brightness.brightness / 100` | `Brightness.setBrightness(round(v*100))` | `Brightness.available` (false on desktops) |
| Speakers | `SystemAudio.volume` | `SystemAudio.setVolume(v)` (new) | `SystemAudio.ready` |

Microphone slider deferred to Phase 4+ when `SystemAudio` is extended to enumerate sources.

### Non-obvious bits

- **`available: false` is the universal "stub" affordance.** Sets opacity 0.45 and disables hover + click handler. Tile and SliderRow both honor it. New stub tiles/rows just set this flag — no other code change needed.
- **Tile `on` is decoupled from the backing service's "enabled" state where it makes sense.** Wi-Fi tile is "on" only when both `wifiEnabled` and `Network.active` (i.e. actually connected). Bluetooth tile is "on" iff `enabled`. Lock has no on-state (it's a fire-and-forget action).
- **QuickPane uses Flickable.** Phase 3's content fits comfortably in 600px of pane height, but Phase 4+ (mic slider, per-app volume, etc.) will overflow — Flickable now means no layout churn later.
- **GroupBox uses `clip: true` + a Column with `default property alias`.** Consumer just adds row Items directly inside. If a group needs hairline separators between rows (Sound, Network, etc.), the consumer inserts `Rectangle { height: 1; color: Colors.hair }` explicitly. Considered (and rejected) auto-injecting separators via post-mount inspection — too brittle for a marginal ergonomic win.

### Known leftovers / non-goals for Phase 3

- Mic slider not present (needs `SystemAudio` source enumeration — Spec 0 follow-up).
- Airplane mode and Night Light tiles are stubbed; flipping them on requires net-new services.
- No "Auto" appearance scheduling (sunrise/sunset) — Dark Mode is plain on/off.
- `Notifications.silent` toggle: setting it back to `false` makes notifications appear again, but the popup-inhibit logic also reads `GlobalStates.rightPanelOpen || appLauncherOpen`. We're piggybacking on the existing semantics.

## Phase 2 — Header + Sidebar + pane registry + Session pane

### What landed

- `modules/controlcenter/Sidebar.qml` — 224px sidebar. User chip (initial avatar + name from `$USER` + host label), section headers (`QUICK` / `SYSTEM` / `SESSION`), 7 items driven by the registry. Emits `paneSelected(name)`.
- `modules/controlcenter/Header.qml` — 44px header. Breadcrumb (section · label), search input (cosmetic only — no behavior), `CloseButton`. Emits `closeRequested()`.
- `modules/controlcenter/atoms/SidebarItem.qml`, `SessionButton.qml`, `CloseButton.qml` — small atoms with hover/active states.
- `modules/controlcenter/panes/PlaceholderPane.qml` — shared stub used by the 6 panes not yet built. Takes a `paneName` prop for the label.
- `modules/controlcenter/panes/SessionPane.qml` — fully functional. Lock (sets `GlobalStates.screenLocked`), Suspend (`systemctl suspend`), Log Out (`niri msg action quit`), Restart (`systemctl reboot`), Shut Down (`systemctl poweroff`), Hibernate (`systemctl hibernate`). All actions close CC first via `GlobalStates.closeControlCenter()` then dispatch the system command. Restart and Shut Down are flagged `danger: true` (hover state turns the icon/label red).
- `modules/ControlCenter.qml` — replaced the Phase 1 placeholder Column with a `ColumnLayout` of `Header` + `RowLayout(Sidebar + paneLoader)`. The pane registry lives inline at the `Scope` root as a `readonly property var paneRegistry` plus seven inline `Component { ... }` definitions. A `paneEntry(name)` function looks up by name. The pane area is a `Loader` whose `sourceComponent` is bound to the current entry's component — switching panes destroys the old item and instantiates the new (each pane's lifecycle log fires accordingly).
- `Loader { active: panel.shouldShow }` (changed from `active: panel.shouldShow || surface.opacity > 0`). With snap-close, content unloads instantly on close — keeping it alive for an animation that doesn't visually run was just wasted memory.

### Lifecycle logs added (per convention)

Each major component logs its load/unload. Expected ordering on open (approximate; not guaranteed): window spawned → content loaded → header loaded → sidebar loaded → current pane loaded. On close: reverse. When switching panes: old pane unloaded → new pane loaded.

### Known leftovers / non-goals for Phase 2

- "Confirm before destructive" Preference not yet added — Restart / Shut Down currently fire immediately. Phase 3+ adds the Preference + confirmation popup.
- "Auto-suspend delay after lock" row not implemented (deferred service).
- Search input has no behavior. Phase planned scope: filter the sidebar items.
- Sidebar item `meta` text is currently empty for every entry. Phase 3+: bind to `Network.active?.ssid`, `Notifications.silent`, `Brightness.brightness`, etc.
- User host label is hardcoded `niri · arch`. Could derive from `Quickshell.env("HOSTNAME")` later.

### Non-obvious bits

- **Pane components are instantiated once and reused across opens.** The seven `Component { ... }` blocks at the `Scope` root are factory definitions; the actual pane Item is created each time the inner `Loader.sourceComponent` is set to one. So switching from Session → Network destroys the Session pane and creates a fresh Network pane. State is not preserved across pane switches (intentional — keeps memory tight; matches what the modularity contracts called for).
- **Sidebar section headers are computed positionally**, not stored explicitly. The `isFirstInSection` derived property checks whether the previous entry in the registry has a different `section` value. Reordering the registry rearranges sections automatically; no separate section-list to keep in sync.
