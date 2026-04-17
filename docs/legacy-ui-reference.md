# Legacy UI Reference

Snapshot of the UI layer as it existed on branch `niri-base` before the `components/` and `modules/` trees were deleted. Kept for reference when rebuilding UI on top of the bare shell. The surviving layers (`common/`, `services/`, `widgets/`, `scripts/`, `assets/`) are unchanged — everything below describes what was removed.

## Top-level wiring (pre-cleanup `shell.qml`)

```
ShellRoot
├── Process: detects laptop vs desktop → GlobalStates.isLaptop
└── Loader (active on Preferences.isLoaded)
    └── Item containing:
        ├── PowerPanel                     (modules/)
        ├── LeftBar            ── signals ─┐
        │                                  ▼
        ├── LazyLoader (triggered by LeftBar.onInstantiated)
        │   ├── TopBar                     (modules/)
        │   └── DebugPanel                 (modules/)
        ├── Lockscreen                     (modules/)
        ├── NotificationPopup              (modules/)
        ├── NotificationCenterPanel        (modules/)
        ├── ControlCenter                  (modules/)
        ├── WallpaperPicker                (modules/)
        ├── MediaControls                  (modules/)
        ├── AppLauncherPanel               (modules/)
        └── Connections on Colors.source_color → razer-cli sync
```

Activation order mattered: `LeftBar` instantiates first, then signals via `onInstantiated` to lazy-load `TopBar` + `DebugPanel`. Everything else mounts immediately under the `Preferences.isLoaded` gate.

## State machine: `common/GlobalStates.qml` (surviving)

Panels are toggled via singleton booleans. Every `modules/` panel reads one of these for its `visible` binding and writes back on close:

| Flag | Owner module | IPC target |
| --- | --- | --- |
| `powerPanelOpen` | `PowerPanel.qml` | `powerpanel` |
| `controlCenterPanelOpen` | `ControlCenter.qml` | `controlcenter` |
| `notificationCenterOpen` | `NotificationCenterPanel.qml` | `notifcenter` |
| `wallpaperPickerOpen` | `WallpaperPicker.qml` | `wallpaperPicker` |
| `appLauncherOpen` | `AppLauncherPanel.qml` | `appLauncher` |
| `mediaControlsOpen` | `MediaControls.qml` | `mediaControls` |
| `screenLocked`, `screenUnlockFailed`, `screenLockContainsCharacters` | `Lockscreen.qml` | `lock` |
| `isLaptop` | set by `shell.qml` laptop-detect `Process` | — |
| `debugMode` | toggled by `DebugPanel` | — |

External tools toggled panels through `qs ipc call <target> <fn>`. The IPC handler list is the complete public surface of the old UI.

## Modules (panels)

Every module was a `Scope { Variants { model: Quickshell.screens; PanelWindow { … } } }` — one instance per monitor. Layer, anchors and keyboard focus are noted per panel.

### `LeftBar.qml` — always-on vertical dock (left edge)
- Layer: `WlrLayer.Top`, exclusive zone = width.
- Width: `Theme.ui.leftBarWidth` (76).
- Hidden while `powerPanelOpen`.
- Column content, top-to-bottom:
  - header row: `"SYS"` label + `"V2"` label
  - `ClockCard`
  - `BatteryCard`
  - `SystemButtonsCard`
  - `SystemTrayCard` (fills remaining height)
- Focused-mode branch: renders noisy/blurred `Canvas` texture + outlined border when `Preferences.focusedMode` is true.

### `TopBar.qml` — always-on horizontal bar (top edge)
- Layer: `WlrLayer.Top`, namespace `quickshell:topbar`, exclusive zone = height.
- Height: `Theme.ui.topBarHeight` (48).
- Hidden while `powerPanelOpen`.
- Row content, three sections:
  - **Left**: `Workspaces` (bound to `screen`), `MediaControlsButton`
  - **Center**: `Osd`
  - **Right**: `SystemStatusCard`, `PowerButton`
- Same focused-mode noise/blur treatment as `LeftBar`.

### `PowerPanel.qml` — fullscreen power menu (IPC `powerpanel.toggle`)
- Layer: `WlrLayer.Overlay`. Largest module at 439 lines.
- When open, hides `TopBar` and `LeftBar` via `powerPanelOpen`.
- Shutdown / Reboot / Suspend / Logout buttons (component: `SystemButtonsCard` and related).

