pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs.common
import qs.services
import qs.widgets

Item {
    id: root

    signal closeRequested()

    property alias searchField: searchField
    property alias resultsList: resultsList

    readonly property int _listMaxHeight: 400

    // Suppress hover-to-select while the keyboard is driving navigation.
    // Cleared by any genuine cursor motion (HoverHandler below).
    property bool _keyboardActive: false
    property real _lastSceneX: -1
    property real _lastSceneY: -1

    readonly property var selectedEntry: Cliphist.count > 0
        ? (Cliphist.results[resultsList.currentIndex] ?? null)
        : null

    onSelectedEntryChanged: {
        if (selectedEntry && selectedEntry.type !== "img") {
            Cliphist.decodeEntry(selectedEntry.id);
        }
    }

    HoverHandler {
        onPointChanged: {
            const x = point.scenePosition.x;
            const y = point.scenePosition.y;
            if (x !== root._lastSceneX || y !== root._lastSceneY) {
                root._lastSceneX = x;
                root._lastSceneY = y;
                root._keyboardActive = false;
            }
        }
    }

    implicitHeight: contentColumn.implicitHeight

    function focusSearch() {
        searchField.forceActiveFocus();
    }

    function _pickCurrent() {
        if (resultsList.count > 0) {
            const item = Cliphist.results[resultsList.currentIndex];
            if (item) Cliphist.pickEntry(item.id);
        }
    }

    function _escapeOrClose() {
        if (searchField.text.length > 0) {
            searchField.text = "";
            Cliphist.query = "";
        } else {
            root.closeRequested();
        }
    }

    component FooterLabel: Text {
        font.family: Theme.font.family.inter_medium
        font.pixelSize: 10
        font.letterSpacing: 1.8
        color: Qt.alpha(Colors.fgSurface, 0.42)
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

    ColumnLayout {
        id: contentColumn
        width: parent.width
        spacing: 0

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: searchRow.implicitHeight + 36

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
                    horizontalAlignment: Text.AlignHCenter
                    icon: "search"
                    iconSize: 16
                    fontColor: Qt.alpha(Colors.fgSurface, 0.56)
                }

                TextField {
                    id: searchField

                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter

                    placeholderText: "search clipboard history…"
                    placeholderTextColor: Qt.alpha(Colors.fgSurface, 0.30)
                    color: Colors.fgSurface
                    selectionColor: Colors.hairHot
                    selectedTextColor: Colors.fgSurface
                    font.family: Theme.font.family.inter
                    font.pixelSize: 18

                    padding: 0
                    leftPadding: 0
                    rightPadding: 0
                    topPadding: 0
                    bottomPadding: 0

                    background: Item {}

                    onTextChanged: {
                        Cliphist.query = text;
                        if (resultsList.count > 0)
                            resultsList.currentIndex = 0;
                        root._keyboardActive = true;
                    }

                    Keys.onPressed: event => {
                        if (event.key === Qt.Key_Down && resultsList.count > 0) {
                            root._keyboardActive = true;
                            resultsList.forceActiveFocus();
                            if (resultsList.currentIndex < 0)
                                resultsList.currentIndex = 0;
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Up && resultsList.count > 0) {
                            root._keyboardActive = true;
                            resultsList.forceActiveFocus();
                            resultsList.currentIndex = Math.max(0, resultsList.count - 1);
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            root._pickCurrent();
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Delete) {
                            if (resultsList.count > 0) {
                                const item = Cliphist.results[resultsList.currentIndex];
                                if (item) Cliphist.deleteEntry(item.id);
                            }
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Escape) {
                            root._escapeOrClose();
                            event.accepted = true;
                        }
                    }
                }

                RowLayout {
                    Layout.alignment: Qt.AlignVCenter
                    spacing: 6
                    visible: Cliphist.query.length === 0

                    FooterKbd { label: "ESC" }
                    FooterLabel { text: "CLOSE" }
                }
            }

            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                height: 1
                color: Colors.hair
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: Cliphist.count === 0
                ? emptyText.implicitHeight + 60
                : Math.max(220, Math.min(resultsList.contentHeight, root._listMaxHeight))

            RowLayout {
                anchors.fill: parent
                spacing: 0
                visible: Cliphist.count > 0

                ListView {
                    id: resultsList

                    Layout.preferredWidth: 360
                    Layout.fillHeight: true

                    clip: true
                    spacing: 0
                    boundsBehavior: Flickable.StopAtBounds
                    currentIndex: 0
                    reuseItems: true

                    ScrollBar.vertical: ScrollBar {
                        policy: ScrollBar.AsNeeded
                        width: 6
                    }

                    model: ScriptModel {
                        values: Cliphist.results
                    }

                    delegate: CliphistRow {
                        required property var modelData
                        required property int index

                        width: resultsList.width
                        entry: modelData
                        firstRow: index === 0
                        selected: index === resultsList.currentIndex
                        query: Cliphist.query
                        keyboardActive: root._keyboardActive

                        onHovered: resultsList.currentIndex = index
                        onPicked: {
                            if (modelData?.id !== undefined)
                                Cliphist.pickEntry(modelData.id);
                        }
                    }

                    Keys.onPressed: event => {
                        if (event.key === Qt.Key_Up) {
                            root._keyboardActive = true;
                            if (resultsList.currentIndex <= 0) {
                                searchField.forceActiveFocus();
                                event.accepted = true;
                            } else {
                                resultsList.currentIndex -= 1;
                                event.accepted = true;
                            }
                        } else if (event.key === Qt.Key_Down) {
                            root._keyboardActive = true;
                            if (resultsList.currentIndex >= resultsList.count - 1) {
                                resultsList.currentIndex = 0;
                                event.accepted = true;
                            } else {
                                resultsList.currentIndex += 1;
                                event.accepted = true;
                            }
                        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            root._pickCurrent();
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Delete) {
                            const item = Cliphist.results[resultsList.currentIndex];
                            if (!item) { event.accepted = true; return; }
                            const wasLast = resultsList.currentIndex >= resultsList.count - 1;
                            Cliphist.deleteEntry(item.id);
                            // If we just deleted the last row, step back; otherwise the next row slides into our index.
                            if (wasLast && resultsList.currentIndex > 0)
                                resultsList.currentIndex -= 1;
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Escape) {
                            const hadQuery = searchField.text.length > 0;
                            root._escapeOrClose();
                            if (hadQuery) searchField.forceActiveFocus();
                            event.accepted = true;
                        } else if (event.text.length > 0) {
                            searchField.forceActiveFocus();
                            searchField.text += event.text;
                            event.accepted = true;
                        }
                    }
                }

                Rectangle {
                    Layout.preferredWidth: 1
                    Layout.fillHeight: true
                    color: Colors.hair
                }

                CliphistDetail {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    entry: root.selectedEntry
                    decodedText: root.selectedEntry
                        ? (Cliphist.decoded[root.selectedEntry.id] ?? "")
                        : ""
                    query: Cliphist.query
                    onPicked: if (root.selectedEntry) Cliphist.pickEntry(root.selectedEntry.id)
                    onDeleted: if (root.selectedEntry) Cliphist.deleteEntry(root.selectedEntry.id)
                }
            }

            Text {
                id: emptyText
                anchors.centerIn: parent
                visible: Cliphist.count === 0
                text: {
                    if (!Cliphist.available) return "CLIPHIST NOT INSTALLED";
                    if (Cliphist.query.length > 0) return `NO MATCH FOR "${Cliphist.query.toUpperCase()}"`;
                    return "NO CLIPBOARD HISTORY YET";
                }
                font.family: Theme.font.family.inter_medium
                font.pixelSize: 11
                font.letterSpacing: 2.2
                color: Colors.inkDimmer
                horizontalAlignment: Text.AlignHCenter
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: footerRow.implicitHeight + 20

            Rectangle {
                anchors.fill: parent
                color: Colors.surfaceContainerLowest
            }

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

                FooterLabel {
                    Layout.alignment: Qt.AlignVCenter
                    text: `${Cliphist.count} ${Cliphist.count === 1 ? "ENTRY" : "ENTRIES"}`
                }

                Item { Layout.fillWidth: true; Layout.preferredHeight: 1 }

                RowLayout {
                    Layout.alignment: Qt.AlignVCenter
                    spacing: 14

                    RowLayout {
                        spacing: 6
                        FooterKbd { label: "↑" }
                        FooterKbd { label: "↓" }
                        FooterLabel { text: "NAV" }
                    }

                    RowLayout {
                        spacing: 6
                        FooterKbd { label: "↵" }
                        FooterLabel { text: "COPY" }
                    }

                    RowLayout {
                        spacing: 6
                        FooterKbd { label: "DEL" }
                        FooterLabel { text: "DELETE" }
                    }

                    RowLayout {
                        spacing: 6
                        FooterKbd { label: "ESC" }
                        FooterLabel { text: "CLOSE" }
                    }
                }
            }
        }
    }
}
