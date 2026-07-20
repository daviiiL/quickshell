pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.common

Item {
    id: root

    required property var keys
    required property string label
    required property bool firstRow

    implicitHeight: content.implicitHeight + 20

    Rectangle {
        id: rowBg
        anchors.fill: parent
        color: rowMouse.containsMouse ? Colors.surfaceContainerLow : "transparent"

        Behavior on color {
            ColorAnimation { duration: 150; easing.type: Easing.InOutQuad }
        }
    }

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: 1
        color: Colors.hair
        visible: !root.firstRow
    }

    RowLayout {
        id: content
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: 16
        anchors.rightMargin: 16
        spacing: 14

        Row {
            Layout.alignment: Qt.AlignVCenter
            spacing: 4

            Repeater {
                model: root.keys
                delegate: Rectangle {
                    required property string modelData

                    height: 18
                    width: Math.max(18, chipText.implicitWidth + 10)
                    border.width: 1
                    border.color: rowMouse.containsMouse ? Colors.hairHot : Colors.hair
                    radius: Theme.ui.radius.sm
                    color: "transparent"

                    Text {
                        id: chipText
                        anchors.centerIn: parent
                        text: parent.modelData
                        color: Colors.inkDim
                        font.family: Theme.font.family.inter
                        font.pixelSize: Theme.font.size.xs
                        font.letterSpacing: 0.1
                    }
                }
            }
        }

        Text {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            text: root.label
            color: Colors.fgSurface
            elide: Text.ElideRight
            horizontalAlignment: Text.AlignRight
            font.family: Theme.font.family.inter
            font.pixelSize: Theme.font.size.md
            font.letterSpacing: 0.01
            wrapMode: Text.NoWrap
        }
    }

    MouseArea {
        id: rowMouse
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.NoButton
    }
}
