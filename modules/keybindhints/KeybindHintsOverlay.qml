pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick.Layouts
import qs.common
import qs.services
import qs.widgets

Scope {
    id: root

    IpcHandler {
        target: "keybindhints"

        function toggle(): void {
            if (GlobalStates.keybindHintsOpen) {
                GlobalStates.keybindHintsOpen = false
            } else {
                NiriKeybinds.reload()
                GlobalStates.keybindHintsOpen = true
            }
        }

        function open(): void {
            NiriKeybinds.reload()
            GlobalStates.keybindHintsOpen = true
        }

        function close(): void {
            GlobalStates.keybindHintsOpen = false
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: panel
            required property var modelData

            screen: modelData
            visible: GlobalStates.keybindHintsOpen && Preferences.isLoaded

            anchors { top: true; left: true; right: true; bottom: true }
            margins { top: 0; bottom: 0; left: 0; right: 0 }

            exclusiveZone: -1

            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
            WlrLayershell.namespace: "quickshell:keybindhints"

            color: "transparent"

            function closeKeybindHints() {
                GlobalStates.keybindHintsOpen = false
            }

            component KeyChip: Rectangle {
                property alias text: chipText.text

                height: 18
                width: Math.max(18, chipText.implicitWidth + 10)
                color: "transparent"
                border.width: 1
                border.color: Colors.hair
                radius: Theme.ui.radius.sm

                Text {
                    id: chipText
                    anchors.centerIn: parent
                    color: Colors.inkDim
                    font.family: Theme.font.family.inter
                    font.pixelSize: Theme.font.size.xs
                    font.letterSpacing: 0.1
                }
            }

            FocusScope {
                anchors.fill: parent
                focus: GlobalStates.keybindHintsOpen

                Keys.onEscapePressed: panel.closeKeybindHints()

                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                    onPressed: panel.closeKeybindHints()
                }

                Rectangle {
                    anchors.fill: parent
                    color: Qt.rgba(0, 0, 0, 0.35)
                    layer.enabled: true
                    layer.effect: MultiEffect {
                        blurEnabled: true
                        blur: 0.6
                        blurMax: 16
                    }
                }

                Rectangle {
                    id: card

                    // Fuzzy filter over the finite bind list: keep sections, drop
                    // non-matching rows, hide emptied sections.
                    readonly property string query: searchField.text.trim()
                    readonly property var filteredSections: {
                        if (query.length === 0)
                            return NiriKeybinds.sections
                        const out = []
                        NiriKeybinds.sections.forEach(section => {
                            const targets = section.rows.map(row => ({
                                text: row.label + " " + row.keys.join(" "),
                                row: row
                            }))
                            const rows = Fuzzy.go(query, targets, { "key": "text" }).map(r => r.obj.row)
                            if (rows.length > 0)
                                out.push({ name: section.name, rows: rows })
                        })
                        return out
                    }
                    readonly property int bindCount: filteredSections.reduce((n, s) => n + s.rows.length, 0)

                    // Same width calculation as AppLauncherPanel's contentRect
                    width: 560
                    implicitHeight: Math.min(innerColumn.implicitHeight, Math.round(panel.height * 0.56)) + footer.height

                    anchors.top: parent.top
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.topMargin: Math.round(panel.height * 0.16)

                    color: Colors.panelBg
                    radius: Theme.ui.radius.md
                    border.width: 1
                    border.color: Colors.hair
                    clip: true

                    scale: panel.visible ? 1 : 0.97
                    opacity: panel.visible ? 1 : 0

                    transform: Translate {
                        y: panel.visible ? 0 : -12

                        Behavior on y {
                            NumberAnimation {
                                duration: Theme.anim.durations.xs
                                easing.type: Easing.OutCubic
                            }
                        }
                    }

                    Behavior on scale {
                        NumberAnimation {
                            duration: Theme.anim.durations.sm
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

                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                        onPressed: searchField.forceActiveFocus()
                    }

                    Rectangle {
                        anchors.left: parent.left
                        anchors.top: parent.top
                        width: 180
                        height: 1
                        gradient: Gradient {
                            orientation: Gradient.Horizontal
                            GradientStop { position: 0.0; color: Colors.hairCatch }
                            GradientStop { position: 1.0; color: "transparent" }
                        }
                    }

                    ColumnLayout {
                        id: innerColumn
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.bottom: footer.top
                        spacing: 0

                        RowLayout {
                            Layout.fillWidth: true
                            Layout.leftMargin: 16
                            Layout.rightMargin: 16
                            Layout.topMargin: 12
                            Layout.bottomMargin: 12
                            spacing: 12

                            MaterialSymbol {
                                Layout.preferredWidth: 20
                                Layout.alignment: Qt.AlignVCenter
                                icon: "search"
                                iconSize: 16
                                fontColor: Qt.alpha(Colors.fgSurface, 0.56)
                                horizontalAlignment: Text.AlignHCenter
                            }

                            TextField {
                                id: searchField

                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignVCenter

                                placeholderText: "filter keybinds…"
                                placeholderTextColor: Qt.alpha(Colors.fgSurface, 0.30)
                                color: Colors.fgSurface
                                selectionColor: Colors.hairHot
                                selectedTextColor: Colors.fgSurface
                                font.family: Theme.font.family.inter
                                font.pixelSize: Theme.font.size.md

                                padding: 0
                                leftPadding: 0
                                rightPadding: 0
                                topPadding: 0
                                bottomPadding: 0

                                background: Item {}

                                Keys.onPressed: event => {
                                    if (event.key === Qt.Key_Escape) {
                                        if (searchField.text.length > 0) {
                                            searchField.text = ""
                                        } else {
                                            panel.closeKeybindHints()
                                        }
                                        event.accepted = true
                                    }
                                }
                            }

                            Text {
                                Layout.alignment: Qt.AlignVCenter
                                text: card.bindCount + " binds"
                                color: Colors.inkDim
                                font.family: Theme.font.family.inter
                                font.pixelSize: Theme.font.size.xs
                                font.letterSpacing: 0.1
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 1
                            color: Colors.hair
                        }

                        ListView {
                            id: list
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            implicitHeight: contentHeight
                            visible: card.bindCount > 0
                            clip: true
                            boundsBehavior: Flickable.StopAtBounds
                            spacing: 0
                            model: card.filteredSections
                            delegate: SectionRow {
                                required property var modelData
                                required property int index
                                width: ListView.view.width
                                name: modelData.name
                                rows: modelData.rows
                                lastSection: index === list.count - 1
                            }
                        }

                        Item {
                            Layout.fillWidth: true
                            Layout.preferredHeight: visible ? 30 + noMatchText.implicitHeight + 30 : 0
                            visible: card.bindCount === 0

                            Text {
                                id: noMatchText
                                anchors.centerIn: parent
                                text: `NO MATCHES FOR "${card.query.toUpperCase()}"`
                                color: Qt.alpha(Colors.fgSurface, 0.42)
                                font.family: Theme.font.family.inter
                                font.pixelSize: Theme.font.size.sm
                                font.letterSpacing: 2.2
                                horizontalAlignment: Text.AlignHCenter
                            }
                        }
                    }

                    Rectangle {
                        id: footer
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        height: 38
                        color: "transparent"

                        Rectangle {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: parent.top
                            height: 1
                            color: Colors.hair
                        }

                        RowLayout {
                            anchors.left: parent.left
                            anchors.leftMargin: 16
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 10

                            Text {
                                text: "IMPORTANT HOTKEYS"
                                color: Colors.inkDimmer
                                font.family: Theme.font.family.inter
                                font.pixelSize: Theme.font.size.xs
                                font.weight: Font.Medium
                                font.letterSpacing: 1.8
                            }

                            Text {
                                text: "· niri"
                                color: Colors.inkDim
                                font.family: Theme.font.family.inter
                                font.pixelSize: Theme.font.size.xs
                                font.letterSpacing: 0.1
                            }
                        }

                        RowLayout {
                            anchors.right: parent.right
                            anchors.rightMargin: 16
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 14

                            RowLayout {
                                spacing: 6

                                KeyChip { text: "super" }
                                KeyChip { text: "shift" }
                                KeyChip { text: "/" }

                                Text {
                                    text: "TOGGLE"
                                    color: Colors.inkDimmer
                                    font.family: Theme.font.family.inter
                                    font.pixelSize: Theme.font.size.xs
                                    font.letterSpacing: 1.8
                                }
                            }

                            RowLayout {
                                spacing: 6

                                KeyChip { text: "esc" }

                                Text {
                                    text: "CLOSE"
                                    color: Colors.inkDimmer
                                    font.family: Theme.font.family.inter
                                    font.pixelSize: Theme.font.size.xs
                                    font.letterSpacing: 1.8
                                }
                            }
                        }
                    }
                }
            }

            onVisibleChanged: {
                if (visible) {
                    Qt.callLater(() => searchField.forceActiveFocus())
                } else {
                    searchField.text = ""
                }
            }
        }
    }
}
