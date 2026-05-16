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

## Phase 2 — (placeholder for next pass)
