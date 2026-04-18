pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.common
import qs.services

MainBarButton {
    id: root

    contentGap: 3

    readonly property bool ready: SystemAudio.ready
    readonly property real volume: ready ? SystemAudio.volume : 0

    readonly property string srcId: "volume"
    active: GlobalStates.rightPanelOpen && GlobalStates.rightPanelSource === srcId

    onActivated: {
        if (GlobalStates.rightPanelOpen && GlobalStates.rightPanelSource === srcId) {
            GlobalStates.rightPanelOpen = false;
            GlobalStates.rightPanelSource = "";
        } else {
            GlobalStates.rightPanelSource = srcId;
            GlobalStates.rightPanelOpen = true;
        }
    }

    Image {
        Layout.preferredWidth:  Theme.ui.mainBarIconSize
        Layout.preferredHeight: Theme.ui.mainBarIconSize
        source: {
            if (!root.ready) return Icons.volume;
            if (root.volume <= 0) return Icons.volumeMuted;
            if (root.volume < 0.34) return Icons.volumeLow;
            if (root.volume < 0.67) return Icons.volumeMedium;
            return Icons.volume;
        }
        sourceSize.width: Theme.ui.mainBarIconSize * 2
        sourceSize.height: Theme.ui.mainBarIconSize * 2
        smooth: true
        opacity: root.hovered ? 1.0 : 0.56
        Behavior on opacity { NumberAnimation { duration: 150; easing.type: Easing.InOutQuad } }
    }

    Text {
        text: root.ready ? (Math.round(root.volume * 100) + "%") : "—"
        color: root.hovered ? Colors.fgSurface : Colors.inkDim
        font.family: Theme.font.family.inter_medium
        font.weight: Font.Medium
        font.pixelSize: 12
        Layout.preferredWidth: 40
        horizontalAlignment: Text.AlignRight
    }
}
