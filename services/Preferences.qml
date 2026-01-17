pragma ComponentBehavior: Bound
pragma Singleton

import Quickshell
import QtQuick

Singleton {
    id: root

    property bool darkMode: true

    function setDarkMode(value: bool): void {
        root.darkMode = value
    }

    function setColorMode(value: int): void {
        root.darkMode = value === 0 ? true : false
    }
}
