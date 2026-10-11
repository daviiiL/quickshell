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
        text: root.title
        font.family: Theme.font.family.inter_medium
        font.pixelSize: Theme.font.size.caption
        font.weight: Font.Medium
        font.letterSpacing: Theme.font.tracking.none
        color: Colors.inkDimmer
    }

    Text {
        Layout.fillWidth: true
        visible: root.meta.length > 0
        text: root.meta
        horizontalAlignment: Text.AlignRight
        elide: Text.ElideRight
        font.family: Theme.font.family.inter_regular
        font.pixelSize: Theme.font.size.body
        color: Colors.inkDim
    }
}
