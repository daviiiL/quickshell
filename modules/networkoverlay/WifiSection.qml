pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.common
import qs.services

ColumnLayout {
    id: root

    Layout.fillWidth: true
    spacing: 0

    readonly property bool wifiOn: Network.wifiEnabled
    readonly property bool scanning: Network.wifiScanning
    readonly property var networks: Network.friendlyWifiNetworks || []

    RowLayout {
        Layout.fillWidth: true
        Layout.leftMargin: 12
        Layout.rightMargin: 12
        Layout.topMargin: 10
        Layout.bottomMargin: 8
        spacing: 8

        Text {
            text: "WI-FI"
            color: Colors.inkDimmer
            font.family: Theme.font.family.inter_medium
            font.pixelSize: 10
            font.weight: Font.Medium
            font.letterSpacing: 1.8
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
            font.pixelSize: 10
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
        id: bodyWrap
        Layout.fillWidth: true
        Layout.preferredHeight: root.wifiOn ? Math.min(listCol.implicitHeight, 280) : offState.implicitHeight
        clip: true
        Behavior on Layout.preferredHeight {
            NumberAnimation {
                duration: Theme.anim.durations.sm
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Theme.anim.curves.emphasized
            }
        }

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

            Item { Layout.preferredHeight: 14 }
        }

        Flickable {
            anchors.fill: parent
            visible: root.wifiOn
            contentHeight: listCol.implicitHeight
            clip: true
            boundsBehavior: Flickable.StopAtBounds

            ColumnLayout {
                id: listCol
                width: parent.width
                spacing: 0

                Repeater {
                    model: root.networks

                    WifiRow {
                        required property var modelData
                        Layout.fillWidth: true
                        ap: modelData
                    }
                }

                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 18
                    visible: root.networks.length === 0

                    Text {
                        anchors.centerIn: parent
                        text: root.scanning ? "SCANNING…" : "NO NETWORKS"
                        color: Colors.inkFaint
                        font.family: Theme.font.family.inter_medium
                        font.pixelSize: 10
                        font.letterSpacing: 1.4
                    }
                }
            }
        }
    }
}
