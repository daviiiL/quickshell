import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Notifications
import "../../common"
import "../widgets"

/**
 * Button for notification actions (close, copy, custom actions)
 */
Rectangle {
    id: button
    property string buttonText: ""
    property string urgency: "normal"
    property Component contentItem: null

    signal clicked()

    Layout.fillWidth: true
    implicitHeight: 34
    radius: Theme.rounding.small
    scale: mouseArea.pressed ? 0.96 : (mouseArea.containsMouse ? 1.02 : 1.0)

    color: (urgency == NotificationUrgency.Critical) ?
        (mouseArea.containsMouse ? Colors.current.error_container : Colors.current.error) :
        (mouseArea.containsMouse ? Colors.current.surface_container_high : Colors.current.surface_container)

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

    Item {
        id: defaultContent
        anchors.centerIn: parent
        visible: button.contentItem === null
        implicitWidth: buttonTextItem.implicitWidth
        implicitHeight: buttonTextItem.implicitHeight

        StyledText {
            id: buttonTextItem
            anchors.centerIn: parent
            width: Math.min(implicitWidth, button.width - 16)
            text: buttonText
            font.pixelSize: Theme.font.size.small
            color: (urgency == NotificationUrgency.Critical) ? Colors.current.on_error : Colors.current.on_surface
            elide: Text.ElideRight
            horizontalAlignment: Text.AlignHCenter
        }
    }

    // Allow custom content item
    Loader {
        anchors.centerIn: parent
        sourceComponent: button.contentItem
    }
}
