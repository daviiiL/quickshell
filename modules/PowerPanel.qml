pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import qs.common
import qs.widgets

Scope {
    id: root

    property int panelWidth: 400
    property int panelHeight: 600

    IpcHandler {
        target: "powerpanel"

        function toggle(): void {
            GlobalStates.powerPanelOpen = !GlobalStates.powerPanelOpen;
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: panel
            required property var modelData

            property int focusedButtonIndex: 0
            property bool closing: false

            function resetButtonAnimations(): void {
                lockButton.animationStart = false;
                logoutButton.animationStart = false;
                rebootButton.animationStart = false;
                shutdownButton.animationStart = false;
            }

            onVisibleChanged: {
                if (visible && GlobalStates.powerPanelOpen) {
                    closing = false;
                    buttonAnimationDelay.start();
                } else {
                    resetButtonAnimations();
                }
            }

            Timer {
                id: buttonAnimationDelay
                interval: 100
                repeat: false
                onTriggered: buttonAnimationSequence.start()
            }

            Timer {
                id: buttonAnimationSequence
                interval: 30
                repeat: true

                property int currentIndex: 0
                property var buttons: [lockButton, logoutButton, rebootButton, shutdownButton]

                onTriggered: {
                    if (currentIndex < buttons.length) {
                        buttons[currentIndex].animationStart = true;
                        currentIndex++;
                    } else {
                        stop();
                    }
                }

                function start(): void {
                    currentIndex = 0;
                    panel.resetButtonAnimations();
                    running = true;
                }
            }

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

            function closePanel(): void {
                GlobalStates.powerPanelOpen = !GlobalStates.powerPanelOpen;
                panel.closing = false;
            }

            Timer {
                id: closePanelTimer
                running: false
                repeat: false
                interval: 400
                onTriggered: () => {
                    panel.closePanel();
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
            visible: GlobalStates.powerPanelOpen || closing

            anchors {
                top: true
                left: true
                right: true
                bottom: true
            }

            color: "transparent"

            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
            WlrLayershell.namespace: "quickshell:powerpanel"

            exclusiveZone: 0

            Rectangle {
                anchors.fill: parent
                z: -1
                color: Colors.background

                opacity: panel.closing ? 0 : (GlobalStates.powerPanelOpen ? 1 : 0)

                Behavior on opacity {
                    NumberAnimation {
                        duration: 400
                        easing.type: Easing.OutCubic
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    panel.closing = true;
                    closePanelTimer.running = true;
                }
            }

            Rectangle {
                id: contentRect

                Keys.onEscapePressed: {
                    panel.closing = true;
                    closePanelTimer.running = true;
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

                color: Colors.surface_container_low
                radius: Theme.ui.radius.lg

                height: buttonGrid.implicitHeight + Theme.ui.padding.lg
                width: buttonGrid.implicitWidth + Theme.ui.padding.lg * 2

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
                                Quickshell.execDetached(["qs", "ipc", "call", "lock", "activate"]);
                                GlobalStates.powerPanelOpen = false;
                            }

                            focusedButtonIndex: panel.focusedButtonIndex
                        }

                        PowerActionButton {
                            id: logoutButton
                            index: 1
                            iconName: "logout"
                            label: "Logout"
                            onClicked: {
                                Quickshell.execDetached(["niri", "msg", "action", "quit"]);
                            }
                            focusedButtonIndex: panel.focusedButtonIndex
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
                                Quickshell.execDetached(["systemctl", "reboot"]);
                            }
                            focusedButtonIndex: panel.focusedButtonIndex
                        }

                        PowerActionButton {
                            id: shutdownButton
                            index: 3
                            iconName: "power_settings_new"
                            label: "Shutdown"
                            onClicked: {
                                Quickshell.execDetached(["systemctl", "poweroff"]);
                            }
                            focusedButtonIndex: panel.focusedButtonIndex
                        }
                    }

                    Item {
                        Layout.fillHeight: true
                    }
                }

                opacity: panel.closing ? 0 : (GlobalStates.powerPanelOpen ? 1 : 0)
                scale: panel.closing ? 0.9 : (GlobalStates.powerPanelOpen ? 1 : 0.9)

                Behavior on opacity {
                    NumberAnimation {
                        duration: 350
                        easing.type: Easing.OutCubic
                    }
                }

                Behavior on scale {
                    NumberAnimation {
                        duration: 350
                        easing.type: Easing.OutBack
                        easing.overshoot: 1.2
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

        required property int focusedButtonIndex
        required property string iconName
        required property string label

        property int index
        property bool hovered: false
        property bool animationStart: false

        property bool keyboardFocused: focusedButtonIndex === index
        property bool isActive: hovered || keyboardFocused

        signal clicked

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

        opacity: animationStart ? 1 : 0
        scale: animationStart ? 1 : 0.8

        Canvas {
            anchors.fill: parent
            antialiasing: true
            visible: opacity > 0

            opacity: buttonRoot.isActive ? 1 : 0

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

            Behavior on opacity {
                NumberAnimation {
                    duration: Theme.anim.durations.sm
                    easing.type: Easing.Bezier
                    easing.bezierCurve: Theme.anim.curves.standard
                }
            }
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

        Behavior on opacity {
            NumberAnimation {
                duration: 300
                easing.type: Easing.OutCubic
            }
        }

        Behavior on scale {
            NumberAnimation {
                duration: 300
                easing.type: Easing.OutBack
                easing.overshoot: 1.1
            }
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
    }
}
