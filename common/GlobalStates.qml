pragma Singleton
pragma ComponentBehavior: Bound

import Quickshell

Singleton {
    property bool screenLocked: false
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
}
