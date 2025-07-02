pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Widgets

Singleton {
    id: root

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }

    readonly property var defaultSinkAudio: Pipewire.defaultAudioSink?.audio
    readonly property real volume: Pipewire.defaultAudioSink?.audio.volume
    readonly property bool isOverdrive: volume < 1
}
