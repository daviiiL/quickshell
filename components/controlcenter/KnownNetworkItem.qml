pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

import qs.common
import qs.services
import qs.widgets

Rectangle {
    id: knownItem
    required property string networkName
    height: 60
    radius: Theme.ui.radius.md
    color: knownMouseArea.containsMouse || forgetMouseArea.containsMouse ? Colors.surface_container_high : Colors.surface_container

    Behavior on color {
        ColorAnimation {
            duration: Theme.anim.durations.sm
            easing.type: Easing.Bezier
            easing.bezierCurve: Theme.anim.curves.emphasized
        }
    }

    MouseArea {
        id: knownMouseArea
        anchors.fill: parent
        hoverEnabled: true
        z: -1
        onClicked: {
            // Try to connect to the known network
            const network = Network.wifiNetworks.find(n => n.ssid === knownItem.networkName);
            if (network) {
                Network.connectToWifiNetwork(network);
            } else {
                // TODO: finish this implementation
                // // Network not in range, try connecting by name
                // Quickshell.exec(["nmcli", "connection", "up", knownItem.networkName]);
            }
        }
    }

    property var matchedNetwork: Network.wifiNetworks.find(n => n.ssid === knownItem.networkName)

    RowLayout {
        anchors.fill: parent
        anchors.margins: Theme.ui.padding.md
        spacing: Theme.ui.padding.md

        MaterialSymbol {
            icon: {
                const strength = knownItem.matchedNetwork?.strength ?? 0;
                if (!knownItem.matchedNetwork)
                    return "signal_wifi_off";
                return strength > 80 ? "signal_wifi_4_bar" : strength > 60 ? "network_wifi_3_bar" : strength > 40 ? "network_wifi_2_bar" : strength > 20 ? "network_wifi_1_bar" : "signal_wifi_0_bar";
            }
            fontColor: knownItem.matchedNetwork ? Colors.on_surface_variant : Colors.outline
            iconSize: Theme.font.size.xl
        }

        Text {
            Layout.fillWidth: true
            text: knownItem.networkName
            font {
                pixelSize: Theme.font.size.md
                family: Theme.font.family.inter_regular
            }
            color: Colors.on_surface
            elide: Text.ElideRight
        }

        Rectangle {
            Layout.alignment: Qt.AlignRight
            Layout.preferredHeight: icon.implicitHeight + 4
            Layout.preferredWidth: icon.implicitWidth + 4
            radius: Theme.ui.radius.md
            color: forgetMouseArea.containsMouse ? Colors.error_container : "transparent"

            MaterialSymbol {
                id: icon
                anchors.centerIn: parent
                icon: "delete"
                fontColor: Colors.on_surface
                iconSize: 15
                animated: true
                colorAnimated: true
            }

            MouseArea {
                id: forgetMouseArea
                anchors.fill: parent
                hoverEnabled: true
                onClicked: {
                    // console.debug(`forgetting ${knownItem.networkName}`);
                    Network.forgetNetwork(knownItem.networkName);
                }
            }
        }
    }
}
