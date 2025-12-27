pragma Singleton

import Quickshell
import QtQuick

Singleton {
    id: root
    readonly property string date: {
        Qt.formatDateTime(clock.date, "ddd d");
    }

    readonly property string time: {
        Qt.formatDateTime(clock.date, "hh:mm");
    }

    readonly property string hrs: {
        Qt.formatDateTime(clock.date, "hh");
    }

    readonly property string mins: {
        Qt.formatDateTime(clock.date, "mm");
    }

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }
}
