pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.common
import qs.widgets

Rectangle {
    id: root

    required property string iconName
    required property string name
    required property string description
    required property bool active
    property bool last: false

    signal activated()

    implicitHeight: 56
    color: (active || ma.containsMouse) ? Colors.surfaceContainerLow : "transparent"
    Behavior on color { ColorAnimation { duration: 150; easing.type: Easing.InOutQuad } }

    Rectangle {
        visible: root.active
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: 2
        color: Colors.barAccent
    }

    Rectangle {
        visible: !root.last
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: Theme.ui.mainBarHairWidth
        color: Colors.hair
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 14
        anchors.rightMargin: 14
        spacing: 12

        Rectangle {
            Layout.preferredWidth: 28
            Layout.preferredHeight: 28
            radius: Theme.ui.radius.sm
            color: Colors.surfaceContainerLowest
            border.width: Theme.ui.mainBarHairWidth
            border.color: root.active ? Colors.hairHot : Colors.hair
            Behavior on border.color { ColorAnimation { duration: 150 } }

            MaterialSymbol {
                anchors.centerIn: parent
                icon: root.iconName
                iconSize: 14
                fontColor: (root.active || ma.containsMouse) ? Colors.fgSurface : Colors.inkDim
                colorAnimated: true
                fill: root.active ? 1 : 0
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            Text {
                Layout.fillWidth: true
                text: root.name
                color: Colors.fgSurface
                font.family: Theme.font.family.inter_medium
                font.pixelSize: 13
                font.weight: Font.Medium
                font.letterSpacing: 0.2
            }

            Text {
                Layout.fillWidth: true
                text: root.description
                color: Colors.inkDimmer
                font.family: Theme.font.family.inter_regular
                font.pixelSize: 11
                font.letterSpacing: 0.4
                wrapMode: Text.NoWrap
                elide: Text.ElideRight
            }
        }

        Rectangle {
            Layout.preferredWidth: 14
            Layout.preferredHeight: 14
            Layout.alignment: Qt.AlignVCenter
            radius: 7
            color: "transparent"
            border.width: Theme.ui.mainBarHairWidth
            border.color: root.active ? Colors.barAccent : Colors.hairHot
            Behavior on border.color { ColorAnimation { duration: 150 } }

            Rectangle {
                anchors.centerIn: parent
                width: 6
                height: 6
                radius: 3
                color: Colors.barAccent
                opacity: root.active ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: 150 } }
            }
        }
    }

    MouseArea {
        id: ma
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.activated()
    }
}
