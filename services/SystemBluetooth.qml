pragma Singleton
pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Bluetooth
import QtQuick

Singleton {
    id: root

    readonly property bool available: Bluetooth.adapters.values.length > 0
    readonly property bool enabled: Bluetooth.defaultAdapter?.enabled ?? false

    readonly property bool discovering: Bluetooth.defaultAdapter?.discovering ?? false
    readonly property BluetoothDevice firstActiveDevice: Bluetooth.defaultAdapter?.devices.values.find(device => device.connected) ?? null
    readonly property int activeDeviceCount: Bluetooth.defaultAdapter?.devices.values.filter(device => device.connected).length ?? 0
    readonly property bool connected: Bluetooth.devices.values.some(d => d.connected)

    function sortFunction(a, b) {
        const macRegex = /^([0-9A-Fa-f]{2}-){5}[0-9A-Fa-f]{2}$/;
        const aIsMac = macRegex.test(a.name);
        const bIsMac = macRegex.test(b.name);
        if (aIsMac !== bIsMac)
            return aIsMac ? 1 : -1;

        return a.name.localeCompare(b.name);
    }

    property list<var> connectedDevices: Bluetooth.devices.values.filter(d => d.connected).sort(sortFunction)
    property list<var> pairedButNotConnectedDevices: Bluetooth.devices.values.filter(d => d.paired && !d.connected).sort(sortFunction)
    property list<var> unpairedDevices: Bluetooth.devices.values.filter(d => !d.paired && !d.connected).sort(sortFunction)
    property list<var> friendlyDeviceList: [...connectedDevices, ...pairedButNotConnectedDevices, ...unpairedDevices]

    function toggleBluetooth(): void {
        if (Bluetooth.defaultAdapter) {
            Bluetooth.defaultAdapter.enabled = !enabled;
        }
    }

    function bluetoothDeviceIconName(type: string): string {
        const t = type ?? "";

        if (t.includes("audio") || t.includes("headset") || t.includes("headphone"))
            return "headphones";
        if (t.includes("phone"))
            return "phone_android";
        if (t.includes("computer"))
            return "computer";
        if (t.includes("keyboard"))
            return "keyboard";
        if (t.includes("mouse"))
            return "mouse";
        return "bluetooth";
    }

    Timer {
        id: discoveringTimer

        interval: 20000
        repeat: false
        running: false
        onTriggered: () => {
            root.stopDiscovering();
        }
    }

    function startDiscovering(): void {
        if (Bluetooth.defaultAdapter && enabled) {
            // console.debug("BT Discovery started");
            Bluetooth.defaultAdapter.discovering = true;
            discoveringTimer.running = true;
        }
    }

    function stopDiscovering(): void {
        if (Bluetooth.defaultAdapter) {
            Bluetooth.defaultAdapter.discovering = false;
        }
    }

    function connectDevice(device: BluetoothDevice): void {
        if (device) {
            device.connect();
        }
    }

    function disconnectDevice(device: BluetoothDevice): void {
        if (device) {
            device.disconnect();
        }
    }

    function pairDevice(device: BluetoothDevice): void {
        if (device) {
            device.pair();
        }
    }

    function unpairDevice(device: BluetoothDevice): void {
        if (device && device.paired) {
            device.forget();
        }
    }
}
