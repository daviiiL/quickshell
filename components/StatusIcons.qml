import QtQuick
import QtQuick.Layouts

import Quickshell.Widgets
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

    ClippingRectangle {
        id: rect
        width: root.parent.width - 12
        anchors.left: parent.left
        anchors.leftMargin: 6
        implicitHeight: bluetooth.implicitHeight + network.implicitHeight + (spacer.implicitHeight * 3)
        color: Colors.values.secondary_container
        radius: Config.rounding.regular

        property bool expanded: rect.width !== root.parent.width - 12

        MouseArea {
            id: capture
            anchors.fill: parent
            hoverEnabled: true
            onEntered: rect.width = 4 * root.implicitWidth - 12
            onExited: rect.width = root.parent.width - 12
        }

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
                opacity: rect.expanded ? 1.0 : 0.0
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
                text: `󰌘 SSID: ${Network.active.ssid.slice(0, 8)}...`
                color: Colors.values.on_secondary_container
                font.family: Config.font.style.inter
                font.pointSize: Config.font.size.regular
                opacity: rect.expanded ? 1.0 : 0.0
            }
        }

        VerticalSpacer {
            spacerHeight: 10
            anchors.top: network.bottom
        }

        Behavior on width {
            NumberAnimation {
                duration: 300
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Config.anim.curves.standardAccel
            }
        }
    }
}
