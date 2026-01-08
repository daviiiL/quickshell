pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
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

                width: 600
                implicitHeight: resultsList.visible ? 400 : searchFieldContainer.implicitHeight + Theme.ui.padding.sm * 4

                Behavior on implicitHeight {
                    NumberAnimation {
                        duration: Theme.anim.durations.xs
                        easing.type: Easing.InOutQuad
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
                    searchField.forceActiveFocus();
                } else {
                    searchField.clear();
                    AppLauncher.query = "";
                }
            }
        }
    }

    GlobalShortcut {
        name: "toggleAppLauncher"
        description: "Open the application launcher"

        onPressed: {
            GlobalStates.appLauncherOpen = !GlobalStates.appLauncherOpen;
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
