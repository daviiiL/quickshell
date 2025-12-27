import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Notifications
import qs.common
import qs.widgets

Rectangle {
    id: button
    property string buttonText: ""
    property string urgency: "normal"
    property Component contentItem: null

    signal clicked

    Layout.fillWidth: true
    implicitHeight: 34
    radius: Theme.ui.radius.md
    scale: mouseArea.pressed ? 0.96 : (mouseArea.containsMouse ? 1.02 : 1.0)

    color: (urgency == NotificationUrgency.Critical) ? (mouseArea.containsMouse ? Colors.error_container : Colors.error) : (mouseArea.containsMouse ? Qt.rgba(Colors.primary.r, Colors.primary.g, Colors.primary.b, 0.16) : Qt.rgba(Colors.primary.r, Colors.primary.g, Colors.primary.b, 0.08))

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
            font.pixelSize: Theme.font.size.sm
            color: (urgency == NotificationUrgency.Critical) ? Colors.on_error : Colors.on_primary_container
            elide: Text.ElideRight
            horizontalAlignment: Text.AlignHCenter
        }
    }

    Loader {
        anchors.centerIn: parent
        sourceComponent: button.contentItem
    }
}
