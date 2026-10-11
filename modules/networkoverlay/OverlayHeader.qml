pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.common

RowLayout {
    id: root

    property string title: "network"
    property string state: ""

    Layout.fillWidth: true
    Layout.leftMargin: 12
    Layout.rightMargin: 12
    Layout.topMargin: 10
    Layout.bottomMargin: 8
    spacing: 6

    Text {
        text: root.title
        color: Colors.inkDimmer
        font.family: Theme.font.family.inter_medium
        font.pixelSize: Theme.font.size.caption
        font.weight: Font.Medium
        font.letterSpacing: Theme.font.tracking.none
    }

    Text {
        Layout.fillWidth: true
        visible: root.state.length > 0
        text: root.state
        horizontalAlignment: Text.AlignRight
        color: Colors.inkDim
        font.family: Theme.font.family.inter_medium
        font.pixelSize: Theme.font.size.caption
        font.letterSpacing: Theme.font.tracking.none
    }
}
