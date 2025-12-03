import QtQuick
import QtQuick.Shapes
import qs.common

Item {
    id: root

    property real sides: 12
    property int implicitSize: 100
    property real amplitude: implicitSize / 50
    property int renderPoints: 360
    property color color: Colors.current.primary_container

    implicitWidth: implicitSize
    implicitHeight: implicitSize

    property real shapeRotation: 0

    Behavior on sides {
        NumberAnimation {
            duration: Theme.anim.durations.normal
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Theme.anim.curves.emphasized
        }
    }

    Shape {
        id: shape
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            id: shapePath
            strokeWidth: 0
            fillColor: root.color

            PathPolyline {
                property var pointsList: {
                    var points = [];
                    var cx = shape.width / 2;
                    var cy = shape.height / 2;
                    var steps = root.renderPoints;
                    var radius = root.implicitSize / 2 - root.amplitude;
                    for (var i = 0; i <= steps; i++) {
                        var angle = (i / steps) * 2 * Math.PI;
                        var rotatedAngle = angle * root.sides + Math.PI / 2;
                        var wave = Math.sin(rotatedAngle) * root.amplitude;
                        var x = Math.cos(angle) * (radius + wave) + cx;
                        var y = Math.sin(angle) * (radius + wave) + cy;
                        points.push(Qt.point(x, y));
                    }
                    return points;
                }

                path: pointsList
            }
        }
    }
}
