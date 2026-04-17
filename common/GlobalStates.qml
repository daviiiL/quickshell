pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

Singleton {
    // Lock screen
    property bool screenLocked: false
    property bool screenUnlockFailed: false
    property bool screenLockContainsCharacters: false

    // Panels / overlays
    property bool sidebarOpen: false
    property bool notificationCenterOpen: false
    property bool powerPanelOpen: false
    property bool controlCenterPanelOpen: false
    property bool wallpaperPickerOpen: false
    property bool appLauncherOpen: false

    // Media controls (tracks position of floating popup)
    property bool mediaControlsOpen: false
    property real mediaControlsX: 0
    property real mediaControlsY: 0

    // Device / misc
    property bool isLaptop: true
    property bool debugMode: false
}
