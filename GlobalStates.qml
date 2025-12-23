pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

Singleton {
    id: root

    property bool sidebarOpen: false
    property bool sidebarLeftOpen: false

    property bool osdVolumeOpen: false
    property bool osdBrightnessOpen: false

    property bool screenLocked: false
    property bool screenLockContainsCharacters: false
    property bool screenUnlockFailed: false
    property bool cheatsheetOpen: false

    property bool isLaptop: true

    property bool statusBarExpanded: false

    property bool debug: false

    signal showCheatsheet
    signal hideCheatsheet
    signal toggleCheatsheet
}
