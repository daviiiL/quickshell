// THIS FILE IS ADAPTED FRON END-4's dotfile: https://github.com/end-4/dots-hyprland

import QtQuick
import QtQuick.Shapes

Item {
    id: root

    enum CornerEnum {
        TopLeft,
        TopRight,
        BottomLeft,
        BottomRight
    }
    property var corner: ScreenCorner.CornerEnum.TopLeft

    property int size: 25
    property color color: "#000000"

    implicitWidth: size
    implicitHeight: size

    readonly property bool isTopLeft: corner === ScreenCorner.CornerEnum.TopLeft
    readonly property bool isBottomLeft: corner === ScreenCorner.CornerEnum.BottomLeft
    readonly property bool isTopRight: corner === ScreenCorner.CornerEnum.TopRight
    readonly property bool isBottomRight: corner === ScreenCorner.CornerEnum.BottomRight
    readonly property bool isTop: isTopLeft || isTopRight
    readonly property bool isBottom: isBottomLeft || isBottomRight
    readonly property bool isLeft: isTopLeft || isBottomLeft
    readonly property bool isRight: isTopRight || isBottomRight

    Shape {
        id: shape
        width: root.size
        height: root.size
        anchors {
            top: root.isTop ? parent.top : undefined
            bottom: root.isBottom ? parent.bottom : undefined
            left: root.isLeft ? parent.left : undefined
            right: root.isRight ? parent.right : undefined
        }
        layer.enabled: true
        layer.smooth: true
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            id: shapePath
            strokeWidth: 0
            fillColor: root.color
            pathHints: ShapePath.PathSolid & ShapePath.PathNonIntersecting

            startX: switch (root.corner) {
            case ScreenCorner.CornerEnum.TopLeft:
            case ScreenCorner.CornerEnum.BottomLeft:
                return 0;
            case ScreenCorner.CornerEnum.TopRight:
            case ScreenCorner.CornerEnum.BottomRight:
                return root.size;
            }
            startY: switch (root.corner) {
            case ScreenCorner.CornerEnum.TopLeft:
            case ScreenCorner.CornerEnum.TopRight:
                return 0;
            case ScreenCorner.CornerEnum.BottomLeft:
            case ScreenCorner.CornerEnum.BottomRight:
                return root.size;
            }

            PathAngleArc {
                moveToStart: false
                centerX: root.size - shapePath.startX
                centerY: root.size - shapePath.startY
                radiusX: root.size
                radiusY: root.size
                startAngle: switch (root.corner) {
                case ScreenCorner.CornerEnum.TopLeft:
                    return 180;
                case ScreenCorner.CornerEnum.TopRight:
                    return -90;
                case ScreenCorner.CornerEnum.BottomLeft:
                    return 90;
                case ScreenCorner.CornerEnum.BottomRight:
                    return 0;
                }
                sweepAngle: 90
            }

            PathLine {
                x: shapePath.startX
                y: shapePath.startY
            }
        }
    }
}
