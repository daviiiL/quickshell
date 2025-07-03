import QtQuick
import "../utils/"

Item {
    id: root

    implicitHeight: rect.height
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

    Rectangle {
        id: rect
        implicitWidth: parent.width - 12
        anchors.horizontalCenter: parent.horizontalCenter
        implicitHeight: bluetooth.implicitHeight + network.implicitHeight + (spacer.implicitHeight * 3)
        color: Colors.values.secondary_container
        radius: Config.rounding.regular

        VerticalSpacer {
            id: topSpacer
            spacerHeight: 10
            anchors.bottom: bluetooth.top
            anchors.top: parent.top
        }

        MaterialSymbol {
            id: bluetooth
            icon: Bluetooth.powered ? "bluetooth" : "bluetooth_disabled"
            fontColor: Colors.values.on_secondary_container
            fontSize: 15
            anchors.top: topSpacer.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            animated: true
        }

        VerticalSpacer {
            id: spacer
            spacerHeight: 10
            anchors {
                top: bluetooth.bottom
            }
        }

        MaterialSymbol {
            id: network
            icon: Network.active ? root.getNetworkIcon(Network.active.strength ?? 0) : "wifi_off"
            fontColor: Colors.values.on_secondary_container
            fontSize: 15
            anchors.top: spacer.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            animated: true
        }

        VerticalSpacer {
            spacerHeight: 10
            anchors.top: network.bottom
        }
    }
}
