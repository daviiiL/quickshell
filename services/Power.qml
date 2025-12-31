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

    readonly property real healthPercentage: UPower.displayDevice.healthPercentage || 1.0

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

    function formatTime(seconds) {
        if (!Number.isFinite(seconds) || seconds <= 0) {
            return "00:00";
        }

        const hrs = Math.floor(seconds / 3600);
        const mins = Math.floor((seconds % 3600) / 60);
        const hh = String(hrs).padStart(2, "0");
        const mm = String(mins).padStart(2, "0");
        return `${hh}:${mm}`;
    }

    readonly property string batteryStatusText: {
        if (percentage > 0.99) {
            return "Fully charged";
        }
        return `EST ${formatTime(timeToGoal)} ${isCharging ? "till full" : "left"}`;
    }

    readonly property string batteryChangeRateText: {
        if (UPower.displayDevice.changeRate === 0) {
            return "Battery not in use";
        }
        return `${isCharging ? "Charging at " : "Discharging at "}${Math.abs(UPower.displayDevice.changeRate).toFixed(2)} W`;
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
