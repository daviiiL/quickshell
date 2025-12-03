pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

Singleton {
    id: root

    property var tracker: null

    Timer {
        // delays initialization by 10 secs to give audio sink time to initialize when first booting up
        interval: 10000 // 10 seconds
        running: true
        repeat: false
        onTriggered: {
            root.tracker = trackerComponent.createObject(root);
        }
    }

    Component {
        id: trackerComponent
        PwObjectTracker {
            objects: [Pipewire.defaultAudioSink, Pipewire.defaultAudioSource]
        }
    }

    readonly property var defaultSinkAudio: Pipewire.defaultAudioSink?.audio || null
    readonly property real volume: Pipewire.defaultAudioSink?.audio.volume || 0
    readonly property bool isOverdrive: {
        return Math.floor(volume * 100) > 100;
    }
    readonly property bool muted: Pipewire.defaultAudioSink?.audio.muted || false
}
