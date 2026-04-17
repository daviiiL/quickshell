pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Pipewire
import qs.common
import qs.services

ColumnLayout {
    id: root

    Layout.fillWidth: true
    spacing: 0

    readonly property real volume: SystemAudio.volume
    readonly property bool muted: SystemAudio.muted
    readonly property string sinkDesc: Pipewire.defaultAudioSink?.description ?? "output"

    SectionHead {
        title: "sound"
        meta: root.sinkDesc
    }

    SliderRow {
        Layout.bottomMargin: 14
        value: root.volume
        from: 0
        to: 1
        valueLabel: Math.round(root.volume * 100) + "%"

        iconSource: "../../assets/icons/volume.svg"

        onMoved: v => {
            if (SystemAudio.ready && Pipewire.defaultAudioSink?.audio) {
                Pipewire.defaultAudioSink.audio.volume = Math.max(0, Math.min(1, v));
            }
        }
    }
}
