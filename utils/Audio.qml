pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

Singleton {
    id: root

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }

    function initializeDefaultSink() {
    }

    readonly property var defaultSinkAudio: Pipewire.defaultAudioSink?.audio || null
    readonly property real volume: Pipewire.defaultAudioSink?.audio.volume || 0
    readonly property bool isOverdrive: volume > 1
    readonly property bool muted: Pipewire.defaultAudioSink?.audio.muted
}
