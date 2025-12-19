import QtQuick
import QtQuick.Layouts
import qs.common
import qs.components.widgets

ColumnLayout {
    id: root

    property string icon: ""
    property color iconColor: Colors.current.primary
    property color iconColorPressed: Colors.current.primary_container
    property int iconSize: 24
    property int padding: 8

    signal clicked

    Rectangle {
        Layout.alignment: Qt.AlignTop
        implicitWidth: symbol.implicitWidth + (root.padding * 2)
        implicitHeight: symbol.implicitHeight + (root.padding * 2)
        radius: 4
        // color: mouseArea.pressed ? Qt.rgba(1, 1, 1, 0.2) : mouseArea.containsMouse ? Qt.rgba(1, 1, 1, 0.1) : "transparent"

        color: "transparent"

        Behavior on color {
            ColorAnimation {
                duration: 150
            }
        }

        MaterialSymbol {
            id: symbol
            anchors.centerIn: parent
            icon: root.icon
            iconSize: root.iconSize
            fontColor: mouseArea.containsMouse ? root.iconColorPressed : root.iconColor

            Behavior on fontColor {
                ColorAnimation {
                    duration: 150
                }
            }
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.clicked()
        }
    }
}
