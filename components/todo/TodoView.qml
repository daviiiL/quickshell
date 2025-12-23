pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import qs.common
import qs.services
import qs.components.widgets

ColumnLayout {
    id: root
    property int sidebarPadding: Theme.ui.padding.large

    anchors.fill: parent
    anchors.margins: sidebarPadding
    spacing: sidebarPadding

    onVisibleChanged: if (visible) todoInput.forceActiveFocus()

    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 40
        radius: Theme.rounding.small
        color: "transparent"

        Text {
            anchors.centerIn: parent
            text: "Todo List"
            font.pixelSize: Theme.font.size.large
            font.family: Theme.font.style.departureMono
            color: Colors.current.secondary
        }
    }

    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 45
        radius: Theme.rounding.small
        color: Colors.current.surface_container
        border.color: Colors.current.outline
        border.width: 1

        RowLayout {
            anchors.fill: parent
            anchors.margins: 8
            spacing: 8
            TextField {
                id: todoInput
                Layout.fillWidth: true
                placeholderText: "Add new todo..."
                color: Colors.current.on_surface
                font.pixelSize: Theme.font.size.regular
                font.family: Theme.font.style.departureMono
                background: Rectangle { color: "transparent" }
                Keys.onReturnPressed: addTodo()
                function addTodo() {
                    if (text.trim()) {
                        Todo.addTodo(text, "", 2, []);
                        Todo.save();
                        text = "";
                    }
                }
            }
            Rectangle {
                Layout.preferredWidth: 35
                Layout.preferredHeight: 35
                radius: Theme.rounding.small
                color: addButton.containsMouse ? Colors.current.primary_container : Colors.current.surface_container
                MaterialSymbol {
                    anchors.centerIn: parent
                    icon: "add"
                    iconSize: 20
                    fontColor: Colors.current.on_surface
                }
                MouseArea {
                    id: addButton
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: todoInput.addTodo()
                }
            }
        }
    }

    Rectangle {
        Layout.fillWidth: true
        Layout.fillHeight: true
        color: "transparent"
        radius: Theme.rounding.small

        ColumnLayout {
            anchors.fill: parent
            spacing: 0
            TabBar {
                id: tabBar
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                Repeater {
                    model: [
                        {list: Todo.todos, name: "Todo", status: "todo", icon: "checklist", empty: "No todos yet"},
                        {list: Todo.started, name: "Started", status: "started", icon: "pending", empty: "Nothing started"},
                        {list: Todo.completed, name: "Completed", status: "completed", icon: "task_alt", empty: "Nothing completed"}
                    ]
                    TabButton {
                        required property var modelData
                        text: `${modelData.name} (${modelData.list.length})`
                        font.family: Theme.font.style.departureMono
                    }
                }
            }
            StackLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                currentIndex: tabBar.currentIndex
                Repeater {
                    model: [
                        {list: Todo.todos, status: "todo", icon: "checklist", empty: "No todos yet"},
                        {list: Todo.started, status: "started", icon: "pending", empty: "Nothing started"},
                        {list: Todo.completed, status: "completed", icon: "task_alt", empty: "Nothing completed"}
                    ]
                    TodoListView {
                        required property var modelData
                        listModel: modelData.list
                        status: modelData.status
                        emptyMessage: modelData.empty
                        emptyIcon: modelData.icon
                    }
                }
            }
        }
    }

    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 40
        radius: Theme.rounding.small
        color: Colors.current.surface_container

        RowLayout {
            anchors.fill: parent
            anchors.margins: 5
            spacing: 5
            Rectangle {
                Layout.preferredWidth: 40
                Layout.preferredHeight: 30
                radius: Theme.rounding.small
                color: saveBtn.containsMouse ? Colors.current.primary_container : "transparent"
                MaterialSymbol {
                    anchors.centerIn: parent
                    icon: "save"
                    iconSize: 18
                    fontColor: Colors.current.on_surface
                }
                MouseArea {
                    id: saveBtn
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Todo.save()
                }
            }
            Text {
                Layout.fillWidth: true
                text: `${Todo.todos.length + Todo.started.length + Todo.completed.length} total`
                font.pixelSize: Theme.font.size.small
                font.family: Theme.font.style.departureMono
                color: Colors.current.on_surface
                horizontalAlignment: Text.AlignHCenter
            }
            Rectangle {
                Layout.preferredWidth: 40
                Layout.preferredHeight: 30
                radius: Theme.rounding.small
                color: deleteBtn.containsMouse ? Colors.current.error_container : "transparent"
                MaterialSymbol {
                    anchors.centerIn: parent
                    icon: "delete_sweep"
                    iconSize: 18
                    fontColor: deleteBtn.containsMouse ? Colors.current.error : Colors.current.on_surface
                }
                MouseArea {
                    id: deleteBtn
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        Todo.deleteCompleted();
                        Todo.save();
                    }
                }
            }
        }
    }
}
