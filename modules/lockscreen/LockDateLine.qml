pragma ComponentBehavior: Bound

import QtQuick
import qs.common
import qs.services

Row {
    id: root
    spacing: 0

    readonly property int textSize: Math.max(25, Math.min(36, Math.round((parent?.width ?? 1920) * 0.0175)))
    readonly property var parts: DateTime.longDate.split(" ")
    readonly property string weekday: parts[0] ?? ""
    readonly property string dayMonth: (parts[1] ?? "") + " " + (parts[2] ?? "")
    readonly property string week: "W" + DateTime.isoWeek

    Text {
        text: root.weekday + " "
        font.pixelSize: root.textSize
        font.letterSpacing: 2.5
        font.family: Theme.font.family.inter_regular
        color: Colors.inkDimmer
    }
    Text {
        text: root.dayMonth
        font.pixelSize: root.textSize
        font.letterSpacing: 2.5
        font.weight: Font.Medium
        font.family: Theme.font.family.inter_medium
        color: Colors.fgSurface
    }
    Text {
        text: "  "
        font.pixelSize: root.textSize
    }
    Text {
        text: "·"
        font.pixelSize: root.textSize
        color: Colors.hairHot
    }
    Text {
        text: "  " + root.week
        font.pixelSize: root.textSize
        font.letterSpacing: 2.5
        font.family: Theme.font.family.inter_regular
        color: Colors.inkDimmer
    }
}
