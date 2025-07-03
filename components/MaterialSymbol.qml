import QtQuick
import "../utils/"

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
    property int animateDuration: Theme.anim.durations.normal

    font.family: "Material Symbols Rounded"
    font.hintingPreference: Font.PreferFullHinting
    // see https://m3.material.io/styles/typography/editorial-treatments#e9bac36c-e322-415f-a182-264a2f2b70f0
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
            duration: Theme.anim.durations.normal
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
