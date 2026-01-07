pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.common
import qs.widgets

Rectangle {
    id: root

    required property string query

    property var item: modelData

    property string itemType: item?.type ?? "App"
    property string itemName: item?.name ?? ""
    property string iconName: item?.iconName ?? ""
    property string itemVerb: item?.verb ?? "Launch"

    height: 60
    radius: Theme.ui.radius.md

    property bool isHovered: mouseArea.containsMouse
    color: isHovered ? Qt.alpha(Colors.primary_container, 0.3) : "transparent"

    Behavior on color {
        ColorAnimation {
            duration: 150
        }
    }

    function highlightContent(content, query) {
        if (!query || query.length === 0)
            return StringUtils.escapeHtml(content);

        let contentLower = content.toLowerCase();
        let queryLower = query.toLowerCase();
        let result = "";
        let lastIndex = 0;
        let qIndex = 0;

        for (let i = 0; i < content.length && qIndex < query.length; i++) {
            if (contentLower[i] === queryLower[qIndex]) {
                if (i > lastIndex)
                    result += StringUtils.escapeHtml(content.slice(lastIndex, i));
                result += `<u><font color="${Colors.primary}">` + StringUtils.escapeHtml(content[i]) + `</font></u>`;
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
        anchors.margins: Theme.ui.padding.sm
        spacing: Theme.ui.padding.sm

        // Icon
        Image {
            Layout.preferredWidth: 32
            Layout.preferredHeight: 32
            source: Quickshell.iconPath(root.iconName, "application-x-executable")
            sourceSize: Qt.size(32, 32)
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            StyledText {
                Layout.fillWidth: true
                text: root.highlightContent(root.itemName, root.query)
                textFormat: Text.StyledText
                font.pixelSize: Theme.font.size.md
                color: Colors.on_surface
                elide: Text.ElideRight
            }

            StyledText {
                Layout.fillWidth: true
                text: root.modelData?.comment ?? ""
                font.pixelSize: Theme.font.size.xs
                color: Colors.on_surface_variant
                elide: Text.ElideRight
                visible: text !== ""
            }
        }

        // Action text (on hover)
        StyledText {
            text: root.itemVerb
            font.pixelSize: Theme.font.size.sm
            color: Colors.on_primary_container
            visible: root.isHovered
        }
    }

    MouseArea {
        id: mouseArea

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onClicked: {
            if (root.modelData?.execute) {
                GlobalStates.appLauncherOpen = false;
                Qt.callLater(() => root.modelData.execute());
            }
        }
    }

    Keys.onPressed: event => {
        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            if (root.modelData?.execute) {
                GlobalStates.appLauncherOpen = false;
                Qt.callLater(() => root.modelData.execute());
            }
            event.accepted = true;
        }
    }
}
