pragma ComponentBehavior: Bound

import QtQuick
import qs.common
import qs.services

Rectangle {
    id: root

    readonly property bool announcing: Fcitx.announcing
    readonly property int padX: Theme.ui.mainBarButtonPadX
    readonly property int labelLead: 8

    // collapsed width is fixed to the wider code so EN <-> 拼 never shifts neighbors
    readonly property real codeSlot: Math.max(enMetrics.advanceWidth, cjkMetrics.advanceWidth)
    readonly property real collapsedW: codeSlot + 2 * padX
    readonly property real expandedW: collapsedW + labelLead + labelText.implicitWidth

    visible: Fcitx.ready
    implicitHeight: Theme.ui.mainBarButtonHeight
    implicitWidth: announcing ? expandedW : collapsedW
    radius: Theme.ui.mainBarButtonRadius
    clip: true

    color: announcing ? Colors.surfaceContainerLow : "transparent"
    border.width: Theme.ui.mainBarHairWidth
    border.color: announcing ? Colors.hair : "transparent"

    Behavior on implicitWidth {
        NumberAnimation {
            duration: Theme.anim.durations.xs + 80
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Theme.anim.curves.standardDecel
        }
    }
    Behavior on color        { ColorAnimation { duration: 150; easing.type: Easing.InOutQuad } }
    Behavior on border.color { ColorAnimation { duration: 150; easing.type: Easing.InOutQuad } }

    TextMetrics {
        id: enMetrics
        font.family: Theme.font.family.inter_medium
        font.pixelSize: Theme.font.size.sm
        font.weight: Font.Medium
        font.letterSpacing: 0.7
        text: "EN"
    }
    TextMetrics {
        id: cjkMetrics
        font.pixelSize: Theme.font.size.md
        text: "拼"
    }

    // accent streak across the top edge while announcing
    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.leftMargin: root.radius
        anchors.rightMargin: root.radius
        height: Theme.ui.mainBarHairWidth
        opacity: root.announcing ? 1 : 0
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: Qt.alpha(Colors.barAccent, 0.55) }
            GradientStop { position: 1.0; color: "transparent" }
        }
        Behavior on opacity { NumberAnimation { duration: 200 } }
    }

    Text {
        id: codeText
        x: root.padX + (root.codeSlot - width) / 2
        anchors.verticalCenter: parent.verticalCenter
        text: Fcitx.currentCode
        color: root.announcing ? Colors.fgSurface : Colors.inkDim
        font.family: Fcitx.isCjk ? Theme.font.family.inter : Theme.font.family.inter_medium
        font.pixelSize: Fcitx.isCjk ? Theme.font.size.md : Theme.font.size.sm
        font.weight: Fcitx.isCjk ? Font.Normal : Font.Medium
        font.letterSpacing: Fcitx.isCjk ? 0 : 0.7
        Behavior on color { ColorAnimation { duration: 150 } }
    }

    Text {
        id: labelText
        x: root.padX + root.codeSlot + root.labelLead
        anchors.verticalCenter: parent.verticalCenter
        text: Fcitx.currentDisplay
        color: Fcitx.isCjk ? Colors.inkDim : Colors.inkDimmer
        font.family: Theme.font.family.inter_medium
        font.pixelSize: Fcitx.isCjk ? Theme.font.size.sm : Theme.font.size.xs
        font.weight: Font.Medium
        font.letterSpacing: Fcitx.isCjk ? 1.2 : 1.6
        opacity: root.announcing ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 200 } }
    }
}
