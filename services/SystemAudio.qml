pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire

Singleton {
    id: root

    property var tracker: null
    property bool ready: false
    signal initialized
    signal safeVolumeChanged

    Timer {
        interval: 2000
        running: true
        repeat: false
        onTriggered: {
            root.tracker = trackerComponent.createObject(root);
            root.ready = true;
            root.initialized();
        }
    }

    Component {
        id: trackerComponent
        PwObjectTracker {
            objects: [Pipewire.defaultAudioSink, Pipewire.defaultAudioSource]
        }
    }

    readonly property var currentAudioSink: Pipewire.defaultAudioSink?.audio

    readonly property real volume: Pipewire.defaultAudioSink?.audio.volume ?? 0
    readonly property real muted: Pipewire.defaultAudioSink?.audio.muted ?? false
    readonly property bool isOverdrive: {
        return Math.floor(volume * 100) > 100;
    }

    IpcHandler {
        target: "volume"

        function increment(): void {
            if (root.ready && !root.muted)
                Pipewire.defaultAudioSink.audio.volume = Math.min(1, Pipewire.defaultAudioSink.audio.volume + 0.05);
            root.safeVolumeChanged();
        }

        function decrement(): void {
            if (root.ready && !root.muted)
                Pipewire.defaultAudioSink.audio.volume = Math.max(0, Pipewire.defaultAudioSink.audio.volume - 0.05);
            root.safeVolumeChanged();
        }
    }
}
