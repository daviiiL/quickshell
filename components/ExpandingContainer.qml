import QtQuick
import Quickshell.Widgets
import "../utils/"

ClippingRectangle {
    id: container

    property bool expanded: width !== collapsedWidth
    property real collapsedWidth: 100
    property real expandedWidth: 400
    property int animationDuration: 300
    property alias hoverEnabled: mouseArea.hoverEnabled
    property alias mouseArea: mouseArea

    signal entered
    signal exited

    width: collapsedWidth
    color: Colors.values.secondary_container
    radius: Theme.rounding.regular

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true

        onEntered: {
            container.width = container.expandedWidth;
            container.entered();
        }

        onExited: {
            container.width = container.collapsedWidth;
            container.exited();
        }
    }

    Behavior on width {
        NumberAnimation {
            duration: container.animationDuration
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Theme.anim.curves.standardAccel
        }
    }
}
