import QtQuick
import QtQuick.Layouts

import qs.common
import qs.services
import qs.components.topbar

Item {
    id: osdContainer
    Layout.fillHeight: true
    Layout.fillWidth: true

    OsdProgressBar {
        id: progressbar
        property bool showing: false
        visible: opacity > 0
        opacity: showing ? 1 : 0
        scale: showing ? 1 : 0.95

        Behavior on opacity {
            NumberAnimation {
                duration: Theme.anim.durations.sm
                easing.type: Easing.Bezier
                easing.bezierCurve: Theme.anim.curves.emphasized
            }
        }

        Behavior on scale {
            NumberAnimation {
                duration: Theme.anim.durations.sm
                easing.type: Easing.Bezier
                easing.bezierCurve: Theme.anim.curves.emphasized
            }
        }
    }

    Timer {
        id: hideTopProgressBar
        interval: 1000
        running: false

        onTriggered: progressbar.showing = false
    }

    function updateVolumeOsd(): void {
        progressbar.value = SystemAudio.muted ? 0 : SystemAudio.volume;
        progressbar.max = 1;
        progressbar.fgColor = SystemAudio.muted ? Colors.primary_container : (progressbar.value >= 1 ? Colors.error : Colors.primary);
        progressbar.text = SystemAudio.muted ? "Speaker Muted" : "Volume";
        progressbar.showing = true;
        hideTopProgressBar.restart();
    }

    Connections {
        target: SystemAudio.ready ? SystemAudio : null

        function onSafeVolumeChanged() {
            osdContainer.updateVolumeOsd();
        }

        function onMutedChanged() {
            osdContainer.updateVolumeOsd();
        }
    }

    Connections {
        target: Brightness

        function onBrightnessChanged() {
            progressbar.value = Brightness.brightness;
            progressbar.max = 100;
            progressbar.text = "Brightness";
            progressbar.showing = true;
            hideTopProgressBar.restart();
        }
    }
}
