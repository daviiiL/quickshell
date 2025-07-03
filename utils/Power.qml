pragma Singleton

import Quickshell
import Quickshell.Services.UPower

Singleton {
    id: root

    readonly property real percentage: UPower.displayDevice.percentage

    readonly property real timeToGoal: UPower.displayDevice.timeToEmpty || UPower.displayDevice.timeToFull
}
