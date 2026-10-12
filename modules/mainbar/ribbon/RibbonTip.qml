pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import qs.common

PopupWindow {
    id: root

    property Item target: null
    property string title: ""
    property string sub: ""

    anchor.item: root.target
    anchor.rect: Qt.rect(0, -Theme.ui.mainBarRibbonTipLift, root.target ? root.target.width : 1, 1)
    anchor.edges: Edges.Top
    anchor.gravity: Edges.Top

    visible: root.target !== null && root.title !== ""
    color: "transparent"
    implicitWidth: card.implicitWidth
    implicitHeight: card.implicitHeight

    Rectangle {
        id: card
        implicitWidth: body.implicitWidth + 2 * Theme.ui.mainBarRibbonTipPadX
        implicitHeight: body.implicitHeight + 2 * Theme.ui.mainBarRibbonTipPadY
        color: Colors.surfaceContainerLow
        border.width: Theme.ui.mainBarHairWidth
        border.color: Colors.hair
        radius: Theme.ui.mainBarRibbonTipRadius

        Column {
            id: body
            anchors.centerIn: parent
            spacing: Theme.ui.mainBarRibbonTipSpacing
            Text {
                text: root.title
                font.family: Theme.font.family.inter_medium
                font.weight: Font.Medium
                font.pixelSize: Theme.font.size.caption
                color: Colors.fgSurface
            }
            Text {
                text: root.sub
                font.family: Theme.font.family.inter
                font.pixelSize: Theme.font.size.caption
                color: Colors.inkDim
            }
        }
    }
}
