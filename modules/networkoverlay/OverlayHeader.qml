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
        text: root.title.toUpperCase()
        color: Colors.inkDimmer
        font.family: Theme.font.family.inter_medium
        font.pixelSize: 10
        font.weight: Font.Medium
        font.letterSpacing: 1.8
    }

    Text {
        visible: root.state.length > 0
        text: "· " + root.state
        color: Colors.inkDim
        font.family: Theme.font.family.inter_medium
        font.pixelSize: 10
        font.letterSpacing: 1.0
    }

    Item { Layout.fillWidth: true }
}
