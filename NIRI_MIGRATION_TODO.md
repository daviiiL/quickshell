# Niri Migration TODO

This document lists all Hyprland dependencies that need to be updated for Niri compatibility.

## QML Files Requiring Updates
<!---->
<!-- ### 1. **modules/AppLauncherPanel.qml** -->
<!-- - Line 8: `import Quickshell.Hyprland` → Replace with `import Quickshell.Niri` -->

<!-- ### 2. **modules/Lockscreen.qml** -->
<!-- - Line 7: `import Quickshell.Hyprland` → Replace with `import Quickshell.Niri` -->
<!-- - Line 34: `hyprctl --batch "dispatch togglespecialworkspace; dispatch togglespecialworkspace"` -->
<!--   → Replace with Niri IPC commands to toggle workspaces -->

### 3. **modules/PowerPanel.qml**
- Line 145: `Hyprland.dispatch("global quickshell:lock")` → Replace with Niri lock command
- Line 155: `Hyprland.dispatch("exit")` → Replace with Niri exit command

### 4. **modules/MediaControls.qml**
- Line 7: `import Quickshell.Hyprland` → Replace with `import Quickshell.Niri`
- Line 51: `HyprlandFocusGrab` → Replace with Niri equivalent focus grab mechanism

### 5. **modules/ScreenCorners.qml**
- Line 4: `import Quickshell.Hyprland` → Replace with `import Quickshell.Niri`
- Line 15: `property HyprlandMonitor monitor: Hyprland.monitorFor(modelData)`
  → Replace with Niri monitor API
- Line 17: `property list<HyprlandWorkspace> workspacesForMonitor`
  → Replace with Niri workspace API

### 6. **components/Workspaces.qml**
- Line 3: `import Quickshell.Hyprland` → Replace with `import Quickshell.Niri`
- Line 13: `readonly property HyprlandMonitor monitor: Hyprland.monitorFor(root.QsWindow.window?.screen)`
  → Replace with Niri monitor API
- Line 42: `const toplevels = Hyprland.toplevels.values ?? [];`
  → Replace with Niri window/toplevel API
- Line 58: `target: Hyprland.workspaces` → Replace with Niri workspaces
- Line 64: `target: Hyprland` → Replace with Niri global object
- Line 76: `Hyprland.dispatch('workspace r+1')` → Replace with Niri workspace switch command
- Line 78: `Hyprland.dispatch('workspace r-1')` → Replace with Niri workspace switch command
- Line 192: `Hyprland.dispatch('workspace ${workspaceValue}')` → Replace with Niri workspace switch

### 7. **components/ScreenCorner.qml**
- Line 1: Comment references "dots-hyprland" - update documentation/attribution if needed

### 8. **services/HyprlandXkb.qml**
- **Entire file needs refactoring**
- Line 15: `hyprctl devices -j | jq -r '.keyboards[0].active_keymap'`
  → Replace with Niri IPC command to get keyboard layout
- Rename file to `NiriXkb.qml` or similar

### 9. **scripts/wallpaper/switch_wall.sh**
- Lines 79-84: hyprctl/hyprpaper commands
  ```bash
  if command -v hyprctl &>/dev/null; then
      hyprctl hyprpaper preload "$WALLPAPER_PATH"
      monitors=$(hyprctl monitors -j | jq -r '.[] | .name')
      for monitor in $monitors; do
          hyprctl hyprpaper wallpaper "$monitor,$WALLPAPER_PATH"
  ```
  → Replace with Niri wallpaper setting mechanism (swaybg, wpaperd, or Niri's native wallpaper support)

## API Mapping Reference

### Hyprland → Niri Equivalents Needed

| Hyprland API | Niri Equivalent | Notes |
|--------------|-----------------|-------|
| `Hyprland.dispatch()` | TBD | Check Quickshell.Niri docs |
| `Hyprland.monitorFor()` | TBD | Niri monitor API |
| `Hyprland.workspaces` | TBD | Niri workspace API |
| `Hyprland.toplevels` | TBD | Niri window/toplevel API |
| `HyprlandMonitor` | TBD | Niri monitor type |
| `HyprlandWorkspace` | TBD | Niri workspace type |
| `HyprlandFocusGrab` | TBD | Niri focus grab mechanism |
| `hyprctl` commands | `niri msg` | Niri IPC commands |

## Action Items

1. **Research Quickshell.Niri API**
   - Check if Quickshell has Niri bindings available
   - Document Niri IPC command equivalents
   - Find Niri wallpaper solution

2. **Update All QML Imports**
   - Replace all `import Quickshell.Hyprland` statements

3. **Refactor Workspace Management**
   - Update Workspaces.qml with Niri API
   - Test workspace switching functionality

4. **Update Power Management**
   - Replace lock/exit dispatcher calls
   - Ensure compatibility with system session management

5. **Fix Wallpaper Script**
   - Decide on wallpaper daemon (swaybg, wpaperd, etc.)
   - Update switch_wall.sh script

6. **Update Keyboard Layout Service**
   - Rewrite HyprlandXkb.qml for Niri
   - Test keyboard layout detection

7. **Test Screen Corners**
   - Verify ScreenCorners.qml works with Niri monitor API
   - Test focus grab behavior

8. **Remove Unused Hyprland-specific Features**
   - Check if any Hyprland-specific features don't have Niri equivalents
   - Document any functionality gaps
