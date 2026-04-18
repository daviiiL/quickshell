pragma ComponentBehavior: Bound

import QtQuick
import qs.common
import qs.services

Item {
    id: root

    property string state: "HIDDEN"
    property string channel: ""

    readonly property int hideMs: 1500
    readonly property int exitMs: Theme.anim.durations.xs + 50

    property bool _seenVolume: false
    property bool _seenBrightness: false

    function trigger(ch) {
        if (ch === "volume" && !root._seenVolume) {
            root._seenVolume = true;
            return;
        }
        if (ch === "brightness" && !root._seenBrightness) {
            root._seenBrightness = true;
            return;
        }

        if (root.state === "HIDDEN"
            && GlobalStates.rightPanelOpen
            && GlobalStates.rightPanelSource === ch) {
            return;
        }

        root.channel = ch;
        root.state = "SHOWN";
        _hideTimer.restart();
    }

    Timer {
        id: _hideTimer
        interval: root.hideMs
        onTriggered: if (root.state === "SHOWN") root.state = "HIDING"
    }

    Timer {
        id: _exitTimer
        interval: root.exitMs
        running: root.state === "HIDING"
        onTriggered: if (root.state === "HIDING") root.state = "HIDDEN"
    }

    Connections {
        target: SystemAudio
        enabled: SystemAudio.ready
        function onVolumeChanged() { root.trigger("volume"); }
        function onMutedChanged()  { root.trigger("volume"); }
    }

    Connections {
        target: Brightness
        enabled: Brightness._pathsReady
        function onBrightnessChanged() { root.trigger("brightness"); }
    }
}
