pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.common
import qs.services
import qs.widgets
import qs.components.applauncher

Scope {
    id: root

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: panel
            required property var modelData

            screen: modelData
            visible: GlobalStates.appLauncherOpen

            function closeAppLauncher() {
                backgroundMouseArea.forceActiveFocus();
                GlobalStates.appLauncherOpen = false;
            }

            anchors {
                top: true
                left: true
                right: true
                bottom: true
            }

            color: "transparent"

            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
            WlrLayershell.namespace: "quickshell:applauncher"

            exclusiveZone: 0

            MouseArea {
                id: backgroundMouseArea
                anchors.fill: parent
                onClicked: {
                    panel.closeAppLauncher();
                }
            }

            Rectangle {
                id: contentRect

                property bool searchFieldVisible: false

                width: 600
                implicitHeight: resultsList.visible ? 400 : searchFieldContainer.implicitHeight + Theme.ui.padding.sm * 4

                scale: panel.visible ? 1 : 0.92
                opacity: panel.visible ? 1 : 0

                transform: Translate {
                    y: panel.visible ? 0 : -20

                    Behavior on y {
                        NumberAnimation {
                            duration: Theme.anim.durations.xs * 1.5
                            easing.type: Easing.OutCubic
                        }
                    }
                }

                Timer {
                    id: searchFieldDelayTimer
                    interval: Theme.anim.durations.xs * 0.85
                    running: false
                    repeat: false
                    onTriggered: {
                        contentRect.searchFieldVisible = true;
                        searchField.forceActiveFocus();
                    }
                }

                Behavior on scale {
                    NumberAnimation {
                        duration: Theme.anim.durations.xs * 1.5
                        easing.type: Easing.OutCubic
                    }
                }

                Behavior on opacity {
                    NumberAnimation {
                        duration: Theme.anim.durations.xs * 1.2
                        easing.type: Easing.OutQuad
                    }
                }

                Behavior on implicitHeight {
                    NumberAnimation {
                        duration: Theme.anim.durations.xs * 1.8
                        easing.type: Easing.OutCubic
                    }
                }

                anchors {
                    top: parent.top
                    horizontalCenter: parent.horizontalCenter
                    topMargin: panel.screen.height / 4
                }

                color: Preferences.darkMode ? Colors.surface : Colors.surface_container_low
                radius: Theme.ui.radius.lg

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: false
                }

                border {
                    width: 1
                    color: Colors.outline_variant
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: Theme.ui.padding.md
                    spacing: Theme.ui.padding.sm

                    RowLayout {
                        id: searchFieldContainer
                        Layout.alignment: Qt.AlignTop
                        Layout.fillWidth: true
                        spacing: Theme.ui.padding.sm

                        opacity: contentRect.searchFieldVisible ? 1 : 0
                        transform: Translate {
                            y: contentRect.searchFieldVisible ? 0 : 10

                            Behavior on y {
                                NumberAnimation {
                                    duration: Theme.anim.durations.xs * 1.2
                                    easing.type: Easing.OutCubic
                                }
                            }
                        }

                        Behavior on opacity {
                            NumberAnimation {
                                duration: Theme.anim.durations.xs * 1.2
                                easing.type: Easing.OutQuad
                            }
                        }

                        MaterialSymbol {
                            icon: "search"
                            iconSize: Theme.font.size.xl
                            fontColor: Colors.on_surface_variant
                        }

                        StyledTextField {
                            id: searchField

                            Layout.fillWidth: true
                            placeholderText: "Search applications"
                            font.pixelSize: Theme.font.size.lg

                            placeholderTextColor: Preferences.darkMode ? Qt.lighter(Colors.primary_container, 1.3) : Qt.lighter(Colors.on_secondary_container, 5)

                            onTextChanged: {
                                AppLauncher.query = text;
                            }

                            Keys.onPressed: event => {
                                if (event.key === Qt.Key_Down && resultsList.count > 0) {
                                    resultsList.forceActiveFocus();
                                    resultsList.currentIndex = 0;
                                    event.accepted = true;
                                } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                    if (resultsList.count > 0) {
                                        const firstItem = resultsList.itemAtIndex(0);
                                        if (firstItem && firstItem.modelData?.execute) {
                                            panel.closeAppLauncher();
                                            firstItem.modelData.execute();
                                        }
                                    }
                                    event.accepted = true;
                                } else if (event.key === Qt.Key_Escape) {
                                    panel.closeAppLauncher();
                                    event.accepted = true;
                                }
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 1
                        Layout.topMargin: Theme.ui.padding.sm
                        color: Colors.outline_variant
                        visible: resultsList.count > 0
                        opacity: resultsList.count > 0 ? 1 : 0

                        Behavior on opacity {
                            NumberAnimation {
                                duration: Theme.anim.durations.xs
                                easing.type: Easing.OutQuad
                            }
                        }
                    }

                    ListView {
                        id: resultsList
                        visible: AppLauncher.query.length >= 1

                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        spacing: 4

                        model: ScriptModel {
                            values: AppLauncher.results
                        }

                        add: Transition {
                            NumberAnimation {
                                properties: "opacity"
                                from: 0
                                to: 1
                                duration: Theme.anim.durations.xs
                                easing.type: Easing.OutQuad
                            }
                            NumberAnimation {
                                properties: "y"
                                from: -10
                                duration: Theme.anim.durations.xs
                                easing.type: Easing.OutCubic
                            }
                        }

                        remove: Transition {
                            NumberAnimation {
                                properties: "opacity"
                                to: 0
                                duration: Theme.anim.durations.xs * 0.8
                                easing.type: Easing.InQuad
                            }
                        }

                        displaced: Transition {
                            NumberAnimation {
                                properties: "y"
                                duration: Theme.anim.durations.xs
                                easing.type: Easing.OutCubic
                            }
                        }

                        delegate: AppLauncherItem {
                            required property var modelData
                            width: resultsList.width
                            query: AppLauncher.query
                            focus: ListView.isCurrentItem
                            currentParentIndex: resultsList.currentIndex
                        }

                        Keys.onPressed: event => {
                            if (event.key === Qt.Key_Up) {
                                if (currentIndex === 0) {
                                    searchField.forceActiveFocus();
                                }
                            }
                        }

                        Text {
                            anchors.centerIn: parent
                            visible: resultsList.count === 0
                            text: AppLauncher.query === "" ? "Start typing to search..." : "No applications found"
                            font.pixelSize: Theme.font.size.md
                            color: Colors.on_surface_variant
                        }
                    }
                }
            }

            onVisibleChanged: {
                if (visible) {
                    searchFieldDelayTimer.start();
                    searchField.forceActiveFocus();
                } else {
                    contentRect.searchFieldVisible = false;
                    searchFieldDelayTimer.stop();
                    searchField.clear();
                    AppLauncher.query = "";
                }
            }
        }
    }

    IpcHandler {
        target: "appLauncher"

        function toggle(): void {
            GlobalStates.appLauncherOpen = !GlobalStates.appLauncherOpen;
        }

        function open(): void {
            GlobalStates.appLauncherOpen = true;
        }

        function close(): void {
            GlobalStates.appLauncherOpen = false;
        }
    }
}
