pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.common
import qs.services

Item {
    id: root

    readonly property bool onEthernet: Network.ethernet && Network.ethernetConnected
    readonly property bool onWifi: !onEthernet && Network.wifiEnabled && Network.active !== null
    readonly property string overlayState: {
        if (root.onEthernet) return "Ethernet";
        if (root.onWifi)     return "Connected";
        if (Network.wifiEnabled) return "Disconnected";
        return "Off";
    }

    ColumnLayout {
        id: col
        anchors.fill: parent
        spacing: 0

        OverlayHeader {
            title: "Network"
            state: root.overlayState
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: Theme.ui.mainBarHairWidth
            color: Colors.hair
        }

        ConnectionCard {
            visible: root.onEthernet
            Layout.fillWidth: true
            iconSymbol: "lan"
            title: "Wired — " + (Network.ethernetDevice || "ethernet")
            meta: Network.ethernetSpeed && Network.ethernetSpeed.length > 0
                    ? Network.ethernetSpeed
                    : "Connected"
        }

        ConnectionCard {
            visible: root.onWifi
            Layout.fillWidth: true
            iconSymbol: Network.materialSymbol
            title: Network.networkName || "Wi-Fi"
            meta: Network.networkStrength + "%" +
                  (Network.active && Network.active.security.length > 0
                      ? " · " + Network.active.security.toUpperCase()
                      : "")
        }

        Rectangle {
            visible: root.onEthernet || root.onWifi
            Layout.fillWidth: true
            Layout.preferredHeight: Theme.ui.mainBarHairWidth
            color: Colors.hair
        }

        WifiSection {
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
    }
}
