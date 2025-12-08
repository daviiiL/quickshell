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

    implicitHeight: workspaceButtonSize * root.workspacesShown

    function updateWorkspaceOccupied() {
        workspaceOccupied = Array.from({
            length: root.workspacesShown
        }, (_, i) => {
            return Hyprland.workspaces.values.some(ws => ws.id === workspaceGroup * root.workspacesShown + i + 1);
        });
    }

    function convertToRomanNumerals(val) {
        return val;
    // let res = "";
    // while (val >= 10) {
    //     res += "X";
    //     val -= 10;
    // }
    //
    // if (val == 9) {
    //     res += "IX";
    // } else {
    //     if (val >= 5) {
    //         res += "V";
    //         val -= 5;
    //     }
    //     while (val > 0) {
    //         res += "I";
    //         val -= 1;
    //     }
    // }
    // return res;
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

    // Background indicator for occupied workspaces
    Column {
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
                    width: Theme.bar.width - root.indicatorPadding * 4
                    height: workspaceButtonSize
                    radius: Theme.rounding.small

                    property var previousOccupied: workspaceOccupied[index - 1]
                    property var nextOccupied: workspaceOccupied[index + 1]
                    property var radiusPrev: previousOccupied ? 0 : Theme.rounding.small
                    property var radiusNext: nextOccupied ? 0 : Theme.rounding.small

                    topLeftRadius: radiusPrev
                    topRightRadius: radiusPrev
                    bottomLeftRadius: radiusNext
                    bottomRightRadius: radiusNext

                    color: Colors.current.surface_container_high
                    opacity: workspaceOccupied[index] ? 0.9 : 0

                    Behavior on opacity {
                        NumberAnimation {
                            duration: Theme.anim.durations.normal
                            easing.type: Easing.OutCubic
                        }
                    }
                    Behavior on radiusPrev {
                        NumberAnimation {
                            duration: Theme.anim.durations.normal
                            easing.type: Easing.OutCubic
                        }
                    }
                    Behavior on radiusNext {
                        NumberAnimation {
                            duration: Theme.anim.durations.normal
                            easing.type: Easing.OutCubic
                        }
                    }
                }
            }
        }
    }

    // Current workspace indicator rectangle (overlays on the dots)
    Rectangle {
        z: 2
        radius: Theme.rounding.regular
        color: Colors.current.primary_container

        property real idx1: parent.workspaceIndexInGroup
        property real idx2: parent.workspaceIndexInGroup
        property real indicatorPosition: Math.min(idx1, idx2) * parent.workspaceButtonSize
        property real indicatorLength: Math.abs(idx1 - idx2) * parent.workspaceButtonSize + parent.workspaceButtonSize

        anchors.horizontalCenter: parent.horizontalCenter
        y: indicatorPosition
        width: Theme.bar.width - root.indicatorPadding * 2
        height: indicatorLength

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
                duration: Theme.anim.durations.small
            }
        }
    }

    // Clickable buttons container
    Column {
        id: workspaceButtons
        z: 3
        spacing: 0
        anchors.centerIn: root

        Repeater {
            model: root.workspacesShown

            // Individual clickable button for each workspace
            MouseArea {
                id: button
                property int workspaceValue: workspaceGroup * root.workspacesShown + index + 1
                implicitWidth: workspaceButtonSize
                implicitHeight: workspaceButtonSize

                onClicked: Hyprland.dispatch(`workspace ${workspaceValue}`)

                // Workspace number indicator
                Item {
                    anchors.centerIn: parent
                    implicitHeight: 20
                    implicitWidth: 20

                    Text {
                        text: button.workspaceValue
                        anchors.centerIn: parent

                        // Intermediate properties for animation
                        property real animatedPixelSize: (monitor?.activeWorkspace?.id == button.workspaceValue) ? Theme.font.size.large : Theme.font.size.regular
                        property int animatedWeight: (monitor?.activeWorkspace?.id == button.workspaceValue) ? Font.Bold : Font.Medium

                        color: (monitor?.activeWorkspace?.id == button.workspaceValue) ? Colors.current.on_primary_container : (workspaceOccupied[index] ? Colors.current.on_surface : Colors.current.on_surface_variant)

                        font {
                            pixelSize: animatedPixelSize
                            weight: animatedWeight
                        }

                        opacity: (monitor?.activeWorkspace?.id == button.workspaceValue) ? 1.0 : (workspaceOccupied[index] ? 0.8 : 0.4)

                        Behavior on color {
                            ColorAnimation {
                                duration: Theme.anim.durations.small
                                easing.type: Easing.OutCubic
                            }
                        }
                        Behavior on opacity {
                            NumberAnimation {
                                duration: Theme.anim.durations.small
                                easing.type: Easing.OutCubic
                            }
                        }
                        Behavior on animatedWeight {
                            NumberAnimation {
                                duration: Theme.anim.durations.small
                            }
                        }
                        Behavior on animatedPixelSize {
                            NumberAnimation {
                                duration: Theme.anim.durations.small
                            }
                        }
                    }
                }
            }
        }
    }
}
