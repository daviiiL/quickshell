pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.common

Item {
    id: root

    property string role: "model"
    property string text: ""
    property bool streaming: false
    readonly property bool mine: role === "user"
    readonly property bool isError: role === "error"

    implicitHeight: bubble.implicitHeight

    Rectangle {
        id: bubble

        anchors.left: root.mine ? undefined : parent.left
        anchors.right: root.mine ? parent.right : undefined
        width: Math.min(Math.max(label.implicitWidth, 64) + 30, parent.width * 0.9)
        implicitHeight: col.implicitHeight + 18

        radius: Theme.ui.radius.lg
        topLeftRadius: root.mine ? Theme.ui.radius.lg : Theme.ui.radius.sm
        topRightRadius: root.mine ? Theme.ui.radius.sm : Theme.ui.radius.lg
        color: root.mine ? Colors.surfaceContainerHigh : Colors.surfaceContainerLow
        border.width: root.mine ? 0 : Theme.ui.mainBarHairWidth
        border.color: Colors.hair

        Rectangle {
            visible: !root.mine
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            width: 2
            height: parent.height - 16
            radius: 1
            color: root.isError ? Colors.error : Colors.primary
            opacity: 0.5
        }

        ColumnLayout {
            id: col
            anchors.fill: parent
            anchors.topMargin: 9
            anchors.bottomMargin: 9
            anchors.leftMargin: root.mine ? 12 : 14
            anchors.rightMargin: 12
            spacing: 3

            Text {
                text: root.mine ? "you" : root.isError ? "error" : "gemini"
                color: root.isError ? Colors.error : Colors.inkDimmer
                font.family: Theme.font.family.inter
                font.pixelSize: Theme.font.size.xs
                font.letterSpacing: 1.6
                font.capitalization: Font.AllUppercase
            }

            Text {
                id: label
                Layout.fillWidth: true
                text: root.text + (root.streaming ? " ▍" : "")
                textFormat: (root.mine || root.isError) ? Text.PlainText : Text.MarkdownText
                color: Colors.fgSurface
                linkColor: Colors.primary
                onLinkActivated: link => Qt.openUrlExternally(link)
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                font.family: Theme.font.family.inter
                font.pixelSize: Theme.font.size.md
                lineHeight: 1.35
            }
        }
    }
}
