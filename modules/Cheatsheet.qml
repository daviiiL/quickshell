pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Hyprland
import ".."
import "../common"
import "../components"
import "../components/widgets"
import "../services"

Scope {
    id: root
    property bool cheatsheetVisible: false

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: cheatsheetWindow
            property var modelData
            screen: modelData
            property HyprlandMonitor monitor: Hyprland.monitorFor(modelData)

            visible: root.cheatsheetVisible && Hyprland.focusedWorkspace?.monitor === monitor
            color: "transparent"

            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }

            property int currentTabIndex: 0
            property var categoryData: HyprlandKeybinds.ready ? groupKeybindsByCategory() : []

            HyprlandFocusGrab {
                id: focusGrab
                windows: [cheatsheetWindow]
                active: cheatsheetWindow.visible
                onCleared: () => {
                    if (!active)
                        root.cheatsheetVisible = false;
                }
            }

            MouseArea {
                anchors.fill: parent
                onPressed: root.cheatsheetVisible = false
                propagateComposedEvents: false
            }

            Rectangle {
                id: modal
                anchors {
                    fill: parent
                    topMargin: 100
                    bottomMargin: 100
                    leftMargin: 200
                    rightMargin: 200
                }
                color: Colors.current.background
                radius: Theme.rounding.large
                focus: true
                border.width: 1
                border.color: Colors.current.primary
                Component.onCompleted: {
                    if (cheatsheetWindow.visible) {
                        modal.forceActiveFocus();
                    }
                }

                Keys.onPressed: event => {
                    if (event.key === Qt.Key_Escape) {
                        root.cheatsheetVisible = false;
                        event.accepted = true;
                    } else if (event.key === Qt.Key_Left) {
                        if (cheatsheetWindow.currentTabIndex > 0) {
                            cheatsheetWindow.currentTabIndex--;
                        }
                        event.accepted = true;
                    } else if (event.key === Qt.Key_Right) {
                        if (cheatsheetWindow.currentTabIndex < cheatsheetWindow.categoryData.length - 1) {
                            cheatsheetWindow.currentTabIndex++;
                        }
                        event.accepted = true;
                    }
                }

                Connections {
                    target: cheatsheetWindow
                    function onVisibleChanged() {
                        if (cheatsheetWindow.visible) {
                            modal.forceActiveFocus();
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onPressed: mouse => {
                        mouse.accepted = true;
                        modal.forceActiveFocus();
                    }
                    propagateComposedEvents: false
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 30
                    spacing: 20

                    StyledText {
                        id: title
                        Layout.alignment: Qt.AlignHCenter
                        text: "SYSTEM KEYBINDS"
                        color: Colors.current.on_secondary_container
                        font.family: Theme.font.style.departureMono
                        font.pixelSize: Theme.font.size.xxl
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 1
                        color: Colors.current.outline
                        opacity: 0.3
                    }

                    // Tab bar
                    ScrollView {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 45
                        clip: true

                        ScrollBar.vertical.policy: ScrollBar.AlwaysOff
                        ScrollBar.horizontal.policy: ScrollBar.AsNeeded

                        Row {
                            spacing: 8

                            Repeater {
                                model: cheatsheetWindow.categoryData

                                delegate: Rectangle {
                                    required property var modelData
                                    required property int index

                                    width: tabText.implicitWidth + 30
                                    height: 35
                                    color: cheatsheetWindow.currentTabIndex === index ? Colors.current.primary_container : Colors.current.secondary_container
                                    radius: Theme.rounding.small

                                    StyledText {
                                        id: tabText
                                        anchors.centerIn: parent
                                        text: modelData.category
                                        font.pixelSize: Theme.font.size.xl
                                        color: cheatsheetWindow.currentTabIndex === index ? Colors.current.on_primary_container : Colors.current.on_secondary_container
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        onPressed: mouse => {
                                            mouse.accepted = true;
                                            cheatsheetWindow.currentTabIndex = index;
                                        }
                                    }
                                }
                            }
                        }
                    }
                    // Content area
                    ScrollView {
                        id: scrollView
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true

                        contentWidth: availableWidth

                        Column {
                            width: scrollView.availableWidth
                            spacing: 12

                            Repeater {
                                model: cheatsheetWindow.categoryData.length > 0 && cheatsheetWindow.currentTabIndex < cheatsheetWindow.categoryData.length ? cheatsheetWindow.categoryData[cheatsheetWindow.currentTabIndex].keybinds : []

                                delegate: Row {
                                    required property var modelData
                                    spacing: 15
                                    width: parent.width

                                    Row {
                                        spacing: 4
                                        width: 250

                                        Repeater {
                                            model: modelData.mods
                                            delegate: StyledText {
                                                required property var modelData
                                                text: getKeyLabel(modelData)
                                                font.family: Theme.font.style.departureMono
                                                font.pixelSize: Theme.font.size.large
                                                color: Colors.current.primary
                                                anchors.verticalCenter: parent ? parent.verticalCenter : undefined
                                            }
                                        }

                                        StyledText {
                                            visible: modelData.mods.length > 0 && modelData.key
                                            text: "+"
                                            font.family: Theme.font.style.departureMono
                                            font.pixelSize: Theme.font.size.large
                                            color: Colors.current.on_secondary_container
                                            opacity: 0.5
                                            anchors.verticalCenter: parent.verticalCenter
                                        }

                                        StyledText {
                                            visible: modelData.key
                                            text: getKeyLabel(modelData.key)
                                            font.family: Theme.font.style.departureMono
                                            font.pixelSize: Theme.font.size.large
                                            color: Colors.current.primary
                                            anchors.verticalCenter: parent ? parent.verticalCenter : undefined
                                        }
                                    }

                                    StyledText {
                                        text: modelData.comment || getDefaultComment(modelData)
                                        font.pixelSize: Theme.font.size.large
                                        color: Colors.current.on_secondary_container
                                        opacity: 0.9
                                        anchors.verticalCenter: parent.verticalCenter
                                        elide: Text.ElideRight
                                        width: parent.width - 270
                                    }
                                }
                            }
                        }
                    }

                    Row {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 20

                        StyledText {
                            text: "← → to switch tabs"
                            font.pixelSize: Theme.font.size.small
                            color: Colors.current.on_secondary_container
                            opacity: 0.5
                        }

                        StyledText {
                            text: "•"
                            font.pixelSize: Theme.font.size.small
                            color: Colors.current.on_secondary_container
                            opacity: 0.5
                        }

                        StyledText {
                            text: "Esc to close"
                            font.pixelSize: Theme.font.size.small
                            color: Colors.current.on_secondary_container
                            opacity: 0.5
                        }

                        StyledText {
                            text: "•"
                            font.pixelSize: Theme.font.size.small
                            color: Colors.current.on_secondary_container
                            opacity: 0.5
                        }

                        StyledText {
                            text: "Super + / to toggle"
                            font.pixelSize: Theme.font.size.small
                            color: Colors.current.on_secondary_container
                            opacity: 0.5
                        }
                    }
                }
            }

            function getKeyLabel(key) {
                const substitutions = {
                    "SUPER": "SUPER",
                    "Super": "SUPER",
                    "Shift": "SHIFT",
                    "CTRL": "CTRL",
                    "ALT": "ALT",
                    "Return": "ENTER",
                    "Space": "SPACE",
                    "mouse:272": "LMB",
                    "mouse:273": "RMB",
                    "PRINT": "PRTSC",
                    "XF86AudioMute": "MUTE",
                    "XF86AudioRaiseVolume": "VOL+",
                    "XF86AudioLowerVolume": "VOL-",
                    "XF86MonBrightnessUp": "BRIGHT+",
                    "XF86MonBrightnessDown": "BRIGHT-",
                    "XF86AudioPlay": "PLAY",
                    "XF86AudioPrev": "PREV",
                    "XF86AudioNext": "NEXT"
                };
                return substitutions[key] || key;
            }

            function getDefaultComment(keybind) {
                if (keybind.comment)
                    return keybind.comment;

                const dispatcher = keybind.dispatcher;
                const params = keybind.params;

                if (dispatcher === "workspace")
                    return "Workspace " + params;
                if (dispatcher === "movetoworkspace")
                    return "Move to workspace " + params;
                if (dispatcher === "killactive")
                    return "Close window";
                if (dispatcher === "exec")
                    return "Execute command";

                return dispatcher;
            }

            function groupKeybindsByCategory() {
                const categories = {
                    "Session": [],
                    "Applications": [],
                    "Windows": [],
                    "Workspaces": [],
                    "Focus": [],
                    "Screenshots": [],
                    "Media": [],
                    "System": [],
                    "Other": []
                };

                const keybinds = HyprlandKeybinds.keybinds.keybinds || [];
                console.log("[Cheatsheet] groupKeybindsByCategory called, ready:", HyprlandKeybinds.ready, "keybinds count:", keybinds.length);

                for (let i = 0; i < keybinds.length; i++) {
                    const kb = keybinds[i];
                    const comment = kb.comment.toLowerCase();
                    const dispatcher = kb.dispatcher;

                    if (dispatcher === "exec" && (kb.params.includes("killall") || kb.params.includes("hyprlock"))) {
                        categories["Session"].push(kb);
                    } else if (dispatcher === "exec" && (kb.params.includes("$term") || kb.params.includes("$browser") || kb.params.includes("bemenu"))) {
                        categories["Applications"].push(kb);
                    } else if (dispatcher === "killactive" || dispatcher === "togglefloating" || dispatcher === "movewindow" || dispatcher === "resizewindow" || comment.includes("window")) {
                        categories["Windows"].push(kb);
                    } else if (dispatcher === "workspace" || dispatcher === "movetoworkspace" || dispatcher === "togglespecialworkspace" || comment.includes("workspace")) {
                        categories["Workspaces"].push(kb);
                    } else if (dispatcher === "movefocus" || comment.includes("focus")) {
                        categories["Focus"].push(kb);
                    } else if (comment.includes("screenshot") || dispatcher === "exec" && kb.params.includes("hyprshot")) {
                        categories["Screenshots"].push(kb);
                    } else if (comment.includes("audio") || comment.includes("brightness") || kb.key.includes("XF86")) {
                        categories["Media"].push(kb);
                    } else if (dispatcher === "exec" && (kb.params.includes("cliphist") || kb.params.includes("pickwall") || kb.params.includes("hyprpicker"))) {
                        categories["System"].push(kb);
                    } else {
                        categories["Other"].push(kb);
                    }
                }

                const result = [];
                for (let cat in categories) {
                    if (categories[cat].length > 0) {
                        result.push({
                            category: cat,
                            keybinds: categories[cat]
                        });
                    }
                }

                console.log("[Cheatsheet] Returning", result.length, "categories");
                return result;
            }
        }
    }

    // Global signal handlers for triggering the cheatsheet
    Connections {
        target: GlobalStates

        function onShowCheatsheet() {
            root.cheatsheetVisible = true;
            GlobalStates.cheatsheetOpen = true;
        }

        function onHideCheatsheet() {
            root.cheatsheetVisible = false;
            GlobalStates.cheatsheetOpen = false;
        }

        function onToggleCheatsheet() {
            root.cheatsheetVisible = !root.cheatsheetVisible;
            GlobalStates.cheatsheetOpen = root.cheatsheetVisible;
        }
    }

    // Global shortcuts
    GlobalShortcut {
        name: "cheatsheetToggle"
        description: "Toggle keybinds cheatsheet"

        onPressed: {
            GlobalStates.toggleCheatsheet();
        }
    }
}
