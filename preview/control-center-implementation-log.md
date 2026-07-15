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

## Phase 7 — Display pane

### What landed

- `modules/controlcenter/panes/DisplayPane.qml` — replaces the placeholder. BUILT-IN SCREEN (Brightness slider) / COLOR (Appearance) groups.
- `modules/controlcenter/atoms/AppearancePreview.qml` — **new atom.** A selectable macOS-style "Appearance" thumbnail: renders a stylized mini-shell (top bar with pills + a floating window with header hairline & content-line bars) in a **fixed** light or dark palette, with an accent selection ring + check badge and a label underneath. Emits `clicked()`.
- `modules/ControlCenter.qml` — `displayPaneComp` swapped from `PlaceholderPane` to `DisplayPane`.

> **Appearance control redesign (user request).** The first cut used a text `Light | Dark` segmented control (new `SegmentedControl.qml` + `SegmentedRow.qml` atoms). The user then asked for the macOS System Settings treatment: "two buttons that are miniature previews of the desktop ui shell." Replaced the segmented row with two `AppearancePreview` cards (Light + Dark) sitting standalone under the COLOR label. **The two segmented atoms were deleted** (orphaned — nothing else used them). If Phase 8 Battery wants the power-profile segmented control from the mockup, restore them from this session's history or rebuild (they were small + reviewed).

### Scope decision (user)

Asked the user how to handle the mockup's unwired controls. **Chose "only wired controls":** drop Scale, Resolution, Auto-brightness, Night Light, and Accent-from-wallpaper entirely (no backing service — `SystemNiri` only tracks workspaces, not output modes; no night-light/wlsunset wrapper; no accent Preference). Pane ships with just the two controls that have real services. This diverges from the "render-everything-and-stub" convention used in earlier panes, by explicit request.

### Wiring

- **Brightness** → `Brightness.brightness / 100` slider, `Brightness.setBrightness(round(v*100))`, `available: Brightness.available` (false on desktops → self-dims). Dynamic `brightness_low/medium/high` icon by level (matches `rightpanel/BrightnessSection.qml`).
- **Appearance** → two `AppearancePreview` cards wrapped in a `GroupBox` (full-width lighter container, matching the BUILT-IN SCREEN group), centered as a pair via flexible end-spacers + 28px gap; padding 30px top / 16px bottom (extra top to offset the labels that sit *below* the thumbnails). Light card `selected: !darkMode`, Dark card `selected: darkMode`; `onClicked: if (!selected) GlobalStates.toggleDarkMode()`. "Auto" omitted (no scheduler).

### Non-obvious bits

