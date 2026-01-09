pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import qs.common
import qs.services

Rectangle {
    id: root

    property var screen

    function makeTranslucent(color, alpha) {
        return Qt.rgba(color.r, color.g, color.b, 0.4);
    }

    readonly property int workspacesShown: 10
    property real workspaceButtonSize: 26
    property real activeWorkspaceMargin: 2
    property real indicatorPadding: 4

    property var screenWorkspaces: []
    property int focusedWorkspaceIndex: -1

    property var workspaceIdMap: ({})

    readonly property color occupiedBackgroundColor: Preferences.darkMode ? Colors.surface_container_high : Qt.darker(Colors.surface_container, 1.1)
    readonly property color activeIndicatorColor: Preferences.darkMode ? Colors.primary_container : root.makeTranslucent(Colors.inverse_primary, 1.3)
    readonly property color activeIndicatorBorderColor: Preferences.darkMode ? Colors.primary_container : Colors.primary
    readonly property color activeWorkspaceTextColor: Preferences.darkMode ? Colors.on_primary_container : Colors.primary
    readonly property color occupiedWorkspaceTextColor: Preferences.darkMode ? Colors.on_surface : Colors.on_surface
    readonly property color inactiveWorkspaceTextColor: Preferences.darkMode ? Colors.on_surface_variant : Colors.on_surface

    implicitWidth: workspaceButtonSize * root.workspacesShown
    implicitHeight: Theme.ui.topBarHeight

    color: "transparent"
    radius: Theme.ui.radius.lg

    // Hidden Repeater to track workspace state for this screen
    Repeater {
        model: SystemNiri.workspaces

        Item {
            required property var model

            Component.onCompleted: {
                if (model.output === root.screen?.name) {
                    updateWorkspaceState();
                }
            }

            Connections {
                target: model
                function onIsFocusedChanged() {
                    updateWorkspaceState();
                }
                function onIndexChanged() {
                    updateWorkspaceState();
                }
            }

            function updateWorkspaceState() {
                if (model.output !== root.screen?.name)
                    return;

                if (model.isFocused) {
                    root.focusedWorkspaceIndex = model.index - 1;
                }

                let newMap = root.workspaceIdMap;
                newMap[model.index - 1] = model.id;
                root.workspaceIdMap = newMap;
            }
        }
    }

    // Active workspace indicator
    Rectangle {
        z: 2
        radius: Theme.ui.radius.lg
        color: Preferences.darkMode ? Qt.alpha(root.activeIndicatorColor, 0.4) : root.activeIndicatorColor
        border.color: root.activeIndicatorBorderColor
        border.width: 0.5

        property real idx1: root.focusedWorkspaceIndex
        property real idx2: root.focusedWorkspaceIndex
        property real indicatorPosition: Math.max(0, Math.min(idx1, idx2)) * root.workspaceButtonSize
        property real indicatorLength: Math.abs(idx1 - idx2) * root.workspaceButtonSize + root.workspaceButtonSize

        anchors.verticalCenter: parent.verticalCenter
        x: indicatorPosition
        width: indicatorLength
        height: Theme.ui.topBarHeight - root.indicatorPadding * 6
        opacity: root.focusedWorkspaceIndex >= 0 ? 1.0 : 0

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

    // Workspace buttons - Use Instantiator to create them with access to model
    Row {
        z: 3
        spacing: 0
        anchors.centerIn: root

        Repeater {
            model: root.workspacesShown

            Rectangle {
                id: workspaceButton
                required property int index
                implicitWidth: root.workspaceButtonSize
                implicitHeight: root.workspaceButtonSize
                color: "transparent"
                // visible: root.workspaceIdMap[index] !== undefined

                readonly property int niriIndex: index + 1

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        SystemNiri.niri.focusWorkspace(parent.index);
                    }
                    cursorShape: Qt.PointingHandCursor
                }

                Text {
                    text: parent.index + 1
                    anchors.centerIn: parent
                    renderType: Text.QtRendering
                    renderTypeQuality: Text.HighRenderTypeQuality

                    readonly property bool isActive: parent.index === root.focusedWorkspaceIndex
                    property real targetScale: isActive ? 1.15 : 1.0

                    color: isActive ? root.activeWorkspaceTextColor : root.inactiveWorkspaceTextColor

                    font {
                        pixelSize: Theme.font.size.md
                        weight: isActive ? Font.Bold : Font.Medium
                        family: Theme.font.family.inter_regular
                    }

                    opacity: isActive ? 1.0 : 0.4
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
