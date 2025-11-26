import "../../common"
import "../../services"
import "../widgets"
import QtQuick

Item {
    id: root

    width: Theme.bar.width
    height: Theme.bar.width

    Rectangle {
        // scale: mouseArea.containsMouse ? 1.08 : 1

        anchors.fill: parent
        anchors.margins: 6
        radius: Theme.rounding.small
        color: mouseArea.containsMouse ? Colors.current.primary_container : "transparent"

        MouseArea {
            id: mouseArea

            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                GlobalStates.sidebarLeftOpen = !GlobalStates.sidebarLeftOpen;
                if (GlobalStates.sidebarLeftOpen)
                    Notifications.markAllRead();

            }
        }

        MaterialSymbol {
            anchors.centerIn: parent
            icon: Notifications.unread > 0 ? "notifications_active" : "notifications"
            iconSize: Theme.font.size.large
            fontColor: (mouseArea.containsMouse || Notifications.unread > 0) ? Colors.current.on_primary_container : Colors.current.secondary_container
            fill: Notifications.unread > 0 ? 1 : 0
            antialiasing: true

            Behavior on fill {
                NumberAnimation {
                    duration: Theme.anim.durations.normal
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: Theme.anim.curves.emphasized
                }

            }

            Behavior on fontColor {
                ColorAnimation {
                    duration: Theme.anim.durations.small
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: Theme.anim.curves.standard
                }

            }

        }

        // Unread badge
        Rectangle {
            visible: Notifications.unread > 0
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.margins: 3
            width: Math.max(16, badgeText.implicitWidth + 6)
            height: 16
            radius: height / 2
            color: Colors.current.error

            Text {
                id: badgeText

                anchors.centerIn: parent
                text: Notifications.unread > 99 ? "99+" : Notifications.unread
                color: Colors.current.on_error
                font.pixelSize: 9
                font.family: Theme.font.style.departureMono_bold
            }

        }

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

    }

}