### `Lockscreen.qml` — session lock (IPC `lock.*`)
- Driven by `GlobalStates.screenLocked`.
- Composition pulls from `components/lockscreen/`: `LockSurface` (wallpaper + blur backdrop), `LockClock`, `LockTextField` (password input via `Authentication` service), `LockButton`, `LockToolbar`.
- `Authentication` service handles PAM; sets `GlobalStates.screenUnlockFailed` on bad password.

### `ControlCenter.qml` — slide-in left panel (IPC `controlcenter.toggle`)
- Layer: `WlrLayer.Overlay`, width = half the screen.
- Slides in from left via `Translate` on `GlobalStates.controlCenterPanelOpen`.
- Left nav `ListView` with tabs: `Network`, `Bluetooth`, `Preferences`, `Battery`/`Power` (depends on `isLaptop`), `System Info`.
- Right `StackLayout` with matching panels: `NetworkPanel`, `BluetoothPanel`, `PreferencesPanel`, `PowerPanel` (local, NOT the top-level `modules/PowerPanel`), `AboutSystemPanel`.
- Escape key closes it via `Keys.onEscapePressed`.

### `AppLauncherPanel.qml` — app launcher (IPC `appLauncher.{toggle,open,close}`)
- Layer: `WlrLayer.Overlay`. Uses `AppSearch` service (fuzzy via `common/Fuzzy.qml` + `fuzzysort.js`).
- Renders `components/applauncher/AppLauncherItem` per hit.

### `NotificationPopup.qml` — transient toasts
- Layer: `WlrLayer.Overlay`. Subscribes to `Notifications` service, displays short-lived `NotificationItem`s.

### `NotificationCenterPanel.qml` — slide-in right panel (IPC `notifcenter.*`)
- Layer: `WlrLayer.Overlay`. Translates in from right.
- Hosts `NotificationCenterView` → `NotificationListView` → `NotificationGroup` → `NotificationItem` hierarchy.

### `WallpaperPicker.qml` — slide-in left panel (IPC `wallpaperPicker.open`, `.close`)
- Layer: `WlrLayer.Top`. Browses directories via `Wallpapers` service; each entry is a `WallpaperDirectoryItem` thumbnail.
- Largest module at 491 lines.

### `MediaControls.qml` — floating media bubble (IPC `mediaControls.{toggle,open,close}`)
- Layer: `WlrLayer.Top`. Position is `GlobalStates.mediaControlsX/Y` so callers can anchor it near their trigger.
- Content: `PlayerControl` (top-level `components/PlayerControl.qml`) driven by `SystemMpris` service.

### `DebugPanel.qml` — dev-only overlay
- Layer: `WlrLayer.Top`. Shown when `GlobalStates.debugMode` is true. Short (64 lines).

## Components (the removed tree)

Grouped by owning module. All paths relative to `components/`.

### Top-level (panel-agnostic cards used in `LeftBar`)
| File | Role |
| --- | --- |
| `BatteryCard.qml` | Battery status card; uses `widgets/BatteryProgressBar.qml` + `services/Power`. |
| `ClockCard.qml` | Clock/date card; reads `services/DateTime`. |
| `SystemButtonsCard.qml` | Power / lock / settings buttons row, opens various panels via `GlobalStates`. |
| `SystemTrayCard.qml` | Thin wrapper around `components/tray/Tray.qml`. |
| `PlayerControl.qml` | MPRIS player widget used by `MediaControls.qml`. |
| `DragManager.qml` | Generic drag helper used by tiles. |

### `applauncher/`
- `AppLauncherItem.qml` — fuzzy-match row (icon + name + category), emits launch on click.

### `controlcenter/`
- `NetworkPanel.qml` + `WifiNetworkItem.qml` + `KnownNetworkItem.qml` — Wi-Fi list and saved networks, talks to `services/Network` and `services/network/`.
- `BluetoothPanel.qml` + `BluetoothDeviceItem.qml` + `KnownBluetoothDeviceItem.qml` — `services/SystemBluetooth`.
- `PowerPanel.qml` (local to controlcenter) — battery/power tab inside ControlCenter (distinct from the fullscreen `modules/PowerPanel.qml`).
- `PreferencesPanel.qml` — toggles bound to `services/Preferences` (focusedMode, openrazerInstalled, …).
- `AboutSystemPanel.qml` — reads `assets/fastfetch-system-info.jsonc` via `services/SystemInfo`.

### `lockscreen/`
- `LockSurface.qml` — full-screen blurred wallpaper backdrop.
- `LockClock.qml` — big centered clock on the lock screen.
- `LockTextField.qml` — password input, calls `services/Authentication`.
- `LockButton.qml`, `LockToolbar.qml` — action buttons.

