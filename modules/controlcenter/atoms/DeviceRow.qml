pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.common
import qs.widgets

Rectangle {
    id: root

    required property string icon
    required property string name
    property string meta: ""
    property bool clickable: false
    property bool secure: false
    property string chipText: ""
    property string chipVariant: "default"
    property string trailingText: ""
    property bool showChevron: false
    property bool showSeparator: false

    signal activated()

    readonly property bool hot: mouseArea.containsMouse
    readonly property int animMs: Theme.anim.durations.xs * 0.6

    Layout.fillWidth: true
    implicitHeight: 52

    color: root.clickable && root.hot ? Qt.alpha(Colors.fgSurface, 0.03) : "transparent"
    Behavior on color { ColorAnimation { duration: root.animMs } }

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
                icon: root.icon
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
                text: root.name
                color: Colors.fgSurface
                font.family: Theme.font.family.inter_medium
                font.pixelSize: 12
                font.weight: Font.Medium
                elide: Text.ElideRight
            }

            Text {
                visible: root.meta.length > 0
                Layout.fillWidth: true
                text: root.meta
                color: Colors.inkDimmer
                font.family: Theme.font.family.inter
                font.pixelSize: 10
                font.letterSpacing: 0.2
                elide: Text.ElideRight
            }
        }

        MaterialSymbol {
            visible: root.secure
            Layout.alignment: Qt.AlignVCenter
            icon: "lock"
            iconSize: 12
            fontColor: Colors.inkFaint
        }

        Text {
            visible: root.trailingText.length > 0
            Layout.alignment: Qt.AlignVCenter
            text: root.trailingText
            color: Colors.inkDim
            font.family: Theme.font.family.inter
            font.pixelSize: 11
            font.letterSpacing: 0.2
        }

        Chip {
            visible: root.chipText.length > 0
            Layout.alignment: Qt.AlignVCenter
            text: root.chipText
            variant: root.chipVariant
        }

        MaterialSymbol {
            visible: root.showChevron
            Layout.alignment: Qt.AlignVCenter
            icon: "chevron_right"
            iconSize: 14
            fontColor: Colors.inkFaint
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

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: root.clickable
        cursorShape: root.clickable ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: { if (root.clickable) root.activated() }
    }
}
