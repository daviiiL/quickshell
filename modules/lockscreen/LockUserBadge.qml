pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.common

RowLayout {
    id: root
    spacing: 10

    readonly property string username: (Quickshell.env("USER") ?? "").toUpperCase()
    readonly property string initials: {
        if (username.length === 0) return "?";
        if (username.length === 1) return username;
        return username.slice(0, 2);
    }

    Rectangle {
        id: avatar
        width: 32
        height: 32
        radius: 3
        border.width: 1
        border.color: Colors.hair

        gradient: Gradient {
            orientation: Gradient.Vertical
            GradientStop { position: 0.0; color: Colors.surfaceContainerHigh }
            GradientStop { position: 1.0; color: Colors.surfaceContainerLow }
        }

        Text {
            anchors.centerIn: parent
            text: root.initials
            font.pixelSize: 13
            font.letterSpacing: 0.5
            font.family: Theme.font.family.inter_regular
            color: Colors.barAccent
        }
    }

    Text {
        text: root.username
        font.pixelSize: 14
        font.weight: Font.Medium
        font.letterSpacing: 2.5
        font.family: Theme.font.family.inter_medium
        color: Colors.fgSurface
    }
}
