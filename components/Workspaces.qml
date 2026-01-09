pragma ComponentBehavior: Bound

import QtQuick
import qs.common
import qs.services

Rectangle {
    id: root

    property var screen

    function makeTranslucent(color, alpha) {
        return Qt.rgba(color.r, color.g, color.b, 0.4);
    }

    property real workspaceButtonSize: 26
    property real activeWorkspaceMargin: 2
    property real indicatorPadding: 4

    property int focusedWorkspacePositionInRow: -1

    readonly property color occupiedBackgroundColor: Preferences.darkMode ? Colors.surface_container_high : Qt.darker(Colors.surface_container, 1.1)
    readonly property color activeIndicatorColor: Preferences.darkMode ? Colors.primary_container : root.makeTranslucent(Colors.inverse_primary, 1.3)
    readonly property color activeIndicatorBorderColor: Preferences.darkMode ? Colors.primary_container : Colors.primary
    readonly property color activeWorkspaceTextColor: Preferences.darkMode ? Colors.on_primary_container : Colors.primary
    readonly property color occupiedWorkspaceTextColor: Preferences.darkMode ? Colors.on_surface : Colors.on_surface
    readonly property color inactiveWorkspaceTextColor: Preferences.darkMode ? Colors.on_surface_variant : Colors.on_surface

    implicitWidth: workspaceRow.width
    implicitHeight: Theme.ui.topBarHeight

    color: "transparent"
    radius: Theme.ui.radius.lg

    Rectangle {
        z: 2
        radius: Theme.ui.radius.lg
        color: Preferences.darkMode ? Qt.alpha(root.activeIndicatorColor, 0.4) : root.activeIndicatorColor
        border.color: root.activeIndicatorBorderColor
        border.width: 0.5

        property real idx1: root.focusedWorkspacePositionInRow
        property real idx2: root.focusedWorkspacePositionInRow
        property real indicatorPosition: Math.max(0, Math.min(idx1, idx2)) * root.workspaceButtonSize
        property real indicatorLength: Math.abs(idx1 - idx2) * root.workspaceButtonSize + root.workspaceButtonSize

        anchors.verticalCenter: parent.verticalCenter
        x: indicatorPosition
        width: indicatorLength
        height: Theme.ui.topBarHeight - root.indicatorPadding * 6
        opacity: root.focusedWorkspacePositionInRow >= 0 ? 1.0 : 0

        Behavior on idx1 {
            NumberAnimation {
                duration: 100
                easing.type: Easing.OutCubic
            }
        }
        Behavior on idx2 {
            NumberAnimation {
                duration: 400
                easing.type: Easing.OutCubic
            }
        }
        Behavior on opacity {
            NumberAnimation {
                duration: Theme.anim.durations.xs
            }
        }
    }

    Row {
        id: workspaceRow
        z: 3
        spacing: 0
        anchors.centerIn: root

        Repeater {
            model: SystemNiri.workspaces

            Item {
                id: workspaceContainer
                required property var model
                required property int index

                implicitWidth: root.workspaceButtonSize
                implicitHeight: root.workspaceButtonSize
                visible: workspaceContainer.model.output === root.screen?.name

                opacity: visible ? 1.0 : 0.0
                scale: visible ? 1.0 : 0.0

                property int myPositionInRow: 0

                Behavior on opacity {
                    NumberAnimation {
                        duration: Theme.anim.durations.sm
                        easing.type: Easing.OutCubic
                    }
                }
                Behavior on scale {
                    NumberAnimation {
                        duration: Theme.anim.durations.sm
                        easing.type: Easing.OutBack
                    }
                }

                Component.onCompleted: {
                    calculatePosition();
                }

                onVisibleChanged: {
                    if (visible)
                        calculatePosition();
                }

                function calculatePosition() {
                    if (!visible)
                        return;

                    let pos = 0;
                    for (let i = 0; i < workspaceRow.children.length; i++) {
                        let child = workspaceRow.children[i];
                        if (child === workspaceContainer)
                            break;
                        if (child.visible)
                            pos++;
                    }
                    myPositionInRow = pos;

                    if (workspaceContainer.model.isFocused) {
                        root.focusedWorkspacePositionInRow = pos;
                    }
                }

                Connections {
                    target: workspaceContainer.model
                    function onIsFocusedChanged() {
                        if (workspaceContainer.model.isFocused && workspaceContainer.visible) {
                            root.focusedWorkspacePositionInRow = workspaceContainer.myPositionInRow;
                        }
                    }
                }

                Rectangle {
                    id: workspaceButton
                    anchors.fill: parent
                    color: "transparent"

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            SystemNiri.niri.focusWorkspaceById(workspaceContainer.model.id);
                        }
                        cursorShape: Qt.PointingHandCursor
                    }

                    Text {
                        z: 2
                        text: workspaceContainer.model.index
                        anchors.centerIn: parent
                        renderType: Text.QtRendering
                        renderTypeQuality: Text.HighRenderTypeQuality

                        property real targetScale: workspaceContainer.model.isFocused ? 1.15 : 1.0

                        color: workspaceContainer.model.isFocused ? root.activeWorkspaceTextColor : root.inactiveWorkspaceTextColor

                        font {
                            pixelSize: Theme.font.size.md
                            weight: workspaceContainer.model.isFocused ? Font.Bold : Font.Medium
                            family: Theme.font.family.inter_regular
                        }

                        opacity: workspaceContainer.model.isFocused ? 1.0 : 0.4
                        scale: targetScale
                        transformOrigin: Item.Center

                        Behavior on color {
                            ColorAnimation {
                                duration: Theme.anim.durations.xs
                                easing.type: Easing.OutCubic
                            }
                        }
                        Behavior on opacity {
                            NumberAnimation {
                                duration: Theme.anim.durations.xs
                                easing.type: Easing.OutCubic
                            }
                        }
                        Behavior on targetScale {
                            NumberAnimation {
                                duration: Theme.anim.durations.xs
                                easing.type: Easing.OutCubic
                            }
                        }
                    }
                }
            }
        }
    }
}
