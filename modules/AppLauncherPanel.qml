pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.common
import qs.services
import qs.widgets
import qs.components.applauncher

Scope {
    id: root

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

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: panel
            required property var modelData

            screen: modelData
            visible: GlobalStates.appLauncherOpen

            function closeAppLauncher() {
                GlobalStates.appLauncherOpen = false;
            }

            component FooterKbd: Rectangle {
                property string label: ""
                Layout.preferredHeight: 18
                Layout.minimumWidth: 18
                Layout.preferredWidth: Math.max(18, kbdText.implicitWidth + 10)
                Layout.alignment: Qt.AlignVCenter
                radius: 3
                color: "transparent"
                border.width: 1
                border.color: Colors.hair

                Text {
                    id: kbdText
                    anchors.centerIn: parent
                    text: parent.label
                    font.family: Theme.font.family.inter_medium
                    font.pixelSize: 10
                    font.letterSpacing: 1.0
                    color: Qt.alpha(Colors.fgSurface, 0.56)
                }
            }

            anchors {
                top: true
                left: true
                right: true
                bottom: true
            }

            margins {
                top: 0
                bottom: 0
                left: 0
                right: 0
            }

            exclusiveZone: -1

            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
            WlrLayershell.namespace: "quickshell:applauncher"

            color: "transparent"

            MouseArea {
                id: backgroundMouseArea
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                onPressed: panel.closeAppLauncher()
            }

            // Scrim (dim + optional blur). Kept as a single Rectangle so
            // dropping blur later is a one-line change.
            Rectangle {
                id: scrim
                anchors.fill: parent
                color: "#00000059"
                layer.enabled: true
                layer.effect: MultiEffect {
                    blurEnabled: true
                    blur: 0.6
                    blurMax: 16
                }
            }

            Rectangle {
                id: contentRect

                property bool searchFieldVisible: false

                width: 560
                implicitHeight: contentColumn.implicitHeight

                anchors.top: parent.top
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.topMargin: parent.height / 4

                color: Colors.surfaceContainerLowest
                radius: Theme.ui.radius.sm
                border.width: 1
                border.color: Colors.hair
                clip: true

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

                // Swallow clicks on the panel so the background closer doesn't fire
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: false
                    onPressed: searchField.forceActiveFocus()
                }

                Rectangle {
                    anchors.left: parent.left
                    anchors.top: parent.top
                    width: 180
                    height: 1
                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop { position: 0.0; color: "#8ce3e3e3" }
                        GradientStop { position: 1.0; color: "#00e3e3e3" }
                    }
                }

                ColumnLayout {
                    id: contentColumn
                    width: parent.width
                    spacing: 0

                    Item {
                        id: searchFieldContainer
                        Layout.fillWidth: true
                        Layout.preferredHeight: searchRow.implicitHeight + 36

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

                        RowLayout {
                            id: searchRow
                            anchors.fill: parent
                            anchors.leftMargin: 18
                            anchors.rightMargin: 18
                            anchors.topMargin: 18
                            anchors.bottomMargin: 18
                            spacing: 14

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

                                placeholderText: "search applications…"
                                placeholderTextColor: Qt.alpha(Colors.fgSurface, 0.30)
                                color: Colors.fgSurface
                                selectionColor: Colors.hairHot
                                selectedTextColor: Colors.fgSurface
                                font.family: Theme.font.family.inter
                                font.pixelSize: 20

                                padding: 0
                                leftPadding: 0
                                rightPadding: 0
                                topPadding: 0
                                bottomPadding: 0

                                background: Item {}

                                onTextChanged: {
                                    AppLauncher.query = text;
                                    resultsList.currentIndex = 0;
                                }

                                Keys.onPressed: event => {
                                    if (event.key === Qt.Key_Down && resultsList.count > 0) {
                                        resultsList.forceActiveFocus();
                                        resultsList.currentIndex = 0;
                                        event.accepted = true;
                                    } else if (event.key === Qt.Key_Up) {
                                        event.accepted = true;
                                    } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                        if (resultsList.count > 0) {
                                            const item = AppLauncher.results[resultsList.currentIndex] ?? AppLauncher.results[0];
                                            if (item && item.execute) {
                                                panel.closeAppLauncher();
                                                Qt.callLater(() => item.execute());
                                            }
                                        }
                                        event.accepted = true;
                                    } else if (event.key === Qt.Key_Escape) {
                                        if (searchField.text.length > 0) {
                                            searchField.text = "";
                                            AppLauncher.query = "";
                                        } else {
                                            panel.closeAppLauncher();
                                        }
                                        event.accepted = true;
                                    }
                                }
                            }

                            RowLayout {
                                Layout.alignment: Qt.AlignVCenter
                                spacing: 6
                                visible: AppLauncher.query.length === 0

                                Rectangle {
                                    Layout.preferredHeight: 18
                                    Layout.minimumWidth: 18
                                    Layout.preferredWidth: escKbd.implicitWidth + 10
                                    radius: 3
                                    color: "transparent"
                                    border.width: 1
                                    border.color: Colors.hair

                                    Text {
                                        id: escKbd
                                        anchors.centerIn: parent
                                        text: "ESC"
                                        font.family: Theme.font.family.inter_medium
                                        font.pixelSize: 10
                                        font.letterSpacing: 1.0
                                        color: Qt.alpha(Colors.fgSurface, 0.56)
                                    }
                                }

                                Text {
                                    text: "CLOSE"
                                    font.family: Theme.font.family.inter_medium
                                    font.pixelSize: 10
                                    font.letterSpacing: 1.8
                                    color: Qt.alpha(Colors.fgSurface, 0.42)
                                }
                            }
                        }

                        Rectangle {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.bottom: parent.bottom
                            height: 1
                            color: Colors.hair
                            visible: AppLauncher.query.length >= 1
                        }
                    }

                    ListView {
                        id: resultsList

                        visible: AppLauncher.query.length >= 1 && resultsList.count > 0
                        Layout.fillWidth: true
                        Layout.preferredHeight: visible
                            ? Math.min(contentHeight, Math.round(panel.height * 0.52))
                            : 0
                        clip: true
                        spacing: 0
                        boundsBehavior: Flickable.StopAtBounds
                        currentIndex: 0

                        model: ScriptModel {
                            values: AppLauncher.results
                        }

                        delegate: AppLauncherItem {
                            required property var modelData

                            width: resultsList.width
                            item: modelData
                            query: AppLauncher.query
                            currentParentIndex: resultsList.currentIndex
                        }

                        Keys.onPressed: event => {
                            if (event.key === Qt.Key_Up) {
                                if (resultsList.currentIndex <= 0) {
                                    // Up at index 0 returns focus to the TextField.
                                    searchField.forceActiveFocus();
                                    event.accepted = true;
                                } else {
                                    resultsList.currentIndex -= 1;
                                    event.accepted = true;
                                }
                            } else if (event.key === Qt.Key_Down) {
                                if (resultsList.currentIndex >= resultsList.count - 1) {
                                    resultsList.currentIndex = 0;
                                    event.accepted = true;
                                } else {
                                    resultsList.currentIndex += 1;
                                    event.accepted = true;
                                }
                            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                const item = AppLauncher.results[resultsList.currentIndex];
                                if (item && item.execute) {
                                    panel.closeAppLauncher();
                                    Qt.callLater(() => item.execute());
                                }
                                event.accepted = true;
                            } else if (event.key === Qt.Key_Escape) {
                                if (searchField.text.length > 0) {
                                    searchField.text = "";
                                    AppLauncher.query = "";
                                    searchField.forceActiveFocus();
                                } else {
                                    panel.closeAppLauncher();
                                }
                                event.accepted = true;
                            } else if (event.text.length > 0) {
                                // Typing while list is focused — route back to the field
                                searchField.forceActiveFocus();
                                searchField.text += event.text;
                                event.accepted = true;
                            }
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                        Layout.preferredHeight: visible ? 30 + noMatchText.implicitHeight + 30 : 0
                        visible: AppLauncher.query.length >= 1 && resultsList.count === 0

                        Text {
                            id: noMatchText
                            anchors.centerIn: parent
                            text: `NO RESULTS FOR "${(AppLauncher.query || "").toUpperCase()}"`
                            font.family: Theme.font.family.inter_medium
                            font.pixelSize: 11
                            font.letterSpacing: 2.2
                            color: Qt.alpha(Colors.fgSurface, 0.42)
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }

                    Item {
                        id: footer
                        Layout.fillWidth: true
                        Layout.preferredHeight: visible ? footerRow.implicitHeight + 20 : 0

                        visible: !(AppLauncher.query.length >= 1 && resultsList.count === 0)

                        Rectangle {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: parent.top
                            height: 1
                            color: Colors.hair
                        }

                        RowLayout {
                            id: footerRow
                            anchors.fill: parent
                            anchors.leftMargin: 18
                            anchors.rightMargin: 18
                            anchors.topMargin: 10
                            anchors.bottomMargin: 10
                            spacing: 0

                            Text {
                                Layout.alignment: Qt.AlignVCenter
                                text: AppLauncher.query.length >= 1 && resultsList.count > 0
                                    ? `${resultsList.count} ${resultsList.count === 1 ? "MATCH" : "MATCHES"}`
                                    : "TYPE TO SEARCH"
                                font.family: Theme.font.family.inter_medium
                                font.pixelSize: 10
                                font.letterSpacing: 1.8
                                color: Qt.alpha(Colors.fgSurface, 0.42)
                            }

                            Item { Layout.fillWidth: true; Layout.preferredHeight: 1 }

                            RowLayout {
                                Layout.alignment: Qt.AlignVCenter
                                spacing: 14

                                RowLayout {
                                    Layout.alignment: Qt.AlignVCenter
                                    spacing: 6
                                    visible: AppLauncher.query.length >= 1 && resultsList.count > 0

                                    FooterKbd { label: "↑" }
                                    FooterKbd { label: "↓" }
                                    Text {
                                        Layout.alignment: Qt.AlignVCenter
                                        text: "NAVIGATE"
                                        font.family: Theme.font.family.inter_medium
                                        font.pixelSize: 10
                                        font.letterSpacing: 1.8
                                        color: Qt.alpha(Colors.fgSurface, 0.42)
                                    }
                                }

                                RowLayout {
                                    Layout.alignment: Qt.AlignVCenter
                                    spacing: 6

                                    FooterKbd { label: "↵" }
                                    Text {
                                        Layout.alignment: Qt.AlignVCenter
                                        text: "LAUNCH"
                                        font.family: Theme.font.family.inter_medium
                                        font.pixelSize: 10
                                        font.letterSpacing: 1.8
                                        color: Qt.alpha(Colors.fgSurface, 0.42)
                                    }
                                }

                                RowLayout {
                                    Layout.alignment: Qt.AlignVCenter
                                    spacing: 6

                                    FooterKbd { label: "ESC" }
                                    Text {
                                        Layout.alignment: Qt.AlignVCenter
                                        text: "CLOSE"
                                        font.family: Theme.font.family.inter_medium
                                        font.pixelSize: 10
                                        font.letterSpacing: 1.8
                                        color: Qt.alpha(Colors.fgSurface, 0.42)
                                    }
                                }
                            }
                        }
                    }
                }
            }

            onVisibleChanged: {
                if (visible) {
                    searchFieldDelayTimer.start();
                } else {
                    contentRect.searchFieldVisible = false;
                    searchFieldDelayTimer.stop();
                    searchField.text = "";
                    AppLauncher.query = "";
                    resultsList.currentIndex = 0;
                }
            }
        }
    }
}
