pragma ComponentBehavior: Bound

import QtQuick
import qs.common
import qs.services

Row {
    id: root

    readonly property int clockSize: Math.max(50, Math.min(72, Math.round((parent?.width ?? 1920) * 0.035)))

    spacing: 0

    Text {
        text: DateTime.hrs
        color: Colors.fgSurface
        font.family: Theme.font.family.inter_thin
        font.weight: 200
        font.italic: false
        font.pixelSize: root.clockSize
        font.letterSpacing: -Math.round(root.clockSize * 0.035)
        font.features: ({ "tnum": 1 })
    }

    Text {
        text: ":"
        color: Colors.barAccent
        font.family: Theme.font.family.inter_thin
        font.weight: 200
        font.pixelSize: root.clockSize

        SequentialAnimation on opacity {
            loops: Animation.Infinite
            NumberAnimation { from: 1;    to: 0.35; duration: 1000 }
            NumberAnimation { from: 0.35; to: 1;    duration: 1000 }
        }
    }

    Text {
        text: DateTime.mins
        color: Colors.fgSurface
        font.family: Theme.font.family.inter_thin
        font.weight: 200
        font.italic: false
        font.pixelSize: root.clockSize
        font.letterSpacing: -Math.round(root.clockSize * 0.035)
        font.features: ({ "tnum": 1 })
    }
}
