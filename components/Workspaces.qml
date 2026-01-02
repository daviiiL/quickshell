import QtQuick
import Quickshell
import Quickshell.Hyprland
import qs.common
import qs.services

Rectangle {
    id: root
    function makeTranslucent(color, alpha) {
        return Qt.rgba(color.r, color.g, color.b, 0.4);
    }

    readonly property HyprlandMonitor monitor: Hyprland.monitorFor(root.QsWindow.window?.screen)
    readonly property int workspacesShown: 10
    readonly property int workspaceGroup: Math.floor((monitor?.activeWorkspace?.id - 1) / root.workspacesShown)
    property list<bool> workspaceOccupied: []

    property real workspaceButtonSize: 26
    property real activeWorkspaceMargin: 2
    property real indicatorPadding: 4
    property int workspaceIndexInGroup: (monitor?.activeWorkspace?.id - 1) % root.workspacesShown

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
    // border {
    //     width: 0.5
    //     color: Colors.outline_variant
    // }

    function updateWorkspaceOccupied() {
        const base = workspaceGroup * root.workspacesShown;
        const toplevels = Hyprland.toplevels.values ?? [];
        workspaceOccupied = Array.from({
            length: root.workspacesShown
        }, (_, i) => {
            const targetId = base + i + 1;

            return toplevels.some(tl => tl.workspace && tl.workspace.id === targetId);
        });
    }

    function convertToRomanNumerals(val) {
        return val;
    }

    Component.onCompleted: updateWorkspaceOccupied()
    Connections {
        target: Hyprland.workspaces
        function onValuesChanged() {
            root.updateWorkspaceOccupied();
        }
    }
    Connections {
        target: Hyprland
        function onFocusedWorkspaceChanged() {
            root.updateWorkspaceOccupied();
        }
    }
    onWorkspaceGroupChanged: {
        updateWorkspaceOccupied();
    }

    WheelHandler {
        onWheel: event => {
            if (event.angleDelta.y < 0)
                Hyprland.dispatch(`workspace r+1`);
            else if (event.angleDelta.y > 0)
                Hyprland.dispatch(`workspace r-1`);
        }
        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
    }

    Row {
        z: 1
        anchors.centerIn: root
        spacing: 0

        Repeater {
            model: root.workspacesShown

            Item {
                implicitWidth: root.workspaceButtonSize
                implicitHeight: root.workspaceButtonSize

                Rectangle {
                    id: occupiedBackground
                    z: 1
                    anchors.centerIn: parent
                    width: workspaceButtonSize
                    height: Theme.ui.topBarHeight - root.indicatorPadding * 6
                    radius: Theme.ui.radius.lg

                    property var previousOccupied: workspaceOccupied[index - 1]
                    property var nextOccupied: workspaceOccupied[index + 1]
                    property var radiusPrev: previousOccupied ? 0 : Theme.ui.radius.lg
                    property var radiusNext: nextOccupied ? 0 : Theme.ui.radius.lg

                    topLeftRadius: radiusPrev
                    bottomLeftRadius: radiusPrev
                    topRightRadius: radiusNext
                    bottomRightRadius: radiusNext

                    color: root.occupiedBackgroundColor
                    opacity: workspaceOccupied[index] ? 0.9 : 0

                    Behavior on opacity {
                        NumberAnimation {
                            duration: Theme.anim.durations.sm
                            easing.type: Easing.OutCubic
                        }
                    }
                    Behavior on radiusPrev {
                        NumberAnimation {
                            duration: Theme.anim.durations.sm
                            easing.type: Easing.OutCubic
                        }
                    }
                    Behavior on radiusNext {
                        NumberAnimation {
                            duration: Theme.anim.durations.sm
                            easing.type: Easing.OutCubic
                        }
                    }
                }
            }
        }
    }

    Rectangle {
        z: 2
        radius: Theme.ui.radius.lg
        color: Preferences.darkMode ? makeTranslucent(root.activeIndicatorColor) : root.activeIndicatorColor
        border.color: root.activeIndicatorBorderColor
        border.width: 0.5
        function makeTranslucent(color: color): color {
            return Qt.rgba(color.r, color.g, color.b, 0.4);
        }
        property real idx1: parent.workspaceIndexInGroup
        property real idx2: parent.workspaceIndexInGroup
        property real indicatorPosition: Math.min(idx1, idx2) * parent.workspaceButtonSize
        property real indicatorLength: Math.abs(idx1 - idx2) * parent.workspaceButtonSize + parent.workspaceButtonSize

        anchors.verticalCenter: parent.verticalCenter

        x: indicatorPosition
        width: indicatorLength
        height: Theme.ui.topBarHeight - root.indicatorPadding * 6
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
        Behavior on color {
            ColorAnimation {
                duration: Theme.anim.durations.xs
            }
        }
    }

    Row {
        id: workspaceButtons
        z: 3
        spacing: 0
        anchors.centerIn: root

        Repeater {
            model: root.workspacesShown

            MouseArea {
                id: button
                property int workspaceValue: workspaceGroup * root.workspacesShown + index + 1
                implicitWidth: workspaceButtonSize
                implicitHeight: workspaceButtonSize

                onClicked: Hyprland.dispatch(`workspace ${workspaceValue}`)

                Item {
                    anchors.centerIn: parent
                    implicitHeight: 20
                    implicitWidth: 20

                    Text {
                        text: button.workspaceValue
                        anchors.centerIn: parent
                        renderType: Text.QtRendering
                        renderTypeQuality: Text.HighRenderTypeQuality
                        property real animatedPixelSize: (monitor?.activeWorkspace?.id == button.workspaceValue) ? Theme.font.size.lg : Theme.font.size.md
                        property int animatedWeight: (monitor?.activeWorkspace?.id == button.workspaceValue) ? Font.Bold : Font.Medium

                        color: (monitor?.activeWorkspace?.id == button.workspaceValue) ? root.activeWorkspaceTextColor : (workspaceOccupied[index] ? root.occupiedWorkspaceTextColor : root.inactiveWorkspaceTextColor)

                        font {
                            pixelSize: animatedPixelSize
                            weight: animatedWeight
                            family: Theme.font.family.inter_regular
                        }

                        opacity: (monitor?.activeWorkspace?.id == button.workspaceValue) ? 1.0 : (workspaceOccupied[index] ? 0.8 : 0.4)

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
                        Behavior on animatedWeight {
                            NumberAnimation {
                                duration: Theme.anim.durations.xs
                            }
                        }
                        Behavior on animatedPixelSize {
                            NumberAnimation {
                                duration: Theme.anim.durations.xs
                            }
                        }
                    }
                }
            }
        }
    }
}
