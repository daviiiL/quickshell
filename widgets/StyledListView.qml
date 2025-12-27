import QtQuick
import qs.common

ListView {
    id: root

    property int dragIndex: -1
    property real dragDistance: 0

    function resetDrag() {
        dragIndex = -1;
        dragDistance = 0;
    }

    spacing: 5
    clip: true

    maximumFlickVelocity: 4000
    flickDeceleration: 1500

    add: Transition {
        id: addTransition

        NumberAnimation {
            property: "opacity"
            from: 0
            to: 1
            duration: Theme.anim.durations.sm
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Theme.anim.curves.standard
        }

        NumberAnimation {
            property: "scale"
            from: 0.9
            to: 1
            duration: Theme.anim.durations.sm
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Theme.anim.curves.emphasized
        }
    }

    remove: Transition {
        id: removeTransition

        SequentialAnimation {
            PropertyAction {
                property: "ListView.delayRemove"
                value: true
            }

            ParallelAnimation {
                NumberAnimation {
                    property: "opacity"
                    to: 0
                    duration: Theme.anim.durations.xs
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: Theme.anim.curves.standard
                }

                NumberAnimation {
                    property: "scale"
                    to: 0.9
                    duration: Theme.anim.durations.xs
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: Theme.anim.curves.emphasized
                }

                NumberAnimation {
                    property: "height"
                    to: 0
                    duration: Theme.anim.durations.xs
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: Theme.anim.curves.emphasized
                }
            }

            PropertyAction {
                property: "ListView.delayRemove"
                value: false
            }
        }
    }

    displaced: Transition {
        NumberAnimation {
            properties: "x,y"
            duration: Theme.anim.durations.sm
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Theme.anim.curves.emphasized
        }
    }

    move: Transition {
        NumberAnimation {
            properties: "x,y"
            duration: Theme.anim.durations.sm
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Theme.anim.curves.emphasized
        }
    }
}
