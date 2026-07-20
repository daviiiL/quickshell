pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.common

Item {
    id: root

    required property string name
    required property var rows
    property bool lastSection: false

    implicitHeight: column.implicitHeight

    ColumnLayout {
        id: column
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 0

        // Section head — mirrors WifiSection.qml: RowLayout + margins + fillWidth spacer
        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: 16
            Layout.rightMargin: 16
            Layout.topMargin: 10
            Layout.bottomMargin: 8
            spacing: 12

            Text {
                Layout.alignment: Qt.AlignVCenter
                text: root.name.toUpperCase()
                color: Colors.inkDimmer
                font.family: Theme.font.family.inter
                font.pixelSize: Theme.font.size.xs
                font.weight: Font.Medium
                font.letterSpacing: 1.8
            }

            Item { Layout.fillWidth: true }

            Text {
                Layout.alignment: Qt.AlignVCenter
                text: root.rows.length
                color: Colors.inkDim
                font.family: Theme.font.family.inter
                font.pixelSize: Theme.font.size.xs
                font.letterSpacing: 0.1
            }
        }

        Repeater {
            model: root.rows
            delegate: RowItem {
                required property var modelData
                required property int index
                Layout.fillWidth: true
                firstRow: index === 0
                keys: modelData.keys
                label: modelData.label
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: Colors.hair
            visible: !root.lastSection
        }
    }
}
