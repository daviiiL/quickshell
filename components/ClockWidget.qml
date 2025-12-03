import QtQuick
import qs.common

Item {
    implicitWidth: parent.width
    implicitHeight: 100

    Rectangle {
        anchors.fill: parent
        anchors.margins: 2

        implicitHeight: parent.height
        implicitWidth: parent.width

        color: Colors.current.background

        Text {
            text: DateTime.date
            color: Colors.current.primary
            anchors {
                bottom: hours.top
                horizontalCenter: parent.horizontalCenter
                leftMargin: -10
                bottomMargin: -8
            }
            font.pointSize: Theme.font.size.regular
            font.family: Theme.font.style.departureMono
        }

        Text {
            id: hours
            text: DateTime.hrs
            color: Colors.current.secondary
            font.family: Theme.font.style.departureMono
            font.styleName: "Bold"
            font.pointSize: Theme.font.size.larger
            anchors {
                bottom: minutes.top
                bottomMargin: -10
                horizontalCenter: parent.horizontalCenter
            }
        }

        Text {
            id: minutes
            text: DateTime.mins
            color: Colors.current.primary
            font.family: Theme.font.style.departureMono
            font.pointSize: Theme.font.size.larger
            anchors {
                bottom: parent.bottom
                bottomMargin: 3
                horizontalCenter: parent.horizontalCenter
            }
        }
    }
}
