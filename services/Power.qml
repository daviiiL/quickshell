import ".."
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.UPower

Singleton {
    id: root

    readonly property real percentage: UPower.displayDevice.percentage
    readonly property real timeToGoal: UPower.displayDevice.timeToEmpty || UPower.displayDevice.timeToFull
    readonly property bool isLaptopBattery: UPower.displayDevice.isLaptopBattery || false
    readonly property bool state: UPower.displayDevice.state
    readonly property string currentProfile: PowerProfile.toString(PowerProfiles.profile)

    readonly property bool onBattery: UPower.onBattery

    readonly property string powerProfileIconText: {
        if (PowerProfiles.profile === PowerProfile.PowerSaver)
            return "energy_savings_leaf";
        if (PowerProfiles.profile === PowerProfile.Performance)
            return "rocket_launch";
        return "balance";
    }

    function setPowerProfile(profileName: string) {
        var profile;
        switch (profileName) {
        case "Performance":
            PowerProfiles.profile = PowerProfile.Performance;
            break;
        case "PowerSaver":
            PowerProfiles.profile = PowerProfile.PowerSaver;
            break;
        default:
            PowerProfiles.profile = PowerProfile.Balanced;
            break;
        }

        return;
    }
}
