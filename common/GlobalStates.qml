pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

Singleton {
    property bool screenLocked: false
    property bool screenUnlockFailed: false
    property bool screenLockContainsCharacters: false

    property bool sidebarOpen: false
    property bool notificationCenterOpen: false
    property bool powerPanelOpen: false
    property bool controlCenterPanelOpen: false
    property bool wallpaperPickerOpen: false
    property bool appLauncherOpen: false
    property bool leftPanelOpen: false
    property bool rightPanelOpen: false
    property string rightPanelSource: ""
    property bool networkOverlayOpen: false
    property real networkButtonCenterX: 0

    property bool mediaControlsOpen: false
    property real mediaControlsX: 0
    property real mediaControlsY: 0

    property bool isLaptop: true
    property bool debugMode: false
}
