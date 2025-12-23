pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import qs.common
import qs.components.widgets
import qs.components.todo

Rectangle {
    id: root
    required property var listModel
    required property string status
    required property string emptyMessage
    required property string emptyIcon

    color: "transparent"

    Item {
        anchors.fill: parent
        visible: root.listModel.length === 0

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 5
            MaterialSymbol {
                Layout.alignment: Qt.AlignHCenter
                iconSize: 55
                fontColor: Colors.current.outline
                icon: root.emptyIcon
            }
            StyledText {
                Layout.alignment: Qt.AlignHCenter
                font.pixelSize: Theme.font.size.large
                color: Colors.current.outline
                text: root.emptyMessage
            }
        }
    }

    ScrollView {
        anchors.fill: parent
        clip: true
        visible: root.listModel.length > 0
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        ColumnLayout {
            width: parent.width
            spacing: 8
            Repeater {
                model: root.listModel
                TodoListItem {
                    required property var modelData
                    Layout.fillWidth: true
                    todoItem: modelData
                    currentStatus: root.status
                }
            }
        }
    }
}
