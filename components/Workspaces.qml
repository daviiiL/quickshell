import QtQuick
import Quickshell
import Quickshell.Hyprland
import qs.common

Item {
    id: root

    readonly property HyprlandMonitor monitor: Hyprland.monitorFor(root.QsWindow.window?.screen)
    readonly property int workspacesShown: 10
    readonly property int workspaceGroup: Math.floor((monitor?.activeWorkspace?.id - 1) / root.workspacesShown)
    property list<bool> workspaceOccupied: []

    property real workspaceButtonSize: 26
    property real activeWorkspaceMargin: 2
    property real indicatorPadding: 4
    property int workspaceIndexInGroup: (monitor?.activeWorkspace?.id - 1) % root.workspacesShown

    implicitWidth: workspaceButtonSize * root.workspacesShown
    implicitHeight: Theme.ui.topBarHeight

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
                    radius: Theme.ui.radius.sm

                    property var previousOccupied: workspaceOccupied[index - 1]
                    property var nextOccupied: workspaceOccupied[index + 1]
                    property var radiusPrev: previousOccupied ? 0 : Theme.ui.radius.sm
                    property var radiusNext: nextOccupied ? 0 : Theme.ui.radius.sm

                    topLeftRadius: radiusPrev
                    bottomLeftRadius: radiusPrev
                    topRightRadius: radiusNext
                    bottomRightRadius: radiusNext

                    color: Colors.surface_container_high
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
        radius: Theme.ui.radius.md
        color: makeTranslucent(Colors.primary_container)
        border.color: Colors.primary_container
        function makeTranslucent(color) {
            return Qt.rgba(color.r, color.g, color.b, 0.4);
        }
        property real idx1: parent.workspaceIndexInGroup
        property real idx2: parent.workspaceIndexInGroup
        property real indicatorPosition: Math.min(idx1, idx2) * parent.workspaceButtonSize
        property real indicatorLength: Math.abs(idx1 - idx2) * parent.workspaceButtonSize + parent.workspaceButtonSize

        anchors.verticalCenter: parent.verticalCenter

        x: indicatorPosition
        width: indicatorLength
        height: Theme.ui.topBarHeight - root.indicatorPadding * 2
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

                        color: (monitor?.activeWorkspace?.id == button.workspaceValue) ? Colors.on_primary_container : (workspaceOccupied[index] ? Colors.on_surface : Colors.on_surface_variant)

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
