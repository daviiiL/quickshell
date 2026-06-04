pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.common
import qs.services
import qs.modules.controlcenter.atoms

Flickable {
    id: root

    Component.onCompleted: console.log("[ControlCenter.sound] loaded")
    Component.onDestruction: console.log("[ControlCenter.sound] unloaded")

    contentWidth: width
    contentHeight: column.implicitHeight + column.anchors.topMargin + column.anchors.bottomMargin
    boundsBehavior: Flickable.StopAtBounds
    clip: true

    ColumnLayout {
        id: column
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.leftMargin: 26
        anchors.rightMargin: 26
        anchors.topMargin: 22
        anchors.bottomMargin: 24
        spacing: 0

        Text {
            text: "Sound"
            color: Colors.fgSurface
            font.family: Theme.font.family.inter_medium
            font.pixelSize: 19
            font.weight: Font.Medium
        }

        Text {
            Layout.topMargin: 4
            Layout.bottomMargin: 18
            text: "OUTPUT · INPUT · APP MIX"
            color: Colors.inkDimmer
            font.family: Theme.font.family.inter_medium
            font.pixelSize: 10
            font.letterSpacing: 2.4
        }

        GroupLabel { text: "OUTPUT" }

        GroupBox {
            DevicePicker {
                title: "Device"
                currentLabel: SystemAudio.nodeLabel(SystemAudio.defaultSink)
                options: SystemAudio.outputDeviceOptions
                currentValue: SystemAudio.defaultSink
                showSeparator: true
                onSelected: v => SystemAudio.setDefaultSink(v)
            }

            SliderRow {
                iconSymbol: "volume_up"
                label: "Volume"
                value: SystemAudio.ready ? SystemAudio.volume : 0
                available: SystemAudio.ready
                showSeparator: true
                onMoved: v => SystemAudio.setVolume(v)
            }

            ToggleRow {
                label: "Mute"
                checked: SystemAudio.muted
                available: SystemAudio.ready
                onToggled: SystemAudio.toggleMuted()
            }
        }

        GroupLabel { text: "INPUT" }

        GroupBox {
            DevicePicker {
                title: "Device"
                currentLabel: SystemAudio.nodeLabel(SystemAudio.defaultSource)
                options: SystemAudio.inputDeviceOptions
                currentValue: SystemAudio.defaultSource
                showSeparator: true
                onSelected: v => SystemAudio.setDefaultSource(v)
            }

            SliderRow {
                iconSymbol: "mic"
                label: "Input level"
                value: SystemAudio.ready ? SystemAudio.sourceVolume : 0
                available: SystemAudio.ready && !!SystemAudio.defaultSource
                onMoved: v => SystemAudio.setSourceVolume(v)
            }
        }

        GroupLabel { text: "PER-APP VOLUME" }

        GroupBox {
            Repeater {
                id: streamRepeater
                model: SystemAudio.playbackStreams

                delegate: SliderRow {
                    id: streamRow
                    required property var modelData
                    required property int index

                    readonly property string iconName: SystemAudio.streamIconName(modelData)
                    iconImage: iconName ? Quickshell.iconPath(iconName, "") : ""
                    iconSymbol: "graphic_eq"
                    label: SystemAudio.streamAppName(modelData)
                    sub: SystemAudio.streamMeta(modelData)
                    trackWidth: 200
                    value: modelData?.audio?.volume ?? 0
                    showSeparator: index < streamRepeater.count - 1
                    onMoved: v => SystemAudio.setStreamVolume(modelData, v)
                }
            }

            DeviceRow {
                visible: streamRepeater.count === 0
                icon: "music_off"
                name: "No apps playing audio"
                meta: "App volume sliders appear here while audio is playing"
            }
        }
    }
}
