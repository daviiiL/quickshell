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
    property bool expandUpward: false

    signal entered
    signal exited

    width: collapsedWidth
    color: Colors.current.primary_container
    radius: Theme.rounding.regular

    // Transform to handle upward expansion
    transform: Translate {
        id: verticalTranslate
        y: 0

        Behavior on y {
            NumberAnimation {
                duration: container.animationDuration
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Theme.anim.curves.standardAccel
            }
        }
    }

    MouseArea {
        id: mouseArea

        anchors.fill: parent
        hoverEnabled: true
        onEntered: {
            container.width = container.expandedWidth;
            if (container.verticalExpansion) {
                // Calculate available space below and above
                let globalY = container.mapToItem(null, 0, 0).y;
                let windowHeight = container.Window.window ? container.Window.window.height : 0;
                let spaceBelow = windowHeight - globalY - container.collapsedHeight;
                let spaceAbove = globalY;

                // Determine expansion direction based on available space
                container.expandUpward = (spaceBelow < container.expandedHeight && spaceAbove >= container.expandedHeight);

                container.height = container.expandedHeight;

                // Apply translation for upward expansion
                if (container.expandUpward) {
                    verticalTranslate.y = -(container.expandedHeight - container.collapsedHeight);
                }
            }

            container.entered();
        }
        onExited: {
            container.width = container.collapsedWidth;
            if (container.verticalExpansion) {
                container.height = container.collapsedHeight;
                verticalTranslate.y = 0;
            }

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
