pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.common
import qs.services
import qs.components.widgets

Rectangle {
    id: root
    required property var todoItem
    required property string currentStatus

    Layout.fillWidth: true
    Layout.preferredHeight: contentColumn.implicitHeight + 16
    radius: Theme.rounding.small
    color: mouseArea.containsMouse ? Colors.current.surface_container_high : Colors.current.surface_container
    border.color: Colors.current.outline
    border.width: 1

    Behavior on color {
        ColorAnimation {
            duration: Theme.anim.durations.small
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        propagateComposedEvents: true
    }

    ColumnLayout {
        id: contentColumn
        anchors.fill: parent
        anchors.margins: 8
        spacing: 6

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Rectangle {
                Layout.preferredWidth: 4
                Layout.preferredHeight: titleText.height
                radius: 2
                color: root.todoItem.priority === 3 ? Colors.current.error :
                       root.todoItem.priority === 2 ? Colors.current.tertiary :
                       Colors.current.outline
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                Text {
                    id: titleText
                    Layout.fillWidth: true
                    text: root.todoItem.text
                    font.pixelSize: Theme.font.size.regular
                    font.family: Theme.font.style.departureMono
                    font.bold: root.currentStatus === "started"
                    color: root.currentStatus === "completed" ? Colors.current.outline : Colors.current.on_surface
                    wrapMode: Text.WordWrap
                    font.strikeout: root.currentStatus === "completed"
                }

                Text {
                    Layout.fillWidth: true
                    text: root.todoItem.description
                    visible: root.todoItem.description
                    font.pixelSize: Theme.font.size.small
                    font.family: Theme.font.style.departureMono
                    color: Colors.current.on_surface_variant
                    wrapMode: Text.WordWrap
                }
            }

            RowLayout {
                Layout.alignment: Qt.AlignRight | Qt.AlignTop
                spacing: 4

                Rectangle {
                    Layout.preferredWidth: 28
                    Layout.preferredHeight: 28
                    radius: Theme.rounding.small
                    color: moveBtn.containsMouse ? Colors.current.primary_container : "transparent"
                    visible: root.currentStatus !== "completed"

                    MaterialSymbol {
                        anchors.centerIn: parent
                        icon: root.currentStatus === "todo" ? "play_arrow" : "check_circle"
                        iconSize: 16
                        fontColor: Colors.current.on_surface
                    }

                    MouseArea {
                        id: moveBtn
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            Todo.moveTodo(root.todoItem.id, root.currentStatus === "todo" ? "started" : "completed");
                            Todo.save();
                        }
                    }
                }

                Rectangle {
                    Layout.preferredWidth: 28
                    Layout.preferredHeight: 28
                    radius: Theme.rounding.small
                    color: backBtn.containsMouse ? Colors.current.tertiary_container : "transparent"
                    visible: root.currentStatus !== "todo"

                    MaterialSymbol {
                        anchors.centerIn: parent
                        icon: "undo"
                        iconSize: 16
                        fontColor: Colors.current.on_surface
                    }

                    MouseArea {
                        id: backBtn
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            Todo.moveTodo(root.todoItem.id, root.currentStatus === "completed" ? "started" : "todo");
                            Todo.save();
                        }
                    }
                }

                Rectangle {
                    Layout.preferredWidth: 28
                    Layout.preferredHeight: 28
                    radius: Theme.rounding.small
                    color: deleteBtn.containsMouse ? Colors.current.error_container : "transparent"

                    MaterialSymbol {
                        anchors.centerIn: parent
                        icon: "delete"
                        iconSize: 16
                        fontColor: deleteBtn.containsMouse ? Colors.current.error : Colors.current.on_surface
                    }

                    MouseArea {
                        id: deleteBtn
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor

                        onClicked: {
                            Todo.deleteTodo(root.todoItem.id);
                            Todo.save();
                        }
                    }
                }
            }
        }

        Flow {
            Layout.fillWidth: true
            spacing: 4
            visible: root.todoItem.tags?.length > 0
            Repeater {
                model: root.todoItem.tags
                Rectangle {
                    required property string modelData
                    height: 20
                    width: tagText.implicitWidth + 12
                    radius: Theme.rounding.small
                    color: Colors.current.secondary_container
                    Text {
                        id: tagText
                        anchors.centerIn: parent
                        text: modelData
                        font.pixelSize: Theme.font.size.xs
                        font.family: Theme.font.style.departureMono
                        color: Colors.current.on_secondary_container
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 8
            visible: root.todoItem.createdAt

            MaterialSymbol {
                icon: "schedule"
                iconSize: 12
                fontColor: Colors.current.outline
            }

            Text {
                text: root.todoItem.createdAt ? Qt.formatDateTime(root.todoItem.createdAt, "MMM dd, hh:mm") : ""
                font.pixelSize: Theme.font.size.xs
                font.family: Theme.font.style.departureMono
                color: Colors.current.outline
            }

            Item {
                Layout.fillWidth: true
            }

            MaterialSymbol {
                icon: "done"
                iconSize: 12
                fontColor: Colors.current.outline
                visible: root.currentStatus === "completed" && root.todoItem.completedAt
            }

            Text {
                visible: root.currentStatus === "completed" && root.todoItem.completedAt
                text: root.todoItem.completedAt ? Qt.formatDateTime(root.todoItem.completedAt, "MMM dd, hh:mm") : ""
                font.pixelSize: Theme.font.size.xs
                font.family: Theme.font.style.departureMono
                color: Colors.current.outline
            }
        }
    }
}
