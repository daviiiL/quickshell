import QtQuick
import QtQuick.Layouts
import qs.common
import qs.widgets

/**
 * Expand button for notification groups
 */
Rectangle {
    id: root
    required property int count
    required property bool expanded
    property real fontSize: Theme.font.size.sm
    property real iconSize: Theme.font.size.md

    signal clicked
    signal altAction

    implicitHeight: fontSize + 8
    implicitWidth: Math.max(contentRow.implicitWidth + 10, 30)
    radius: height / 2
    scale: mouseArea.pressed ? 0.94 : (mouseArea.containsMouse ? 1.04 : 1.0)

    color: mouseArea.containsMouse ? Qt.rgba(Colors.primary.r, Colors.primary.g, Colors.primary.b, 0.16) : Qt.rgba(Colors.primary.r, Colors.primary.g, Colors.primary.b, 0.08)

    Behavior on color {
        ColorAnimation {
            duration: Theme.anim.durations.xs
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Theme.anim.curves.standard
        }
    }

    Behavior on scale {
        NumberAnimation {
            duration: Theme.anim.durations.xs
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Theme.anim.curves.emphasized
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: mouse => {
            if (mouse.button === Qt.RightButton)
                root.altAction();
            else
                root.clicked();
        }
    }

    RowLayout {
        id: contentRow
        anchors.centerIn: parent
        spacing: 3

        StyledText {
            visible: root.count > 1
            text: root.count
            font.pixelSize: root.fontSize
            color: Colors.on_primary_container
        }

        MaterialSymbol {
            icon: "keyboard_arrow_down"
            iconSize: root.iconSize
            fontColor: Colors.on_primary_container
            rotation: expanded ? 180 : 0

            Behavior on rotation {
                NumberAnimation {
                    duration: Theme.anim.durations.xs
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: Theme.anim.curves.emphasized
                }
            }
        }
    }
}
