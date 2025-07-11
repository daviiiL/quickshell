pragma Singleton

import Quickshell
import QtQuick

Singleton {
    id: root
    // When using the block syntax for property bindings the last expression
    // must be returned. Without an explicit return statement the binding would
    // evaluate to `undefined`.  Define the properties directly so that the
    // formatted value is returned correctly.
    readonly property string date: Qt.formatDateTime(clock.date, "ddd")
    readonly property string time: Qt.formatDateTime(clock.date, "hh:mm")
    readonly property string hrs: Qt.formatDateTime(clock.date, "hh")
    readonly property string mins: Qt.formatDateTime(clock.date, "mm")

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }
}
