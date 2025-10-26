pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

Singleton {
    id: root

    // Panel states
    property bool sidebarOpen: false
    property bool sidebarLeftOpen: false

    // OSD states
    property bool osdVolumeOpen: false
    property bool osdBrightnessOpen: false

    // Other states
    property bool screenLocked: false
}
