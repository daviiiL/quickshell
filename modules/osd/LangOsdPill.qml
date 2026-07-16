pragma ComponentBehavior: Bound

import QtQuick
import qs.common
import qs.services

Rectangle {
    id: root

    readonly property bool cjkFace: Fcitx.isCjk

    implicitWidth: 220
    implicitHeight: 56
    color: Colors.panelBg
    radius: 4
    border.width: 1
    border.color: Colors.hair

    Rectangle {
        z: -1
        anchors.fill: parent
        anchors.topMargin: 6
        radius: parent.radius
        color: "#000000"
        opacity: 0.55
    }

    // streak draws itself across the top edge on every switch
    Rectangle {
        id: streak
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.leftMargin: root.radius
        height: 1
        width: 140
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: Qt.alpha(Colors.barAccent, 0.55) }
            GradientStop { position: 1.0; color: "transparent" }
        }
    }

    NumberAnimation {
        id: sweep
        target: streak
        property: "width"
        from: 0
        to: 140
        duration: 420
        easing.type: Easing.BezierSpline
        easing.bezierCurve: Theme.anim.curves.standardDecel
    }

    NumberAnimation {
        id: trackIn
        target: nameText
        property: "font.letterSpacing"
        from: 0.4
        to: root.cjkFace ? 1.7 : 1.68
        duration: 420
        easing.type: Easing.BezierSpline
        easing.bezierCurve: Theme.anim.curves.standardDecel
    }

    Connections {
        target: Fcitx
        function onSwitched() {
            sweep.restart();
            trackIn.restart();
        }
    }

    Component.onCompleted: {
        sweep.restart();
        trackIn.restart();
    }

    // -- code tile (fixed 34x34 at x=16) -----------------------------------
    Rectangle {
        x: 16
        anchors.verticalCenter: parent.verticalCenter
        width: 34
        height: 34
        radius: 3
        color: Colors.surfaceContainerLowest
        border.width: 1
        border.color: Colors.hair

        Text {
            anchors.centerIn: parent
            text: Fcitx.currentCode
            color: Colors.fgSurface
            font.family: root.cjkFace ? "LXGW WenKai" : Theme.font.family.inter_medium
            font.pixelSize: root.cjkFace ? Theme.font.size.xl : Theme.font.size.sm
            font.weight: root.cjkFace ? Font.Normal : Font.Medium
            font.letterSpacing: root.cjkFace ? 0 : 0.7
        }
    }

    // -- name (fixed x=64) ---------------------------------------------------
    Text {
        id: nameText
        x: 64
        anchors.verticalCenter: parent.verticalCenter
        text: Fcitx.currentDisplay
        color: Colors.fgSurface
        font.family: Theme.font.family.inter_medium
        font.pixelSize: root.cjkFace ? Theme.font.size.md : Theme.font.size.sm
        font.weight: Font.Medium
        font.letterSpacing: root.cjkFace ? 1.7 : 1.68
    }

    // -- group index (fixed right column) -------------------------------------
    Text {
        x: 204 - width
        anchors.verticalCenter: parent.verticalCenter
        visible: Fcitx.groupTotal > 0
        text: Fcitx.groupIndex + "/" + Fcitx.groupTotal
        color: Colors.inkDimmer
        font.family: Theme.font.family.inter_medium
        font.pixelSize: Theme.font.size.sm
        font.letterSpacing: 0.7
    }
}
