pragma Singleton

import Quickshell
import Quickshell.Services.UPower

Singleton {
    id: root

    readonly property real percentage: UPower.displayDevice.percentage
    readonly property bool is_charging: UPowerDeviceState.Charging
    readonly property real timeToGoal: is_charging ? UPowerDevice.timeToFull : UPowerDevice.timeToEmpty || 0
}
