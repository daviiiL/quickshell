pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.common
import qs.services

MainBarButton {
    id: root

    contentGap: 3

    readonly property real level: (typeof Brightness !== "undefined" && Brightness.brightness !== undefined)
                                    ? Brightness.brightness / 100
                                    : 0.72

    readonly property string iconSource: {
        if (root.level < 0.15) return Icons.brightness1;
        if (root.level < 0.55) return Icons.brightness2;
        return Icons.brightness3;
    }

    readonly property string srcId: "brightness"
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
        source: root.iconSource
        sourceSize.width: Theme.ui.mainBarIconSize * 2
        sourceSize.height: Theme.ui.mainBarIconSize * 2
        smooth: true
        opacity: root.hovered ? 1.0 : 0.56
        Behavior on opacity { NumberAnimation { duration: 150; easing.type: Easing.InOutQuad } }
    }

    Text {
        text: Math.round(root.level * 100) + "%"
        color: root.hovered ? Colors.fgSurface : Colors.inkDim
        font.family: Theme.font.family.inter_medium
        font.weight: Font.Medium
        font.pixelSize: 12
        Layout.preferredWidth: 40
        horizontalAlignment: Text.AlignRight
    }
}
