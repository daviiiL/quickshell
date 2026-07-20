pragma ComponentBehavior: Bound

import QtQuick
import qs.common
import qs.services

ListView {
    id: root

    clip: true
    spacing: 14
    model: Gemini.messages
    boundsBehavior: Flickable.StopAtBounds
    leftMargin: 16
    rightMargin: 16
    topMargin: 18
    bottomMargin: 10

    delegate: MessageBubble {
        required property var modelData
        width: ListView.view.width - root.leftMargin - root.rightMargin
        role: modelData.role
        text: modelData.text
        streaming: modelData.streaming || false
    }

    onContentHeightChanged: Qt.callLater(root.positionViewAtEnd)

    Text {
        anchors.centerIn: parent
        visible: root.count === 0
        width: parent.width - 64
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WordWrap
        text: "Ask Gemini anything.\nThis conversation clears when the panel closes."
        color: Colors.inkFaint
        font.family: Theme.font.family.inter
        font.pixelSize: Theme.font.size.sm
        lineHeight: 1.4
    }
}
