pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.common
import qs.widgets

Rectangle {
    id: root

    required property string query
    required property int currentParentIndex
    required property int index
    required property var item

    property string itemName: item?.name ?? ""
    property string iconName: item?.iconName ?? ""
    property string itemComment: item?.comment ?? ""

    property bool isSelected: mouseArea.containsMouse || index === currentParentIndex

    height: 56
    color: isSelected ? Colors.surfaceContainerLow : "transparent"

    Behavior on color {
        ColorAnimation { duration: 120; easing.type: Easing.InOutQuad }
    }

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: 1
        color: Colors.hair
        visible: root.index > 0
    }

    Rectangle {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: 2
        color: Colors.fgSurface
        visible: root.isSelected
    }

    function highlightContent(content, query) {
        if (!query || query.length === 0)
            return StringUtils.escapeHtml(content);

        const contentLower = content.toLowerCase();
        const queryLower = query.toLowerCase();
        let result = "";
        let lastIndex = 0;
        let qIndex = 0;

        for (let i = 0; i < content.length && qIndex < query.length; i++) {
            if (contentLower[i] === queryLower[qIndex]) {
                if (i > lastIndex)
                    result += StringUtils.escapeHtml(content.slice(lastIndex, i));
                result += `<u style="text-decoration:none;"><font color="#c8c8c8">`
                    + StringUtils.escapeHtml(content[i])
                    + `</font></u>`;
                lastIndex = i + 1;
                qIndex++;
            }
        }
        if (lastIndex < content.length)
            result += StringUtils.escapeHtml(content.slice(lastIndex));

        return result;
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 18
        anchors.rightMargin: 18
        anchors.topMargin: 12
        anchors.bottomMargin: 12
        spacing: 14

        Rectangle {
            Layout.preferredWidth: 28
            Layout.preferredHeight: 28
            Layout.alignment: Qt.AlignVCenter
            radius: 4
            color: root.isSelected ? Colors.surfaceContainerHigh : Colors.surfaceContainerLow
            border.width: 1
            border.color: root.isSelected ? Colors.hairHot : Colors.hair

            Behavior on color        { ColorAnimation { duration: 120; easing.type: Easing.InOutQuad } }
            Behavior on border.color { ColorAnimation { duration: 120; easing.type: Easing.InOutQuad } }

            Image {
                anchors.centerIn: parent
                width: 20
                height: 20
                sourceSize.width: 20
                sourceSize.height: 20
                source: Quickshell.iconPath(root.iconName, "application-x-executable")
                smooth: true
                asynchronous: true
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 3

            Text {
                Layout.fillWidth: true
                text: root.highlightContent(root.itemName, root.query)
                textFormat: Text.StyledText
                font.family: Theme.font.family.inter
                font.pixelSize: 14
                color: Colors.fgSurface
                elide: Text.ElideRight
            }

            Text {
                Layout.fillWidth: true
                text: root.itemComment.toUpperCase()
                font.family: Theme.font.family.inter_medium
                font.pixelSize: 10
                font.letterSpacing: 1.6
                color: Qt.alpha(Colors.fgSurface, 0.42)
                elide: Text.ElideRight
                visible: root.itemComment !== ""
            }
        }

        MaterialSymbol {
            Layout.preferredWidth: 20
            Layout.alignment: Qt.AlignVCenter
            icon: "keyboard_return"
            iconSize: 12
            fontColor: Qt.alpha(Colors.fgSurface, 0.56)
            opacity: root.isSelected ? 1 : 0
            horizontalAlignment: Text.AlignHCenter

            Behavior on opacity {
                NumberAnimation { duration: 120; easing.type: Easing.InOutQuad }
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onEntered: {
            if (root.ListView.view)
                root.ListView.view.currentIndex = root.index;
        }
        onClicked: {
            if (root.item?.execute) {
                GlobalStates.appLauncherOpen = false;
                Qt.callLater(() => root.item.execute());
            }
        }
    }
}
