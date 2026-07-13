pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.common
import qs.widgets

Item {
    id: root

    required property bool dark
    required property string label
    property bool selected: false

    signal clicked()

    readonly property bool hot: hover.containsMouse
    readonly property int animMs: Theme.anim.durations.xs * 0.6

    readonly property var pal: root.dark ? ({
        bg: "#141218", bar: "#0a0a0a", win: "#1d1b20",
        hair: "#272727", ink: "#8f8f8f", accent: "#e3e3e3"
    }) : ({
        bg: "#f5f2f7", bar: "#e4e0e9", win: "#eee9f0",
        hair: "#d6d1dc", ink: "#5b5764", accent: "#1c1820"
    })

    implicitWidth: col.implicitWidth
    implicitHeight: col.implicitHeight

    ColumnLayout {
        id: col
        anchors.centerIn: parent
        spacing: 8

        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            width: 138
            height: 86
            radius: Theme.ui.radius.md
            clip: true

            border.color: root.selected ? Colors.barAccent : (root.hot ? Colors.hairHot : Colors.hair)
            border.width: root.selected ? 2 : Theme.ui.mainBarHairWidth
            scale: root.hot && !root.selected ? 1.03 : 1.0

            Behavior on border.color { ColorAnimation { duration: root.animMs } }
            Behavior on scale { NumberAnimation { duration: root.animMs; easing.type: Easing.OutCubic } }

            gradient: Gradient {
                GradientStop { position: 0.0; color: root.dark ? Qt.lighter(root.pal.bg, 1.35) : Qt.darker(root.pal.bg, 1.04) }
                GradientStop { position: 1.0; color: root.pal.bg }
            }

            Rectangle {
                id: bar
                anchors { top: parent.top; left: parent.left; right: parent.right }
                height: 14
                color: root.pal.bar

                Rectangle {
                    anchors.bottom: parent.bottom
                    width: parent.width
                    height: 1
                    color: root.pal.hair
                }

                Row {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 8
                    spacing: 4
                    Rectangle { width: 13; height: 3; radius: 1.5; color: root.pal.ink; anchors.verticalCenter: parent.verticalCenter }
                    Rectangle { width: 8;  height: 3; radius: 1.5; color: root.pal.ink; anchors.verticalCenter: parent.verticalCenter }
                }

                Row {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    anchors.rightMargin: 8
                    spacing: 4
                    Rectangle { width: 10; height: 3; radius: 1.5; color: root.pal.ink; anchors.verticalCenter: parent.verticalCenter }
                    Rectangle { width: 4;  height: 4; radius: 2;   color: root.pal.accent; anchors.verticalCenter: parent.verticalCenter }
                }
            }

            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: bar.bottom
                anchors.topMargin: 12
                width: 88
                height: 46
                radius: Theme.ui.radius.sm
                color: root.pal.win
                border.color: root.pal.hair
                border.width: 1

                Rectangle { x: 9; y: 8;  width: 24; height: 3; radius: 1.5; color: root.pal.accent; opacity: 0.9 }
                Rectangle { x: 0; y: 17; width: parent.width; height: 1; color: root.pal.hair }
                Rectangle { x: 9; y: 25; width: 52; height: 3; radius: 1.5; color: root.pal.ink; opacity: 0.85 }
                Rectangle { x: 9; y: 33; width: 34; height: 3; radius: 1.5; color: root.pal.ink; opacity: 0.55 }
            }

            Rectangle {
                width: 18
                height: 18
                radius: 9
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.margins: 5
                color: root.pal.accent
                border.color: root.pal.bg
                border.width: 1.5
                visible: root.selected

                MaterialSymbol {
                    anchors.centerIn: parent
                    icon: "check"
                    iconSize: 12
                    fontColor: root.pal.bg
                }
            }
        }

        Text {
            Layout.alignment: Qt.AlignHCenter
            text: root.label
            color: root.selected ? Colors.fgSurface : Colors.inkDim
            font.family: Theme.font.family.inter_medium
            font.pixelSize: 11
            font.weight: root.selected ? Font.Medium : Font.Normal
        }
    }

    MouseArea {
        id: hover
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
