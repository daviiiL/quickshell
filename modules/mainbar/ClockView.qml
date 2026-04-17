pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.common
import qs.services

RowLayout {
    id: root
    spacing: 10

    RowLayout {
        spacing: 0

        Text {
            text: DateTime.hrs
            font.family: Theme.font.family.inter_medium
            font.pixelSize: 16
            font.weight: Font.Medium
            color: Colors.fgSurface
            font.letterSpacing: 0.4
        }

        Text {
            id: sep
            text: ":"
            font.family: Theme.font.family.inter_medium
            font.pixelSize: 16
            font.weight: Font.Medium
            color: Colors.barAccent

            SequentialAnimation on opacity {
                loops: Animation.Infinite
                NumberAnimation { from: 1;    to: 0.35; duration: 1000 }
                NumberAnimation { from: 0.35; to: 1;    duration: 1000 }
            }
        }

        Text {
            text: DateTime.mins
            font.family: Theme.font.family.inter_medium
            font.pixelSize: 16
            font.weight: Font.Medium
            color: Colors.fgSurface
            font.letterSpacing: 0.4
        }
    }

    Rectangle {
        Layout.fillHeight: false
        Layout.preferredHeight: 14
        Layout.preferredWidth: 1
        color: Colors.hair
    }

    Text {
        text: DateTime.date.toUpperCase()
        font.family: Theme.font.family.inter_medium
        font.pixelSize: 13
        color: Colors.inkDim
        font.letterSpacing: 1.0
        Layout.preferredWidth: 62
        horizontalAlignment: Text.AlignLeft
    }
}
