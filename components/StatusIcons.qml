import QtQuick
import QtQuick.Layouts

import Quickshell.Widgets
import "../utils/"

Item {
    id: root
    
    property bool expanded: container.expanded

    implicitHeight: container.height
    implicitWidth: parent.width

    function getNetworkIcon(strength: int): string {
        if (strength >= 80)
            return "signal_wifi_4_bar";
        if (strength >= 60)
            return "network_wifi_3_bar";
        if (strength >= 40)
            return "network_wifi_2_bar";
        if (strength >= 20)
            return "network_wifi_1_bar";
        return "signal_wifi_0_bar";
    }

    ExpandingContainer {
        id: container
        collapsedWidth: root.parent.width - 12
        expandedWidth: 4 * root.implicitWidth - 12
        anchors.left: parent.left
        anchors.leftMargin: 6
        implicitHeight: bluetooth.implicitHeight + network.implicitHeight + (spacer.implicitHeight * 3)

        VerticalSpacer {
            id: topSpacer
            spacerHeight: 10
            anchors.bottom: bluetooth.top
            anchors.top: parent.top
        }

        RowLayout {
            id: bluetooth
            anchors.top: topSpacer.bottom
            spacing: root.implicitWidth - bluetoothIcon.width - 6
            MaterialSymbol {
                id: bluetoothIcon
                icon: Bluetooth.powered ? "bluetooth" : "bluetooth_disabled"
                fontColor: Colors.values.on_secondary_container
                fontSize: 15
                anchors.left: parent.left
                anchors.leftMargin: (root.implicitWidth - this.width - 12) / 2
                animated: true
            }
            Text {
                text: `${Bluetooth.devices.length} device connected`
                color: Colors.values.on_secondary_container
                font.family: Config.font.style.inter
                font.pointSize: Config.font.size.regular
                opacity: container.expanded ? 1.0 : 0.0
            }
        }

        VerticalSpacer {
            id: spacer
            spacerHeight: 10
            anchors {
                top: bluetooth.bottom
            }
        }

        RowLayout {
            id: network
            anchors.top: spacer.bottom
            spacing: root.implicitWidth - networkIcon.width - 6
            MaterialSymbol {
                id: networkIcon
                icon: Network.active ? root.getNetworkIcon(Network.active.strength ?? 0) : "wifi_off"
                fontColor: Colors.values.on_secondary_container
                fontSize: 15
                anchors.left: parent.left
                anchors.leftMargin: (root.implicitWidth - this.width - 12) / 2
                animated: true
            }
            Text {
                text: Network.active ? `󰌘 SSID: ${Network.active?.ssid?.slice(0, 8) || ""}...` : "Disconnected"
                color: Colors.values.on_secondary_container
                font.family: Config.font.style.inter
                font.pointSize: Config.font.size.regular
                opacity: container.expanded ? 1.0 : 0.0
            }
        }

        VerticalSpacer {
            spacerHeight: 10
            anchors.top: network.bottom
        }

    }
}
