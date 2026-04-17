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
        if (root.onEthernet) return "ethernet";
        if (root.onWifi)     return "connected";
        if (Network.wifiEnabled) return "disconnected";
        return "off";
    }

    implicitHeight: col.implicitHeight

    ColumnLayout {
        id: col
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        spacing: 0

        OverlayHeader {
            title: "network"
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
                    : "CONNECTED"
        }

        ConnectionCard {
            visible: !root.onEthernet && root.onWifi
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

        WifiSection {}
    }
}
