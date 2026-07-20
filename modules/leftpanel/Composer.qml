pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.common
import qs.services
import qs.widgets

Rectangle {
    id: root

    readonly property bool canSend: Gemini.state === "idle" || Gemini.state === "thinking" || Gemini.state === "responding"

    implicitHeight: content.implicitHeight + 26
    color: Colors.surfaceContainerLowest

    Rectangle {
        anchors.top: parent.top
        width: parent.width
        height: Theme.ui.mainBarHairWidth
        color: Colors.hair
    }

    Connections {
        target: GlobalStates
        function onLeftPanelOpenChanged(): void {
            if (!GlobalStates.leftPanelOpen)
                field.text = "";
        }
    }

    function submit(): void {
        if (!root.canSend)
            return;
        const txt = field.text.trim();
        if (txt.length === 0)
            return;
        field.text = "";
        Gemini.send(txt);
    }

    RowLayout {
        id: content
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.leftMargin: 13
        anchors.rightMargin: 13
        anchors.bottomMargin: 13
        spacing: 10

        StyledTextArea {
            id: field
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignBottom
            enabled: root.canSend
            maxHeight: 120
            placeholderText: root.canSend ? "Message Gemini…" : (Gemini.state === "needs-key" ? "Set your API key in AI settings" : "Connection unavailable")
            onSubmitted: root.submit()
        }

        Rectangle {
            Layout.preferredWidth: 38
            Layout.preferredHeight: 38
            Layout.alignment: Qt.AlignBottom
            radius: Theme.ui.radius.md
            color: Colors.surfaceContainer
            border.width: Theme.ui.mainBarHairWidth
            border.color: sendArea.containsMouse && root.canSend ? Colors.primary : Colors.hair
            opacity: root.canSend ? 1 : 0.4

            MaterialSymbol {
                anchors.centerIn: parent
                icon: "arrow_forward"
                iconSize: 18
                fontColor: sendArea.containsMouse && root.canSend ? Colors.primary : Colors.inkDim
            }

            MouseArea {
                id: sendArea
                anchors.fill: parent
                hoverEnabled: true
                enabled: root.canSend
                cursorShape: Qt.PointingHandCursor
                onClicked: root.submit()
            }
        }
    }
}
