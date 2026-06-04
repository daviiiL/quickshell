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
            root.rebuild();
            root.initialized();
        }
    }

    Component {
        id: trackerComponent
        PwObjectTracker {
            objects: [Pipewire.defaultAudioSink, Pipewire.defaultAudioSource]
        }
    }

    // ── Default sink (speakers) ───────────────────────────────────────────
    readonly property var currentAudioSink: Pipewire.defaultAudioSink?.audio

    readonly property real volume: Pipewire.defaultAudioSink?.audio.volume ?? 0
    readonly property bool muted: Pipewire.defaultAudioSink?.audio.muted ?? false
    readonly property bool isOverdrive: Math.floor(volume * 100) > 100

    function setVolume(v: real): void {
        if (!root.ready) return;
        Pipewire.defaultAudioSink.audio.volume = Math.max(0, Math.min(1, v));
    }

    function toggleMuted(): void {
        if (!root.ready) return;
        Pipewire.defaultAudioSink.audio.muted = !Pipewire.defaultAudioSink.audio.muted;
    }

    // ── Default source (microphone) ───────────────────────────────────────
    readonly property var defaultSink: Pipewire.defaultAudioSink
    readonly property var defaultSource: Pipewire.defaultAudioSource

    readonly property real sourceVolume: Pipewire.defaultAudioSource?.audio.volume ?? 0
    readonly property bool sourceMuted: Pipewire.defaultAudioSource?.audio.muted ?? false

    function setSourceVolume(v: real): void {
        if (!root.ready || !Pipewire.defaultAudioSource?.audio) return;
        Pipewire.defaultAudioSource.audio.volume = Math.max(0, Math.min(1, v));
    }

    function toggleSourceMuted(): void {
        if (!root.ready || !Pipewire.defaultAudioSource?.audio) return;
        Pipewire.defaultAudioSource.audio.muted = !Pipewire.defaultAudioSource.audio.muted;
    }

    // ── Device enumeration + per-app streams ──────────────────────────────
    // Stable arrays rebuilt only on node changes, never binding-derived per-read (avoids a binding storm).
    property var outputDeviceOptions: []   // [{ label, value }]
    property var inputDeviceOptions: []    // [{ label, value }]
    property var playbackStreams: []
    property var trackedNodes: []

    function rebuild(): void {
        if (!Pipewire.ready) return;
        const nodes = Pipewire.nodes?.values ?? [];
        const outs = [], ins = [], streams = [];
        for (let i = 0; i < nodes.length; i++) {
            const n = nodes[i];
            if (!n || !n.audio) continue;
            // Classify on the constant isStream/isSink booleans — media.class is empty
            // for untracked source/stream nodes, and a playback stream reports isSink=true.
            if (n.isStream) {
                if (n.isSink) streams.push(n);   // per-app playback stream
            } else if (n.isSink) {
                outs.push(n);                     // output device
            } else {
                ins.push(n);                      // input device
            }
        }
        root.outputDeviceOptions = outs.map(n => ({ label: nodeLabel(n), value: n }));
        root.inputDeviceOptions = ins.map(n => ({ label: nodeLabel(n), value: n }));
        root.playbackStreams = streams;
        root.trackedNodes = outs.concat(ins, streams);
    }

    // Node add/remove surfaces only as the nodes model's valuesChanged.
    Connections {
        target: Pipewire.nodes
        function onValuesChanged(): void { root.rebuild(); }
    }

    Connections {
        target: Pipewire
        function onReadyChanged(): void { root.rebuild(); }
    }

    // One stable list → tracker re-evaluates once per rebuild, keeping `audio` live for shown nodes.
    PwObjectTracker {
        objects: root.trackedNodes
    }

    function setDefaultSink(node: var): void {
        if (node) Pipewire.preferredDefaultAudioSink = node;
    }

    function setDefaultSource(node: var): void {
        if (node) Pipewire.preferredDefaultAudioSource = node;
    }

    function setStreamVolume(node: var, v: real): void {
        if (!root.ready || !node?.audio) return;
        node.audio.volume = Math.max(0, Math.min(1, v));
    }

    // ── Label helpers ─────────────────────────────────────────────────────
    function nodeLabel(node: var): string {
        if (!node) return "—";
        return node.description || node.nickname || node.name || "Unknown";
    }

    function streamAppName(node: var): string {
        const p = node?.properties ?? ({});
        return p["application.name"] || node?.description || node?.name || "App";
    }

    function streamMeta(node: var): string {
        const p = node?.properties ?? ({});
        return p["media.name"] || "";
    }

    function streamIconName(node: var): string {
        const p = node?.properties ?? ({});
        return String(p["application.icon-name"] || p["application.process.binary"] || p["application.name"] || "").toLowerCase();
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
