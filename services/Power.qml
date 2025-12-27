pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.UPower

Singleton {
    id: root

    readonly property bool onBattery: UPower.onBattery
    readonly property bool isLaptopBattery: UPower.displayDevice.isLaptopBattery || false

    readonly property real percentage: UPower.displayDevice.percentage
    readonly property int state: UPower.displayDevice.state
    readonly property bool isCharging: state === UPowerDeviceState.Charging
    readonly property real timeToGoal: {
        return UPower.displayDevice.timeToEmpty !== 0 ? UPower.displayDevice.timeToEmpty : UPower.displayDevice.timeToFull;
    }

    readonly property string currentProfile: PowerProfile.toString(PowerProfiles.profile)
    readonly property bool isPerformanceMode: currentProfile === "Performance"
    readonly property string powerProfileIcon: {
        switch (PowerProfiles.profile) {
        case PowerProfile.PowerSaver:
            return "energy_savings_leaf";
        case PowerProfile.Performance:
            return "speed";
        case PowerProfile.Balanced:
        default:
            return "donut_large";
        }
    }
    readonly property string powerProfileText: {
        switch (PowerProfiles.profile) {
        case PowerProfile.PowerSaver:
            return "Energy";
        case PowerProfile.Performance:
            return "Boost";
        case PowerProfile.Balanced:
        default:
            return "Balanced";
        }
    }
    function setPowerProfile(profileName: string) {
        switch (profileName) {
        case "Performance":
            PowerProfiles.profile = PowerProfile.Performance;
            break;
        case "PowerSaver":
            PowerProfiles.profile = PowerProfile.PowerSaver;
            break;
        case "Balanced":
        default:
            PowerProfiles.profile = PowerProfile.Balanced;
            break;
        }
    }
}
