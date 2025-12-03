import QtQuick
import qs.common

ListView {
    id: root
    spacing: 5
    property real removeOvershoot: 20
    property int dragIndex: -1
    property real dragDistance: 0
    property bool popin: true
    property bool animateAppearance: true
    property bool animateMovement: false

    function resetDrag() {
        root.dragIndex = -1;
        root.dragDistance = 0;
    }

    maximumFlickVelocity: 3500
    boundsBehavior: Flickable.DragOverBounds

    add: Transition {
        NumberAnimation {
            properties: popin ? "opacity,scale" : "opacity"
            from: 0
            to: 1
            duration: Theme.anim.durations.normal
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Theme.anim.curves.emphasized
        }
    }

    addDisplaced: Transition {
        NumberAnimation {
            property: "y"
            duration: Theme.anim.durations.normal
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Theme.anim.curves.emphasized
        }
        NumberAnimation {
            properties: popin ? "opacity,scale" : "opacity"
            to: 1
            duration: Theme.anim.durations.normal
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Theme.anim.curves.emphasized
        }
    }

    displaced: Transition {
        enabled: root.animateMovement
        NumberAnimation {
            property: "y"
            duration: Theme.anim.durations.normal
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Theme.anim.curves.emphasized
        }
        NumberAnimation {
            properties: "opacity,scale"
            to: 1
            duration: Theme.anim.durations.normal
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Theme.anim.curves.emphasized
        }
    }

    move: Transition {
        enabled: root.animateMovement
        NumberAnimation {
            property: "y"
            duration: Theme.anim.durations.normal
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Theme.anim.curves.emphasized
        }
        NumberAnimation {
            properties: "opacity,scale"
            to: 1
            duration: Theme.anim.durations.normal
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Theme.anim.curves.emphasized
        }
    }

    moveDisplaced: Transition {
        enabled: root.animateMovement
        NumberAnimation {
            property: "y"
            duration: Theme.anim.durations.normal
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Theme.anim.curves.emphasized
        }
        NumberAnimation {
            properties: "opacity,scale"
            to: 1
            duration: Theme.anim.durations.normal
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Theme.anim.curves.emphasized
        }
    }

    remove: Transition {
        enabled: animateAppearance
        NumberAnimation {
            property: "x"
            to: root.width + root.removeOvershoot
            duration: Theme.anim.durations.normal
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Theme.anim.curves.emphasized
        }
        NumberAnimation {
            property: "opacity"
            to: 0
            duration: Theme.anim.durations.normal
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Theme.anim.curves.emphasized
        }
    }

    removeDisplaced: Transition {
        enabled: animateAppearance
        NumberAnimation {
            property: "y"
            duration: Theme.anim.durations.normal
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Theme.anim.curves.emphasized
        }
        NumberAnimation {
            properties: "opacity,scale"
            to: 1
            duration: Theme.anim.durations.normal
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Theme.anim.curves.emphasized
        }
    }
}
