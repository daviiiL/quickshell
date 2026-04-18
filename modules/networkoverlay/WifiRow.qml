pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.common
import qs.services
import qs.widgets

Rectangle {
    id: root

    required property var ap

    signal expandRequested(var ap)

    readonly property int strength: root.ap?.strength ?? 0
    readonly property bool isSecure: root.ap?.isSecure ?? false
    readonly property bool isActive: root.ap?.active ?? false
    readonly property bool isWeak: root.strength < 35
    readonly property string ssid: root.ap?.ssid ?? ""
    readonly property string security: root.ap?.security ?? ""
    readonly property bool isKnown: root.ap
                                    && Network.knownNetworks
                                    && Network.knownNetworks.indexOf(root.ssid) !== -1
    readonly property bool isConnecting: Network.wifiConnecting
                                          && Network.wifiConnectTarget === root.ap

    readonly property string wifiIcon: {
        if (root.strength > 83) return "signal_wifi_4_bar";
        if (root.strength > 67) return "network_wifi";
        if (root.strength > 50) return "network_wifi_3_bar";
        if (root.strength > 33) return "network_wifi_2_bar";
        if (root.strength > 17) return "network_wifi_1_bar";
        return "signal_wifi_0_bar";
    }

    implicitHeight: row.implicitHeight + 28
    color: ma.containsMouse ? Colors.surfaceContainerLow : "transparent"
    Behavior on color { ColorAnimation { duration: Theme.anim.durations.xs } }

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: Theme.ui.mainBarHairWidth
        color: Colors.hair
    }

    RowLayout {
        id: row
        anchors.fill: parent
        anchors.leftMargin: 16
        anchors.rightMargin: 16
        anchors.topMargin: 14
        anchors.bottomMargin: 14
        spacing: 12

        Item {
            Layout.preferredWidth: 22
            Layout.preferredHeight: 22
            Layout.alignment: Qt.AlignVCenter

            MaterialSymbol {
                anchors.centerIn: parent
                visible: !root.isConnecting
                icon: root.wifiIcon
                iconSize: 17
                fill: root.isActive ? 1 : 0
                fontColor: root.isWeak ? Colors.inkDim : Colors.fgSurface
                opacity: root.isWeak ? 0.5 : (root.isActive ? 1.0 : 0.78)
            }

            Rectangle {
                anchors.centerIn: parent
                visible: root.isConnecting
                width: 7
                height: 7
                radius: 3.5
                color: Colors.barAccent
                SequentialAnimation on opacity {
                    running: root.isConnecting
                    loops: Animation.Infinite
                    NumberAnimation { from: 1;    to: 0.3; duration: 550 }
                    NumberAnimation { from: 0.3;  to: 1;   duration: 550 }
                }
                SequentialAnimation on scale {
                    running: root.isConnecting
                    loops: Animation.Infinite
                    NumberAnimation { from: 1;    to: 0.78; duration: 550 }
                    NumberAnimation { from: 0.78; to: 1;    duration: 550 }
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            Text {
                Layout.fillWidth: true
                text: root.ssid
                color: root.isWeak ? Colors.inkDim : Colors.fgSurface
                font.family: Theme.font.family.inter_medium
                font.pixelSize: 14
                font.weight: root.isActive ? Font.Medium : Font.Normal
                elide: Text.ElideRight
            }

            Text {
                text: root.isConnecting
                        ? "CONNECTING…"
                        : (root.isActive
                            ? "CONNECTED"
                            : (root.security.length > 0 ? root.security.toUpperCase() : "OPEN"))
                color: root.isConnecting
                        ? Colors.fgSurface
                        : (root.isActive ? Colors.live : Colors.inkDimmer)
                font.family: Theme.font.family.inter_medium
                font.pixelSize: 11
                font.letterSpacing: 1.4
            }
        }

        MaterialSymbol {
            visible: root.isSecure
            Layout.alignment: Qt.AlignVCenter
            icon: "lock"
            iconSize: 14
            fontColor: Colors.inkDimmer
        }

        Text {
            Layout.preferredWidth: 34
            Layout.alignment: Qt.AlignVCenter
            horizontalAlignment: Text.AlignRight
            text: root.strength + "%"
            color: Colors.inkDim
            font.family: Theme.font.family.inter_regular
            font.pixelSize: 12
            font.letterSpacing: 0.2
        }
    }

    MouseArea {
        id: ma
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            if (root.isActive) {
                Network.disconnectWifiNetwork();
            } else if (!root.ap) {
                return;
            } else if (root.isKnown || !root.isSecure) {
                Network.connectToWifiNetwork(root.ap);
            } else {
                root.expandRequested(root.ap);
            }
        }
    }
}
