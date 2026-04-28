pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.common
import qs.widgets

Item {
    id: root

    required property var entry
    required property bool selected
    required property bool firstRow
    required property string query
    required property bool keyboardActive

    readonly property bool isMono: {
        const t = root.entry?.type ?? "txt";
        return t === "cmd" || t === "warn" || t === "err";
    }

    signal picked()
    signal hovered()

    implicitWidth: parent ? parent.width : 0
    implicitHeight: 22 + 2 * 11

    Rectangle {
        id: rowBg
        anchors.fill: parent
        color: root.selected || rowMouse.containsMouse
            ? Colors.surfaceContainerLow
            : "transparent"

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

    Rectangle {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: 2
        color: Colors.barAccent
        visible: root.selected
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 18
        anchors.rightMargin: 18
        anchors.topMargin: 11
        anchors.bottomMargin: 11
        spacing: 12

        MaterialSymbol {
            Layout.preferredWidth: 24
            Layout.alignment: Qt.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            icon: {
                switch (root.entry?.type) {
                case "img":  return "image";
                case "url":  return "link";
                case "cmd":  return "terminal";
                case "warn": return "warning";
                case "err":  return "error";
                default:     return "notes";
                }
            }
            iconSize: 16
            fontColor: root.selected ? Colors.fgSurface : Colors.inkDim
            colorAnimated: true
        }

        Text {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            text: StringUtils.highlightSubstring(root.entry?.preview ?? "", root.query, Colors.warning)
            textFormat: Text.StyledText
            color: Colors.fgSurface
            elide: Text.ElideRight
            wrapMode: Text.NoWrap
            font.family: root.isMono ? "JetBrains Mono" : Theme.font.family.inter
            font.pixelSize: root.isMono ? 12 : 13
            font.letterSpacing: 0.13
        }

        Text {
            Layout.alignment: Qt.AlignVCenter
            text: root.entry ? "#" + root.entry.id : ""
            color: root.selected ? Colors.inkDim : Colors.inkFaint
            font.family: Theme.font.family.inter
            font.pixelSize: 11
            font.letterSpacing: 0.44
        }
    }

    MouseArea {
        id: rowMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onEntered: if (!root.keyboardActive) root.hovered()
        onClicked: root.picked()
    }
}