### `notification/`
- `notification_utils.js` — formatting helpers (timeago, urgency → icon mapping).
- `NotificationItem.qml` — single notification card.
- `NotificationGroup.qml` + `NotificationGroupExpandButton.qml` — stacked same-app notifications.
- `NotificationListView.qml`, `NotificationCenterView.qml` — scroll container wrappers.
- `NotificationActionButton.qml`, `NotificationAppIcon.qml`, `NotificationStatusButton.qml` — leaf widgets.

### `topbar/`
- `Workspaces.qml` — niri workspace indicator, reads `services/SystemNiri`.
- `SystemStatusCard.qml` — volume / brightness / network / bluetooth status cluster.
- `PowerButton.qml` — opens fullscreen `modules/PowerPanel` via `GlobalStates.powerPanelOpen`.
- `MediaControlsButton.qml` — opens the media bubble via `GlobalStates.mediaControlsOpen/X/Y`.
- `Osd.qml` + `OsdProgressBar.qml` — inline OSD for volume/brightness changes.

### `tray/`
- `Tray.qml` — `SystemTray` subscriber.
- `TrayItem.qml` — single status notifier item.
- `TrayMenu.qml` — right-click popup menu.

### `wallpaper/`
- `WallpaperDirectoryItem.qml` — thumbnail row rendered by `WallpaperPicker`. Uses `scripts/thumbnails/` for cached previews.

## Surviving layers (still load-bearing)

### `common/`
- **State singletons**: `GlobalStates` (cross-panel flags), `Preferences` (persisted user prefs — actually in `services/` but wired similarly), `Colors` (Material palette derived from `colors.json`), `Theme` (font families, sizes, padding tokens, animation curves `emphasized`/`standard` with matching durations).
- **Utils**: `ColorUtils`, `FileUtils`, `StringUtils`, `Fuzzy` + `fuzzysort.js`, `Images`, `DebugLogger`, `ApiClient`, `models/`.

### `services/`
Pure state providers — no UI. Each panel that was deleted consumed one or more:
- `DateTime` — used by `ClockCard`, `LockClock`.
- `SystemAudio`, `Brightness` — `Osd`, `SystemStatusCard`, ControlCenter volume slider.
- `Network`, `network/` — `NetworkPanel`, topbar status.
- `SystemBluetooth` — `BluetoothPanel`, topbar status.
- `Notifications` — `NotificationPopup`, `NotificationCenterPanel`.
- `SystemMpris` — `MediaControls`, `PlayerControl`, `MediaControlsButton`.
- `SystemNiri` — `Workspaces`.
- `Power` — `BatteryCard`, `PowerPanel` tab.
- `Authentication` — `Lockscreen`.
- `Wallpapers` — `WallpaperPicker`.
- `AppLauncher`, `AppSearch` — `AppLauncherPanel`.
- `Preferences` — gates rendering via `Preferences.isLoaded` and exposes `focusedMode`, `openrazerInstalled`, …
- `SystemInfo` — `AboutSystemPanel`.
- `apis/` — external HTTP clients (weather, etc.).

### `widgets/`
Reusable primitives, no knowledge of any specific panel. The ones most obviously tied to deleted UI (flagged for possible later removal): `BatteryProgressBar`, `ControlCenterPanelSection`, `RectWidgetCard`. All others (`MaterialSymbol`, `StyledButton`, `StyledText`, `StyledTextField`, `StyledSwitchButton`, `StyledSlider`, `StyledRadioButton`, `StyledIndicatorButton`, `StyledProgressBar`, `StyledImage`, `ThumbnailImage`, `StyledListView`, `MaterialCookie`) are fully generic.

## Fonts

- **Material Symbols Rounded** (variable TTF, axes `FILL, GRAD, opsz, wght`) — the only icon font. Loaded via `widgets/MaterialSymbol.qml` (`font.family: "Material Symbols Rounded"`).
- System install location: `/usr/share/fonts/TTF/MaterialSymbolsRounded[FILL,GRAD,opsz,wght].ttf` (also `Outlined` and `Sharp` variants present). Verified registered in the fontconfig cache via `fc-list | grep -i material`. No local font file in `assets/`.
- Text fonts referenced from `Theme.font.family.inter_regular` / `inter_bold` — defined in `common/Theme.qml`.

## Recovery

Everything documented here lives in git history before the cleanup commit on branch `niri-base`. To inspect a specific deleted file:
```
git log --all --full-history -- components/lockscreen/LockClock.qml
git show <sha>:components/lockscreen/LockClock.qml
```
