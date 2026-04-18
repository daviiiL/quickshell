pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.common
import qs.services

Rectangle {
    id: root

    required property string channel

    readonly property real volume: SystemAudio.ready ? SystemAudio.volume : 0
    readonly property bool muted: SystemAudio.ready ? SystemAudio.muted : false
    readonly property real brightness: Brightness._pathsReady ? (Brightness.brightness / 100) : 0

    readonly property bool isVolume: channel === "volume"
    readonly property real rawValue: isVolume ? volume : brightness
    readonly property real barValue: Math.min(1, rawValue)
    readonly property bool isOverdrive: isVolume && !muted && rawValue > 1.0
    readonly property bool isMuted: isVolume && muted

    readonly property string iconSource: {
        if (isVolume) {
            if (muted || rawValue <= 0) return "../../assets/icons/volume-muted.svg";
            if (rawValue < 0.34) return "../../assets/icons/volume-low.svg";
            if (rawValue < 0.67) return "../../assets/icons/volume-medium.svg";
            return "../../assets/icons/volume.svg";
        }
        if (rawValue < 0.15) return "../../assets/icons/brightness-1.svg";
        if (rawValue < 0.55) return "../../assets/icons/brightness-2.svg";
        return "../../assets/icons/brightness-3.svg";
    }

    readonly property string percentLabel: Math.round(rawValue * 100) + "%"

    implicitWidth: 220
    implicitHeight: 36
    color: Colors.panelBg
    radius: 4
    border.width: 1
    border.color: Colors.hair

    Rectangle {
        z: -1
        anchors.fill: parent
        anchors.topMargin: 6
        radius: parent.radius
        color: "#000000"
        opacity: 0.55
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        spacing: 10

        Image {
            Layout.preferredWidth: 16
            Layout.preferredHeight: 16
            Layout.alignment: Qt.AlignVCenter
            source: root.iconSource
            sourceSize.width: 32
            sourceSize.height: 32
            smooth: true
            opacity: root.isMuted ? 0.55 : 0.9
        }

        Item {
            id: track
            Layout.fillWidth: true
            Layout.preferredHeight: 2
            Layout.alignment: Qt.AlignVCenter

            Rectangle {
                anchors.fill: parent
                radius: 1
                color: Colors.hair
            }

            Rectangle {
                visible: !root.isOverdrive
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: parent.width * root.barValue
                radius: 1
                color: Colors.barAccent
                opacity: root.isMuted ? 0.35 : 1.0
            }

            Rectangle {
                id: overdriveBar
                visible: root.isOverdrive
                anchors.fill: parent
                radius: 1

                readonly property real splitPos: 1 / root.rawValue

                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0.0;                 color: Colors.barAccent }
                    GradientStop { position: overdriveBar.splitPos; color: Colors.barAccent }
                    GradientStop { position: overdriveBar.splitPos; color: Colors.warning }
                    GradientStop { position: 1.0;                 color: Colors.warning }
                }
            }
        }

        Text {
            Layout.preferredWidth: 40
            Layout.alignment: Qt.AlignVCenter
            horizontalAlignment: Text.AlignRight
            text: root.percentLabel
            font.family: Theme.font.family.inter_medium
            font.pixelSize: 12
            font.weight: Font.Medium
            font.letterSpacing: 0.2
            color: {
                if (root.isMuted) return Colors.inkDimmer;
                if (root.isOverdrive) return Colors.warning;
                return Colors.inkDim;
            }
            opacity: root.isMuted ? 0.55 : 1.0
        }
    }
}
