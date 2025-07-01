import QtQuick
import "../utils/"

Item {
    anchors {
        bottom: parent.bottom
    }

    implicitWidth: parent.width
    implicitHeight: 50

    Text {
        anchors.top: parent.top
        text: DateTime.date
    }

    Text {
        anchors.bottom: parent.bottom
        text: DateTime.time
    }
}
