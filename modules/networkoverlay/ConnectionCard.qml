pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.common
import qs.widgets

Rectangle {
    id: root

    property string iconSymbol: "lan"
    property string title: ""
    property string meta: ""
    property bool live: true

    implicitHeight: row.implicitHeight + 24
    color: ma.containsMouse ? Colors.surfaceContainerLow : "transparent"
    Behavior on color { ColorAnimation { duration: Theme.anim.durations.xs } }

    RowLayout {
        id: row
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        anchors.topMargin: 12
        anchors.bottomMargin: 12
        spacing: 10

        MaterialSymbol {
            Layout.preferredWidth: 20
            Layout.alignment: Qt.AlignVCenter
            icon: root.iconSymbol
            iconSize: 16
            fontColor: Colors.fgSurface
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            Text {
                Layout.fillWidth: true
                text: root.title
                color: Colors.fgSurface
                font.family: Theme.font.family.inter_medium
                font.pixelSize: 13
                font.weight: Font.Medium
                font.letterSpacing: 0.2
                elide: Text.ElideRight
            }

            RowLayout {
                spacing: 6

                Rectangle {
                    visible: root.live
                    Layout.preferredWidth: 4
                    Layout.preferredHeight: 4
                    radius: 2
                    color: Colors.live
                }

                Text {
                    text: root.meta
                    color: Colors.inkDimmer
                    font.family: Theme.font.family.inter_medium
                    font.pixelSize: 10
                    font.letterSpacing: 1.4
                }
            }
        }

        MaterialSymbol {
            visible: ma.containsMouse
            Layout.alignment: Qt.AlignVCenter
            icon: "more_horiz"
            iconSize: 14
            fontColor: Colors.inkDim
        }
    }

    MouseArea {
        id: ma
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.NoButton
    }
}
