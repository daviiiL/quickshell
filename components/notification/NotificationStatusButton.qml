import QtQuick
import QtQuick.Layouts
import qs.common
import qs.widgets

Rectangle {
    id: button
    property string buttonIcon: ""
    property string buttonText: ""
    property bool toggled: false

    Layout.fillWidth: true
    Layout.preferredHeight: 36

    radius: Theme.ui.radius.md
    color: toggled ? Colors.primary : (mouseArea.containsMouse ? Colors.primary_container : "transparent")
    scale: mouseArea.pressed ? 0.95 : (mouseArea.containsMouse ? 1.02 : 1.0)

    signal clicked

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
        onClicked: button.clicked()
    }

    RowLayout {
        anchors.centerIn: parent
        spacing: 5

        MaterialSymbol {
            visible: buttonIcon !== ""
            icon: buttonIcon
            iconSize: Theme.font.size.lg
            fontColor: button.toggled ? Colors.on_primary : (mouseArea.containsMouse ? Colors.on_primary_container : Colors.secondary_container)
        }

        StyledText {
            visible: buttonText !== ""
            text: buttonText
            font.pixelSize: Theme.font.size.md
            color: button.toggled ? Colors.on_primary : Colors.on_surface
        }
    }
}
