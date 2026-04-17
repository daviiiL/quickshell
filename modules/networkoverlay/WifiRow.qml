pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.common
import qs.services
import qs.widgets

Rectangle {
    id: root

    required property var ap

    readonly property int strength: root.ap?.strength ?? 0
    readonly property bool isSecure: root.ap?.isSecure ?? false
    readonly property bool isActive: root.ap?.active ?? false
    readonly property bool isWeak: root.strength < 35
    readonly property string ssid: root.ap?.ssid ?? ""
    readonly property string security: root.ap?.security ?? ""

    readonly property string wifiIcon: {
        if (root.strength > 83) return "signal_wifi_4_bar";
        if (root.strength > 67) return "network_wifi";
        if (root.strength > 50) return "network_wifi_3_bar";
        if (root.strength > 33) return "network_wifi_2_bar";
        if (root.strength > 17) return "network_wifi_1_bar";
        return "signal_wifi_0_bar";
    }

    implicitHeight: row.implicitHeight + 18
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
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        anchors.topMargin: 9
        anchors.bottomMargin: 9
        spacing: 10

        MaterialSymbol {
            Layout.preferredWidth: 20
            Layout.alignment: Qt.AlignVCenter
            icon: root.wifiIcon
            iconSize: 16
            fill: root.isActive ? 1 : 0
            fontColor: root.isWeak ? Colors.inkDim : Colors.fgSurface
            opacity: root.isWeak ? 0.5 : (root.isActive ? 1.0 : 0.78)
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            Text {
                Layout.fillWidth: true
                text: root.ssid
                color: root.isWeak ? Colors.inkDim : Colors.fgSurface
                font.family: Theme.font.family.inter_medium
                font.pixelSize: 13
                font.weight: root.isActive ? Font.Medium : Font.Normal
                elide: Text.ElideRight
            }

            Text {
                text: root.isActive
                        ? "CONNECTED"
                        : (root.security.length > 0 ? root.security.toUpperCase() : "OPEN")
                color: root.isActive ? Colors.live : Colors.inkDimmer
                font.family: Theme.font.family.inter_medium
                font.pixelSize: 10
                font.letterSpacing: 1.4
            }
        }

        MaterialSymbol {
            visible: root.isSecure
            Layout.alignment: Qt.AlignVCenter
            icon: "lock"
            iconSize: 11
            fontColor: Colors.inkDimmer
        }

        Text {
            Layout.preferredWidth: 34
            Layout.alignment: Qt.AlignVCenter
            horizontalAlignment: Text.AlignRight
            text: root.strength + "%"
            color: Colors.inkDim
            font.family: Theme.font.family.inter_regular
            font.pixelSize: 11
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
            } else if (root.ap) {
                Network.connectToWifiNetwork(root.ap);
            }
        }
    }
}
