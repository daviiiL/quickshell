pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.common

Text {
    Layout.fillWidth: true
    Layout.topMargin: 18
    Layout.bottomMargin: 8
    Layout.leftMargin: 4

    color: Colors.inkDimmer
    font.family: Theme.font.family.inter_medium
    font.pixelSize: Theme.font.size.caption
    font.weight: Font.Medium
    font.letterSpacing: Theme.font.tracking.none
}
