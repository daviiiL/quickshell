pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.common
import qs.widgets

Item {
    id: root

    property string iconSymbol: "info"
    required property string label
    property string sub: ""
    property bool showSeparator: false

    Layout.fillWidth: true
    implicitHeight: root.sub.length > 0 ? 52 : 44

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 14
        anchors.rightMargin: 14
        spacing: 12

        Rectangle {
            Layout.preferredWidth: 26
            Layout.preferredHeight: 26
            Layout.alignment: Qt.AlignVCenter
            radius: 3
            color: Colors.surfaceContainer
            border.color: Colors.hair
            border.width: Theme.ui.mainBarHairWidth

            MaterialSymbol {
                anchors.centerIn: parent
                icon: root.iconSymbol
                iconSize: 13
                fontColor: Colors.inkDim
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 1

            Text {
                Layout.fillWidth: true
                text: root.label
                color: Colors.fgSurface
                font.family: Theme.font.family.inter
                font.pixelSize: Theme.font.size.body
                elide: Text.ElideRight
            }

            Text {
                visible: root.sub.length > 0
                Layout.fillWidth: true
                text: root.sub
                color: Colors.inkDimmer
                font.family: Theme.font.family.inter
                font.pixelSize: Theme.font.size.caption
                elide: Text.ElideRight
            }
        }
    }

    Rectangle {
        visible: root.showSeparator
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: Theme.ui.mainBarHairWidth
        color: Colors.hair
    }
}
