import QtQuick
import Quickshell.Widgets
import qs.common

ClippingRectangle {
    id: container

    property bool expanded: width !== collapsedWidth
    property real collapsedWidth: 100
    property real expandedWidth: 400
    property bool verticalExpansion: false
    property real collapsedHeight: 50
    property real expandedHeight: 300
    property int animationDuration: 300
    property alias hoverEnabled: mouseArea.hoverEnabled
    property alias mouseArea: mouseArea

    signal entered
    signal exited

    width: collapsedWidth
    color: Colors.current.primary_container
    radius: Theme.rounding.regular

    MouseArea {
        id: mouseArea

        anchors.fill: parent
        hoverEnabled: true
        onEntered: {
            container.width = container.expandedWidth;
            if (container.verticalExpansion)
                container.height = container.expandedHeight;

            container.entered();
        }
        onExited: {
            container.width = container.collapsedWidth;
            if (container.verticalExpansion)
                container.height = container.collapsedHeight;

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

    Behavior on height {
        NumberAnimation {
            duration: container.animationDuration
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Theme.anim.curves.standardAccel
        }
    }
}
