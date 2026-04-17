pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.common
import qs.services

MainBarButton {
    id: root

    readonly property real level: (typeof Brightness !== "undefined" && Brightness.brightness !== undefined)
                                    ? Brightness.brightness / 100
                                    : 0.72

    readonly property string iconKey: {
        if (root.level < 0.15) return "brightness-1";
        if (root.level < 0.55) return "brightness-2";
        return "brightness-3";
    }

    onActivated: {}

    Image {
        Layout.preferredWidth:  Theme.ui.mainBarIconSize
        Layout.preferredHeight: Theme.ui.mainBarIconSize
        source: "../../assets/icons/" + root.iconKey + ".svg"
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
        font.pixelSize: 15
        Layout.preferredWidth: 40
        horizontalAlignment: Text.AlignRight
    }
}
