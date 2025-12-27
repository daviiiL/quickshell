pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.common
import qs.widgets

Scope {
    id: root

    property int panelWidth: 400
    property int panelHeight: 600

    GlobalShortcut {
        name: "powerPanelToggle"
        description: "Toggles the power panel"

        onPressed: {
            GlobalStates.powerPanelOpen = !GlobalStates.powerPanelOpen;
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: panel
            required property var modelData

            property int focusedButtonIndex: 0

            function setKeyActionFocusIndex(key) {
                const i = focusedButtonIndex;

                switch (key) {
                case Qt.Key_Right:
                    if ((i & 1) === 0)
                        focusedButtonIndex = i + 1;
                    break;
                case Qt.Key_Left:
                    if ((i & 1) === 1)
                        focusedButtonIndex = i - 1;
                    break;
                case Qt.Key_Up:
                    if (i >= 2)
                        focusedButtonIndex = i - 2;
                    break;
                case Qt.Key_Down:
                    if (i <= 1)
                        focusedButtonIndex = i + 2;
                    break;
                }
            }

            function toggleButtonOnKeys() {
                switch (focusedButtonIndex) {
                case 0:
                    lockButton.clicked();
                    break;
                case 1:
                    logoutButton.clicked();
                    break;
                case 2:
                    rebootButton.clicked();
                    break;
                case 3:
                    shutdownButton.clicked();
                    break;
                }
            }

            screen: modelData
            visible: GlobalStates.powerPanelOpen

            anchors {
                top: true
                left: true
                right: true
                bottom: true
            }

            color: Qt.rgba(Colors.surface.r, Colors.surface.g, Colors.surface.b, 0.3)

            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
            WlrLayershell.namespace: "quickshell:powerpanel"

            exclusiveZone: 0

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    GlobalStates.powerPanelOpen = false;
                }
            }
            Rectangle {
                id: contentRect
                Keys.onEscapePressed: {
                    GlobalStates.powerPanelOpen = false;
                }

                Keys.onPressed: event => {
                    if (event.key === Qt.Key_Right || event.key === Qt.Key_Left || event.key === Qt.Key_Down || event.key === Qt.Key_Up) {
                        panel.setKeyActionFocusIndex(event.key);
                        event.accepted = true;
                    } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space) {
                        panel.toggleButtonOnKeys();
                        event.accepted = true;
                    }
                }

                color: Qt.rgba(Colors.surface_container.r, Colors.surface_container.g, Colors.surface_container.b, 0.55)

                radius: Theme.ui.radius.lg

                height: buttonGrid.implicitHeight + Theme.ui.padding.lg
                width: buttonGrid.implicitWidth

                anchors.centerIn: parent

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: false
                }

                ColumnLayout {
                    id: buttonGrid
                    anchors.fill: parent
                    anchors.margins: Theme.ui.padding.lg
                    spacing: Theme.ui.padding.lg

                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: Theme.ui.padding.lg

                        PowerActionButton {
                            id: lockButton
                            index: 0
                            iconName: "lock"
                            label: "Lock"
                            onClicked: {
                                GlobalStates.powerPanelOpen = false;
                                Hyprland.dispatch("global quickshell:lock");
                            }
                        }

                        PowerActionButton {
                            id: logoutButton
                            index: 1
                            iconName: "logout"
                            label: "Logout"
                            onClicked: {
                                Hyprland.dispatch("exit");
                            }
                        }
                    }

                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: Theme.ui.padding.lg

                        PowerActionButton {
                            id: rebootButton
                            index: 2
                            iconName: "restart_alt"
                            label: "Reboot"
                            onClicked: {
                                Hyprland.dispatch("exec", "systemctl reboot");
                            }
                        }

                        PowerActionButton {
                            id: shutdownButton
                            index: 3
                            iconName: "power_settings_new"
                            label: "Shutdown"
                            onClicked: {
                                Hyprland.dispatch("exec", "systemctl poweroff");
                            }
                        }
                    }

                    Item {
                        Layout.fillHeight: true
                    }
                }
            }

            Component.onCompleted: {
                contentRect.forceActiveFocus();
            }
        }
    }

    component PowerActionButton: Rectangle {
        id: buttonRoot

        property int index

        required property string iconName
        required property string label
        signal clicked

        property bool hovered: false
        property bool keyboardFocused: panel.focusedButtonIndex === index
        property bool isActive: hovered || keyboardFocused

        function makeTranslucent(color) {
            return Qt.rgba(color.r, color.g, color.b, 0.4);
        }

        Layout.preferredWidth: 180
        Layout.preferredHeight: 120

        radius: Theme.ui.radius.md
        color: isActive ? buttonRoot.makeTranslucent(Colors.primary_container) : buttonRoot.makeTranslucent(Colors.secondary_container)

        border {
            color: isActive ? Colors.primary_container : Colors.secondary_container
        }

        Behavior on color {
            ColorAnimation {
                duration: Theme.anim.durations.md
                easing.type: Easing.Bezier
                easing.bezierCurve: Theme.anim.curves.standard
            }
        }

        Behavior on border.color {
            ColorAnimation {
                duration: Theme.anim.durations.sm
                easing.type: Easing.Bezier
                easing.bezierCurve: Theme.anim.curves.standard
            }
        }

        Canvas {
            anchors.fill: parent
            antialiasing: true
            visible: opacity > 0
            opacity: buttonRoot.isActive ? 1 : 0

            Behavior on opacity {
                NumberAnimation {
                    duration: Theme.anim.durations.sm
                    easing.type: Easing.Bezier
                    easing.bezierCurve: Theme.anim.curves.standard
                }
            }

            onPaint: {
                const ctx = getContext("2d");
                ctx.reset();

                ctx.strokeStyle = Colors.primary;
                ctx.lineWidth = 3;
                ctx.lineCap = "round";

                const lineY = 2;
                const lineWidth = 20;
                const startX = (width - lineWidth) / 2;
                const endX = startX + lineWidth;

                ctx.beginPath();
                ctx.moveTo(startX, lineY);
                ctx.lineTo(endX, lineY);
                ctx.stroke();
            }

            Component.onCompleted: requestPaint()
        }

        ColumnLayout {
            anchors.centerIn: parent
            spacing: Theme.ui.padding.md

            MaterialSymbol {
                Layout.alignment: Qt.AlignHCenter
                icon: buttonRoot.iconName
                iconSize: 32
                fontColor: buttonRoot.isActive ? Colors.on_primary_container : Colors.on_secondary_container
            }

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: buttonRoot.label
                font.pixelSize: 16
                font.weight: Font.Medium
                color: buttonRoot.isActive ? Colors.on_primary_container : Colors.on_secondary_container
            }
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            onClicked: buttonRoot.clicked()

            onEntered: {
                buttonRoot.hovered = true;
                panel.focusedButtonIndex = buttonRoot.index;
            }

            onExited: {
                buttonRoot.hovered = false;
            }
        }
    }
}
