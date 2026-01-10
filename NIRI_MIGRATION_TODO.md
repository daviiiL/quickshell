# Niri Migration TODO

This document lists all Hyprland dependencies that need to be updated for Niri compatibility.


### 10. **scripts/wallpaper/switch_wall.sh**
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