- **`AppearancePreview.pal` hardcodes the light/dark hex values** (mirrors `common/Colors.qml`). It MUST be a literal, not a binding to `Colors.*`, because both palettes render **simultaneously** — `Colors.*` only reflects the current mode. If the palette is retuned in `Colors.qml`, update this literal too.
- **Badge/ring use the card's own `pal`, not `Colors.barAccent`/`panelBg`.** The selected card's palette always equals the current mode (Light card selected ⟺ light mode), so the mode-dependent `Colors.*` happened to align — but keying the check badge off `root.pal.accent`/`root.pal.bg` makes it contrast against *its own* thumbnail unconditionally, decoupled from that invariant. The selection **ring** is left on `Colors.barAccent` (matches the CC's selection-accent convention; equal to `pal.accent` in every visible-selected state anyway).
- **Sizing: root `implicitWidth/Height` ← inner `ColumnLayout` (`col`), which is `anchors.centerIn: parent`.** The host `RowLayout` reads the implicit sizes directly to allocate space, so there's no zero-size/circular hazard despite `col` being anchor-centered rather than Layout-placed (verified; same shape as other atoms). The 138×86 thumb drives the width.
- **Mini-shell is absolute-positioned pixel art** (bar pills, window header hairline, content-line bars at literal x/y). Intentional — do not tokenize or convert to a Layout.

### Phase 7 review pass (simplifier + reviewer)

Two passes (segmented-control draft, then the AppearancePreview redesign):

- **Segmented draft** (atoms since deleted): reviewer caught an `anchors.fill`→`implicitWidth:0` zero-width collapse and a compounded `0.45 × 0.45` opacity double-dim. Both fixed before the redesign superseded the atoms.
- **AppearancePreview**: simplifier hoisted `animMs` and unified the two cards' click guards to `if (!selected)`. Reviewer verified the implicit-size chain, `MaterialSymbol` API (`icon`/`iconSize`/`fontColor`), `Qt.lighter/darker` on hex-string colors (valid in Qt6), MouseArea capture, and idempotent toggle — the one applied fix was switching the check badge to the card's own `pal` (above).

### Known leftovers / non-goals for Phase 7

- Scale / Resolution would need a niri-IPC service (`niri msg output <name> scale|mode`) + mode enumeration. Deferred.
- Night Light still pending a `wlsunset` wrapper (shared with the stubbed Quick Settings tile).
- Auto-brightness needs an ambient-light-sensor source; none exists.

## Phase 6 — Sound pane

### What landed

- `modules/controlcenter/panes/SoundPane.qml` — replaces the placeholder. OUTPUT (device picker + volume + mute) / INPUT (device picker + input level) / PER-APP VOLUME groups, matching the mockup's full layout.
- `modules/controlcenter/atoms/DevicePicker.qml` — **new atom.** Inline-expanding device selector.
- `modules/controlcenter/atoms/SliderRow.qml` — extended with opt-in `iconImage` (image icon w/ MaterialSymbol fallback), `sub` (two-line meta), `trackWidth`, `showSeparator`. OUTPUT/INPUT sliders use it unchanged; per-app rows use the new props.
- `services/SystemAudio.qml` — major extension: enumerates `outputDeviceOptions` / `inputDeviceOptions` / `playbackStreams`, mic accessors (`sourceVolume`/`sourceMuted`/`setSourceVolume`/`toggleSourceMuted`), default-device setters (`setDefaultSink`/`setDefaultSource` → `Pipewire.preferredDefaultAudioSink/Source`), `setStreamVolume`, label helpers.
- `modules/ControlCenter.qml` — `soundPaneComp` swapped from `PlaceholderPane` to `SoundPane`.

### Non-obvious bits

- **`onNodeAdded` / `onNodeRemoved` on `Pipewire` are C++ methods, not QML signals.** Connecting to them silently never fires. Node add/remove is observed via the `Pipewire.nodes` ObjectModel's `valuesChanged` instead. (Verified against `quickshell-service-pipewire.qmltypes`.)
- **Classify nodes on the constant `isStream`/`isSink` booleans, NOT `media.class`.** `properties`/`media.class` is *bound* data — empty for nodes that aren't currently tracked, which is a chicken-and-egg (classification decides what to track). Confirmed live: an untracked mic and an untracked Firefox playback stream both reported `media.class=(none)`. Also non-obvious: **a playback stream reports `isSink=true`.** So: output device = `!isStream && isSink`; input device = `!isStream && !isSink`; per-app playback stream = `isStream && isSink`. The first draft keyed inputs off `media.class === "Audio/Source"` and streams off `!isSink`, yielding `ins=0` and `streams=0` until this was found via debug instrumentation.
- **Device/stream lists are stable arrays rebuilt only on node changes** (`rebuild()` driven by `valuesChanged` + `readyChanged`), never binding-derived-per-read — the same anti-binding-storm pattern as `Network.friendlyWifiNetworks` (the Wi-Fi-toggle freeze lesson). Per-app sliders read live volume because every shown node is held by one `PwObjectTracker` bound to a single `trackedNodes` list.
- **DevicePicker expands inline, not as a floating popup.** `GroupBox` and the host `Flickable` are both `clip: true`, so a floating overlay would be clipped, and a separate Wayland popup surface would reintroduce the focus-grab / extra-click layer-shell issues from Phase 1. Inline expansion reflows the GroupBox/Flickable cleanly and needs no focus handling.
- **Per-app icon resolution is best-effort.** `streamIconName` tries `application.icon-name` → `application.process.binary` → `application.name` (lowercased), fed to `Quickshell.iconPath(name, "")`; misses fall back to a `graphic_eq` glyph (the user accepted this is fiddly).

### Phase 6 review pass (simplifier + reviewer)

Simplifier stripped the verbose rationale comments to one-liners (per user request), removed redundant section dividers, and centralised the picker-option construction.

Reviewer found 5 issues; applied 4, rejected 1:
- **CRITICAL — tracker thrash.** The `PwObjectTracker.objects` binding used `outputDevices.concat(inputDevices, playbackStreams)`; the three assignments in `rebuild()` each re-evaluated it. **Fixed:** tracker binds to a single `trackedNodes` array assigned once per rebuild.
- **IMPORTANT — picker churn on selection.** `deviceOptions(...)` rebuilt the option array on every default-device change, tearing down the whole Repeater for a checkmark change. **Fixed:** stable `{label,value}` option arrays + `currentValue` compared per-delegate, so selecting re-evaluates only the check icon.
- **IMPORTANT — separator slid during the expand/collapse animation** (anchored to the animating `parent.bottom`). **Fixed:** anchored to `header.bottom`.
- **MINOR — `setStreamVolume` lacked a `ready` guard.** **Fixed** for consistency with the setter family.
- **REJECTED — "timer tracker captures defaults statically."** The binding inside the dynamically-created tracker is live, and `trackedNodes` already holds the default sink/source (they're in the device lists), so their `audio` stays live. Pre-existing init Timer left untouched (it also gates `ready`).

### Known leftovers / non-goals for Phase 6

- **Mic mute toggle** — `toggleSourceMuted()` exists in the service but the INPUT group has no mute row yet (mockup doesn't show one). Easy add if wanted.
- **Per-app mute / per-app device routing** — sliders only; no mute button or move-to-sink per stream.
- **`safeVolumeChanged` dead signal** — long-standing follow-up, still untouched (out of scope; warrants a deliberate OSD-behavior decision).
- **Memoize per-app icon paths** — `Quickshell.iconPath` resolves per delegate binding; fine at current stream counts.

## Phase 5 — Bluetooth pane

### What landed

- `modules/controlcenter/panes/BluetoothPane.qml` — replaces the placeholder. **Zero new atoms** (DeviceRow / ToggleRow / Chip / GroupBox / GroupLabel all reused from Phase 4).
- `modules/ControlCenter.qml` — `bluetoothPaneComp` swapped from `PlaceholderPane` to `BluetoothPane`.

### Layout

- First group: Bluetooth toggle (ToggleRow, gated on `SystemBluetooth.available`) + read-only Discoverable row (`Bluetooth.defaultAdapter?.name`).
- **MY DEVICES** group (Loader-gated on `available && enabled`): repeater over `SystemBluetooth.friendlyDeviceList.filter(d => d?.paired)`. Each row shows the device-type icon (via `SystemBluetooth.bluetoothDeviceIconName(deviceType)`), name, type, and a chip — `Connected · 72%` (live, battery suffix when device exposes it) or `Not connected` (default). Click → connect if paired-but-not-connected, disconnect if connected.
- **NEARBY** group (same Loader): repeater over `SystemBluetooth.unpairedDevices`. Click → `pairDevice()`. Chevron present (signals "tap to pair"). Empty state offers a "Tap to scan" trigger.
- Auto-discovery: `Component.onCompleted` calls `startDiscovering()` (when BT enabled); `onDestruction` calls `stopDiscovering()`. The service has a 20-second auto-stop timer as a safety net.

### Reused patterns (Phase 4 carry-overs)

- **Loader-gated lists** on `SystemBluetooth.enabled` — atomic teardown when BT toggles off, avoiding the binding-storm class of bug that previously froze the shell during Wi-Fi toggle.
- **Repeater.count for separator** instead of materializing the source list's `.length` per delegate.
- **Defensive `modelData?` access** everywhere.
- **`available: false` stubbing** on ToggleRow when no adapter is present.

### Non-obvious bits

- **Battery suffix is opportunistic.** `device.battery` is set by BlueZ only for devices that expose battery via HID++/HFP-AG/etc. — many keyboards and older mice don't. `batteryText()` guards on `typeof b === "number" && 0 ≤ b ≤ 100`; absent battery yields just `Connected` with no suffix.
- **`deviceType` is a string in Quickshell.Bluetooth's wrapper.** The helper `bluetoothDeviceIconName` expects a string with substrings like `"audio"`, `"keyboard"`. We coerce defensively via `String(... ?? "")`.
- **`SystemBluetooth.connectedDevices` / `pairedButNotConnectedDevices` / `unpairedDevices` / `friendlyDeviceList` are binding-derived** (`Bluetooth.devices.values.filter(...).sort(...)`) — same N² rebuild concern flagged for `Network.friendlyWifiNetworks`. Not memoized here yet. If scan-time churn becomes a problem, mirror the Phase-4b memoization pattern in `SystemBluetooth.qml`. Logged as follow-up.

### Phase 5 review pass

Simplifier inlined `adapterName` (single-use), folded `batteryText` into `connectedChip`, dropped a redundant `showChevron: false` default. No structural changes.

Reviewer found two actionable items:
- **`stopDiscovering()` called without guard on destruction.** When BT is disabled, the destruction path was still telling the adapter to stop discovering — a spurious D-Bus call to a disabled adapter. **Fixed:** mirrored the `onCompleted` guard (`if (available && enabled)`).
- **Misleading empty-state copy.** When MY DEVICES is empty and NEARBY is also empty, the "Pair one from the list below" hint pointed at a list that itself says "No nearby devices". **Fixed:** the MY DEVICES empty row now reads "Scan for nearby devices" when NEARBY is also empty, and only says "Pair one from the list below" when NEARBY has items.

### Known leftovers / non-goals for Phase 5

- **"Discoverable as" rename** — read-only for now. Quickshell.Bluetooth's Adapter likely exposes a settable `alias`; the row would become a chevron-tap → inline rename. Phase 5b.
- **Forget / unpair** — no UI. The service has `unpairDevice()`; a chevron-tap → context popup would land it.
- **PIN-required pairing** — `pairDevice()` triggers BlueZ's agent; PIN entry happens through the system agent, not the CC. PIN-less devices (most accessories) pair automatically.
- **Memoize `friendlyDeviceList`** — analogous to the Phase-4b friendlyWifiNetworks memoization. Defer until scan churn is observed.

## Phase 4 — Network pane

### What landed

- **Atoms** (4 new):
  - `SettingsSwitch.qml` — 32×18 pill toggle with animated thumb. `available: bool` for stubbing.
  - `Chip.qml` — small-caps status chip; `variant` selects color/dot (`default` / `live` / `warn` / `err`).
  - `ToggleRow.qml` — grouped-list row: label + `SettingsSwitch`.
  - `DeviceRow.qml` — workhorse grouped-list row. Icon-cell + name/meta stack + optional `secure` lock icon + optional `trailingText` + optional `Chip` + optional `chevron`. Has `showSeparator: bool` for hairline-between-rows. Click handler is gated by `clickable: bool`.
- `panes/NetworkPane.qml` replacing the placeholder. Composes CURRENT / OTHER NETWORKS / ETHERNET groups using the new atoms.
- `modules/ControlCenter.qml` — `networkPaneComp` swapped from `PlaceholderPane` to `NetworkPane`.

### Wiring

| Section | Behavior |
| --- | --- |
| CURRENT row | name = `Network.active?.ssid` or "Not connected" / "Wi-Fi off". meta = `${security} · ${strength}%`. chip = "Connected" (live) or "Connecting" (default). |
| Wi-Fi toggle | `checked: Network.wifiEnabled` / `onToggled: Network.toggleWifi()` |
| Other networks list | `Repeater { model: Network.friendlyWifiNetworks.filter(n => !n.active) }`. Each row clickable; click → `Network.connectToWifiNetwork(ap)` only if known or open. Secure-unknown APs intentionally no-op (Phase 4b adds the password prompt inline). |
| Empty / scanning state | When the list is empty, a single DeviceRow shows "Scanning…" or "No networks found · Pull to refresh" (click → `Network.rescanWifi()`). |
| Ethernet row | name = `Network.ethernetDevice`. meta = `Connected · ${speed}` or "Cable not connected". chip = "Connected" (live) or "Idle" (default). |

### Non-obvious bits

- **Row separators live on the row, not the GroupBox.** Each `DeviceRow` / `ToggleRow` has a bottom hairline that's `visible: root.showSeparator`. Consumer sets `false` on the last row in a group. `GroupBox` has 0 spacing between children so separators line up with content. The mockup's `:last-child { border-bottom: 0 }` pattern translated to QML.
- **Repeater's last-row gate is computed at the delegate.** `showSeparator: index < root.otherWifiNetworks.length - 1` inside the delegate.
- **The "trailing slot" pattern was deliberately not used.** Considered `default property alias trailing: ...` on DeviceRow but in QML the default-alias swallows ALL inline children (including the row's own background + content layout). Switched to explicit named properties on DeviceRow (`chipText`, `chipVariant`, `trailingText`, `showChevron`, `secure`) — covers every mockup pattern at the cost of "open extension"; OK at current pane count.
- **Secure-unknown click is a deliberate no-op.** Mirrors the design-doc decision to defer password-prompt UI until a dedicated phase. NetworkOverlay still handles password entry for now; CC's Network pane can punt to NetworkOverlay later or grow its own inline prompt.

### Known leftovers / non-goals for Phase 4

- **Password prompt for secure unknown APs** — Phase 4b. Need `WifiPasswordEntry`-style inline modal or a popup atom.
- **"Other…" (hidden SSID) row** — needs `Network.connectToHiddenNetwork()` extension (Spec 0 follow-up).
- **Current AP additional details** (IP, frequency, dBm) — `WifiAccessPoint` doesn't expose these directly; would need to extend `Network.qml` to query `nmcli -t -f IP4.ADDRESS device show <device>`.
- **Forget from row** — currently no forget UI; would be a chevron-tap → details popup. Disconnect now works (click the active row).

### Phase 4 review pass (post-simplifier)

Simplifier collapsed the atoms: `SettingsSwitch` got `thumbSize`/`thumbInset` extracted + `radius: height / 2`; `Chip`'s color tables switched to `switch` statements + `dotColor` default → real color (`Colors.inkFaint`, gated invisible by `hasDot`); `ToggleRow` lost the empty spacer Item; `DeviceRow` collapsed root Item + background Rectangle into one Rectangle and adopted the `animMs` token. NetworkPane untouched by the simplifier.

Reviewer found 5 issues. Applied 3 inline; deferred 2 that need `Network.qml` changes (would affect NetworkOverlay too).

**Applied:**
- **`apMeta` open-AP label bug** — open networks with signal showed `"65%"` instead of `"Open"`. The `|| "Open"` fallback only fired when both `security` and `strength` were absent. Fixed by explicitly pushing `"Open"` when `security` is empty.
- **Separator sort-thrash** — `showSeparator: index < Network.friendlyWifiNetworks.length - 1` re-materialized the sort+spread for every delegate on every model change. Switched to `index < networksRepeater.count - 1` — reads a cached integer off the Repeater QObject, no array access. Added `id: networksRepeater`.
- **Secure-unknown silent-click** — row showed hover/press feedback then no-op'd, misleading. Made `clickable` conditional: `apRow.isActive || apRow.isKnown || apRow.isOpen`. Secure-unknown rows now render without pointer cursor or hover tint, signaling clearly that they're not actionable. Phase 4b lights them up via password prompt.

**Deferred follow-ups (need broader decision; touch `services/Network.qml`):**

1. **`disconnectWifiNetwork` uses SSID as connection-profile name** (`nmcli connection down <ssid>`). When the saved profile's name differs from the SSID (renamed by user, or auto-named by NetworkManager), the command silently fails. NetworkOverlay's disconnect path has the same bug. Fix: use `nmcli device disconnect <interface>` or `nmcli connection down id <ssid>`. Out of Phase 4 scope since it changes shared service behavior — Phase 4b or a separate Network.qml hardening pass.
2. **`Network.friendlyWifiNetworks` recomputes `[...wifiNetworks].sort(...)` on every read** — **Fixed.** Converted from `readonly property list<var> ... = [...].sort(...)` (binding-derived, fresh array per read) to a regular `property list<var> friendlyWifiNetworks: []` with a `_rebuildFriendlyWifiNetworks()` helper. The helper runs **once** at the end of `getNetworks.onStreamFinished` — after the in-place `wifiNetworks` splice/push pass completes. The array is now stable between scans; consumers (NetworkPane's Repeater, NetworkOverlay's WifiSection) only re-evaluate when the property assignment happens, not on every read. Eliminates the ~N² delegate rebuild during scans.

### Bug fix — shell freeze on Wi-Fi toggle off

**Reproduced:** toggling Wi-Fi off from the Network pane froze the entire shell.

**Cause:** the first draft had `readonly property var otherWifiNetworks: Network.friendlyWifiNetworks.filter(n => !n.active)`. `friendlyWifiNetworks` itself returns a new array on every read (`[...wifiNetworks].sort(...)`), and the extra `.filter()` layered on top returned yet another new array. During the toggle, `wifiNetworks` mutates rapidly (nmcli teardown), and the Repeater watching `otherWifiNetworks` got a fresh model on every binding evaluation while accessing stale `modelData` references from delegates being torn down — binding storm + null-property-access combo, hard freeze.

**Fix applied:**
1. Dropped the `otherWifiNetworks` derived property entirely. The Repeater now binds `model: Network.friendlyWifiNetworks` directly — same array reference per service-side change.
2. Wrapped the NETWORKS list (group label + group box) in a `Loader` gated on `Network.wifiEnabled`. When Wi-Fi flips off, the Loader unloads atomically; all delegates destroyed cleanly before the wifiNetworks-empties cascade.
3. The active AP now appears in the list (sorted first by `friendlyWifiNetworks`'s comparator) instead of being separated into a CURRENT group. Click the active row → disconnect. Renames the section from "OTHER NETWORKS" to "NETWORKS" since active is included.
4. The first row of the WI-FI group is a read-only summary (active AP + chip + meta). The Wi-Fi toggle is the second row.
5. Defensive null guards everywhere: `modelData?.ssid`, `typeof ap.strength === "number"`, etc.

This mirrors NetworkOverlay's safer pattern (also uses `Network.friendlyWifiNetworks` directly, no extra filter).

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
