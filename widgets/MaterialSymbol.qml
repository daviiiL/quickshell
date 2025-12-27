pragma ComponentBehavior: Bound

import QtQuick
import qs.common

Text {
    id: root
    property real fill: 0
    property int grad: 0
    property int iconSize
    required property string icon
    required property color fontColor

    property bool animated: false
    property bool colorAnimated: false
    property string animateProp: "scale"
    property real animateFrom: 0
    property real animateTo: 1
    property int animateDuration: Theme.anim.durations.md

    font.family: "Material Symbols Rounded"
    font.hintingPreference: Font.PreferFullHinting
    font.variableAxes: {
        "FILL": root.fill,
        "opsz": root.fontInfo.pixelSize,
        "GRAD": root.grad,
        "wght": root.fontInfo.weight
    }
    renderType: Text.NativeRendering
    text: root.icon
    font.pointSize: root.iconSize || 20
    color: fontColor

    Behavior on color {
        enabled: root.colorAnimated

        ColorAnimation {
            duration: Theme.anim.durations.md
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Theme.anim.curves.standard
        }
    }

    Behavior on text {
        enabled: root.animated

        SequentialAnimation {
            Anim {
                to: root.animateFrom
                easing.bezierCurve: Theme.anim.curves.standardAccel
            }
            PropertyAction {}
            Anim {
                to: root.animateTo
                easing.bezierCurve: Theme.anim.curves.standardDecel
            }
        }
    }

    component Anim: NumberAnimation {
        target: root
        property: root.animateProp
        duration: root.animateDuration / 2
        easing.type: Easing.BezierSpline
    }
}
