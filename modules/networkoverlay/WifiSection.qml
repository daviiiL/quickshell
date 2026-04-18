pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.common
import qs.services

ColumnLayout {
    id: root

    Layout.fillWidth: true
    Layout.fillHeight: true
    spacing: 0

    readonly property bool wifiOn: Network.wifiEnabled
    readonly property bool scanning: Network.wifiScanning
    readonly property var networks: Network.friendlyWifiNetworks || []

    function collapse() { list.expandedSsid = ""; }

    onWifiOnChanged: if (!wifiOn) collapse()

    RowLayout {
        Layout.fillWidth: true
        Layout.leftMargin: 16
        Layout.rightMargin: 16
        Layout.topMargin: 14
        Layout.bottomMargin: 10
        spacing: 10

        Text {
            text: "WI-FI"
            color: Colors.inkDimmer
            font.family: Theme.font.family.inter_medium
            font.pixelSize: 11
            font.weight: Font.Medium
            font.letterSpacing: 1.98
        }

        Rectangle {
            visible: root.wifiOn && root.scanning
            Layout.preferredWidth: 5
            Layout.preferredHeight: 5
            radius: 2.5
            color: Colors.barAccent
            SequentialAnimation on opacity {
                running: root.wifiOn && root.scanning
                loops: Animation.Infinite
                NumberAnimation { from: 1;    to: 0.25; duration: 600 }
                NumberAnimation { from: 0.25; to: 1;    duration: 600 }
            }
        }

        Text {
            visible: root.wifiOn && root.scanning
            text: "SCANNING"
            color: Colors.inkDim
            font.family: Theme.font.family.inter_medium
            font.pixelSize: 12
            font.letterSpacing: 1.4
        }

        Item { Layout.fillWidth: true }

        Switch {
            checked: root.wifiOn
            onToggled: {
                Network.toggleWifi();
                if (!Network.wifiEnabled) Network.rescanWifi();
            }
        }
    }

    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: Theme.ui.mainBarHairWidth
        color: Colors.hair
    }

    Item {
        id: body
        Layout.fillWidth: true
        Layout.fillHeight: true

        ColumnLayout {
            id: offState
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            visible: !root.wifiOn
            spacing: 4

            Item { Layout.preferredHeight: 14 }

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "Wi-Fi off"
                color: Colors.inkFaint
                font.family: Theme.font.family.inter_regular
                font.pixelSize: 12
            }

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "TURN ON TO SCAN FOR NETWORKS"
                color: Colors.inkDimmer
                font.family: Theme.font.family.inter_medium
                font.pixelSize: 9
                font.letterSpacing: 1.4
            }
        }

        Item {
            anchors.fill: parent
            visible: root.wifiOn && root.networks.length === 0

            Text {
                anchors.centerIn: parent
                text: root.scanning ? "SCANNING…" : "NO NETWORKS"
                color: Colors.inkFaint
                font.family: Theme.font.family.inter_medium
                font.pixelSize: 10
                font.letterSpacing: 1.4
            }
        }

        ListView {
            id: list
            anchors.fill: parent
            visible: root.wifiOn && root.networks.length > 0
            clip: true
            spacing: 0
            model: root.networks
            boundsBehavior: Flickable.StopAtBounds

            property string expandedSsid: ""

            delegate: WifiListRow {
                required property var modelData
                ap: modelData
                expanded: ListView.view.expandedSsid === (modelData?.ssid ?? "")
                rowWidth: ListView.view.width
                onExpandRequested: (requestedAp) => {
                    ListView.view.expandedSsid = requestedAp.ssid;
                }
                onCollapseRequested: ListView.view.expandedSsid = ""
            }
        }
    }
}
