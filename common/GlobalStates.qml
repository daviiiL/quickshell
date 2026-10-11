pragma Singleton
pragma ComponentBehavior: Bound

import Quickshell

Singleton {
    // Restored after the root tree reloads, which hands the compositor lock to the new WlSessionLock first.
    PersistentProperties {
        id: persist
        reloadableId: "lockState"
        property bool screenLocked: false
    }

    property alias screenLocked: persist.screenLocked
    property bool screenDismissing: false
    property bool screenUnlockFailed: false
    property bool screenLockContainsCharacters: false

    property bool appLauncherOpen: false
    property bool cliphistOverlayOpen: false
    property bool keybindHintsOpen: false
    property bool leftPanelOpen: false
    property bool rightPanelOpen: false
    property string rightPanelSource: ""
    property bool networkOverlayOpen: false
    property string networkOverlayScreen: ""
    property var networkButtonCenters: ({})

    function setNetworkButtonCenter(screenName, x) {
        if (!screenName) return;
        const current = networkButtonCenters[screenName];
        if (current === x) return;
        const next = Object.assign({}, networkButtonCenters);
        next[screenName] = x;
        networkButtonCenters = next;
    }

    property bool controlCenterOpen: false
    property string controlCenterPane: "quick"

    function openControlCenter(source: string): void {
        controlCenterOpen = true;
    }

    function closeControlCenter(): void {
        controlCenterOpen = false;
    }

    property bool wallpaperPickerOpen: false
    property bool wallpaperPickerReturnToControlCenter: false

    function openWallpaperPicker(source: string): void {
        wallpaperPickerReturnToControlCenter = controlCenterOpen;
        if (controlCenterOpen)
            closeControlCenter();
        wallpaperPickerOpen = true;
    }

    function closeWallpaperPicker(): void {
        if (!wallpaperPickerOpen)
            return;
        wallpaperPickerOpen = false;
        if (wallpaperPickerReturnToControlCenter) {
            wallpaperPickerReturnToControlCenter = false;
            openControlCenter("wallpaperpicker");
        }
    }

    property bool powerProfileOverlayOpen: false
    property string powerProfileOverlayScreen: ""
    property var powerProfileButtonCenters: ({})

    function setPowerProfileButtonCenter(screenName, x) {
        if (!screenName) return;
        const current = powerProfileButtonCenters[screenName];
        if (current === x) return;
        const next = Object.assign({}, powerProfileButtonCenters);
        next[screenName] = x;
        powerProfileButtonCenters = next;
    }

    property bool isLaptop: true
    property bool debugMode: false

    property bool darkMode: true

    function toggleDarkMode(): void {
        darkMode = !darkMode;
    }

    property int fontOffset: 0

    property bool caffeinated: false

    function setCaffeinated(on: bool): void {
        if (caffeinated === on)
            return;
        caffeinated = on;
        console.log("[IdleManager] caffeine " + (on ? "on" : "off"));
    }

    function toggleCaffeine(): void {
        setCaffeinated(!caffeinated);
    }
}
