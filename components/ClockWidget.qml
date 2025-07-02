import QtQuick
import "../utils/"
import "../styles/"

Item {
    implicitWidth: parent.width
    implicitHeight: 100

    Rectangle {
        anchors.fill: parent
        anchors.margins: 2

        implicitHeight: parent.height
        implicitWidth: parent.width

        // radius: Config.rounding.regular

        color: Colors.values.background

        Text {
            text: DateTime.date
            color: Colors.values.primary
            anchors {
                bottom: hours.top
                horizontalCenter: parent.horizontalCenter
                leftMargin: -10
                bottomMargin: -8
            }
            font.pointSize: Config.font.size.regular
            font.family: Config.font.style.inter
        }

        Text {
            id: hours
            text: DateTime.hrs
            color: Colors.values.secondary
            font.family: Config.font.style.inter_bold
            font.pointSize: Config.font.size.larger
            anchors {
                bottom: minutes.top
                bottomMargin: -10
                horizontalCenter: parent.horizontalCenter
            }
        }

        Text {
            id: minutes
            text: DateTime.mins
            color: Colors.values.primary
            font.family: Config.font.style.inter_bold
            font.pointSize: Config.font.size.larger
            anchors {
                bottom: parent.bottom
                bottomMargin: 3
                horizontalCenter: parent.horizontalCenter
            }
        }
    }
}
