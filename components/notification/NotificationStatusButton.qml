import QtQuick
import QtQuick.Layouts
import qs.common
import qs.components.widgets

Rectangle {
    id: button
    property string buttonIcon: ""
    property string buttonText: ""
    property bool toggled: false

    Layout.fillWidth: true
    Layout.preferredHeight: 36

    radius: Theme.rounding.small
    color: toggled ? Colors.current.primary : (mouseArea.containsMouse ? Colors.current.primary_container : "transparent")
    scale: mouseArea.pressed ? 0.95 : (mouseArea.containsMouse ? 1.02 : 1.0)

    signal clicked

    Behavior on color {
        ColorAnimation {
            duration: Theme.anim.durations.small
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Theme.anim.curves.standard
        }
    }

    Behavior on scale {
        NumberAnimation {
            duration: Theme.anim.durations.small
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
            iconSize: Theme.font.size.large
            fontColor: button.toggled ? Colors.current.on_primary : (mouseArea.containsMouse ? Colors.current.on_primary_container : Colors.current.secondary_container)
        }

        StyledText {
            visible: buttonText !== ""
            text: buttonText
            font.pixelSize: Theme.font.size.regular
            color: button.toggled ? Colors.current.on_primary : Colors.current.on_surface
        }
    }
}
