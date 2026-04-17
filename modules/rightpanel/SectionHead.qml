pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.common

RowLayout {
    id: root

    property string title: ""
    property string meta: ""

    Layout.fillWidth: true
    Layout.leftMargin: 14
    Layout.rightMargin: 14
    Layout.topMargin: 10
    Layout.bottomMargin: 8
    spacing: 8

    Text {
        text: root.title.toUpperCase()
        font.family: Theme.font.family.inter_medium
        font.pixelSize: 10
        font.weight: Font.Medium
        font.letterSpacing: 1.8
        color: Colors.inkDimmer
    }

    Item { Layout.fillWidth: true }

    Text {
        visible: root.meta.length > 0
        text: root.meta
        font.family: Theme.font.family.inter_regular
        font.pixelSize: 11
        font.letterSpacing: 0.4
        color: Colors.inkDim
    }
}
