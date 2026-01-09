pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import qs.common
import qs.services
import qs.widgets
import qs.components.wallpaper

FloatingWindow {
    id: root
    function makeTranslucent(color) {
        return Qt.rgba(color.r, color.g, color.b, 0.4);
    }
    visible: GlobalStates.wallpaperPickerOpen ?? false

    color: "transparent"

    title: "Wallpaper Picker"

    IpcHandler {
        target: "wallpaperPicker"

        function open(): void {
            GlobalStates.wallpaperPickerOpen = true;
        }
    }

    onVisibleChanged: {
        if (!this.visible)
            GlobalStates.wallpaperPickerOpen = false;
    }

    MouseArea {
        id: content
        anchors.fill: parent
        property int columns: 4
        property real previewCellAspectRatio: 4 / 3

        function updateThumbnails() {
            const totalImageMargin = (8 + 8) * 2;
            const thumbnailSizeName = Images.thumbnailSizeNameForDimensions(grid.cellWidth - totalImageMargin, grid.cellHeight - totalImageMargin);
            Wallpapers.generateThumbnail(thumbnailSizeName);
        }

        Connections {
            target: Wallpapers
            function onDirectoryChanged() {
                content.updateThumbnails();
            }
        }

        function selectWallpaperPath(filePath) {
            if (filePath && filePath.length > 0) {
                Wallpapers.select(filePath);
                filterField.text = "";
            }
        }

        Keys.onPressed: event => {
            if (event.key === Qt.Key_Escape) {
                GlobalStates.wallpaperPickerOpen = false;
                event.accepted = true;
            } else if (event.key === Qt.Key_Left) {
                grid.moveSelection(-1);
                event.accepted = true;
            } else if (event.key === Qt.Key_Right) {
                grid.moveSelection(1);
                event.accepted = true;
            } else if (event.key === Qt.Key_Up) {
                grid.moveSelection(-grid.columns);
                event.accepted = true;
            } else if (event.key === Qt.Key_Down) {
                grid.moveSelection(grid.columns);
                event.accepted = true;
            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                grid.activateCurrent();
                event.accepted = true;
            } else if (event.key === Qt.Key_Backspace) {
                if (filterField.text.length > 0) {
                    filterField.text = filterField.text.substring(0, filterField.text.length - 1);
                }
                filterField.forceActiveFocus();
                event.accepted = true;
            } else if (event.key === Qt.Key_Slash) {
                filterField.forceActiveFocus();
                event.accepted = true;
            } else {
                if (event.text.length > 0) {
                    filterField.text += event.text;
                    filterField.cursorPosition = filterField.text.length;
                    filterField.forceActiveFocus();
                }
                event.accepted = true;
            }
        }

        Rectangle {
            id: wallpaperGridBackground
            anchors.fill: parent
            focus: true
            color: Colors.surface

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Theme.ui.padding.md
                spacing: Theme.ui.padding.sm

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.ui.padding.md

                    StyledText {
                        text: "Select Wallpaper"
                        font.pixelSize: Theme.font.size.lg
                        font.weight: Font.Medium
                        color: Colors.on_surface
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    StyledButton {
                        text: "↑ Up"
                        onClicked: Wallpapers.navigateUp()
                    }

                    StyledButton {
                        text: "← Back"
                        onClicked: Wallpapers.navigateBack()
                    }

                    StyledButton {
                        text: "Forward →"
                        onClicked: Wallpapers.navigateForward()
                    }
                }

                // Matugen preferences
                RowLayout {
                    id: matugenPreferencesRow
                    Layout.preferredHeight: 32

                    StyledText {
                        text: "Matugen Color Scheme"
                        font.pixelSize: Theme.font.size.md
                        color: Colors.on_surface_variant
                    }

                    ComboBox {
                        id: dropdown
                        Layout.preferredWidth: 150
                        property bool initializing: true

                        background: Rectangle {
                            color: Colors.surface_container
                            radius: Theme.ui.radius.sm
                            border.width: 1
                            border.color: dropdown.activeFocus ? Colors.primary : Colors.outline_variant
                        }

                        contentItem: Text {
                            leftPadding: Theme.ui.padding.sm
                            rightPadding: dropdown.indicator.width + Theme.ui.padding.sm
                            text: dropdown.displayText
                            font.pixelSize: Theme.font.size.md
                            color: Colors.on_surface
                            verticalAlignment: Text.AlignVCenter
                            elide: Text.ElideRight
                        }

                        model: ListModel {
                            id: matugenSchemesModel
                            ListElement {
                                name: "Content"
                                value: "scheme-content"
                            }
                            ListElement {
                                name: "Expressive"
                                value: "scheme-expressive"
                            }
                            ListElement {
                                name: "Fidelity"
                                value: "scheme-fidelity"
                            }
                            ListElement {
                                name: "Fruit Salad"
                                value: "scheme-fruit-salad"
                            }
                            ListElement {
                                name: "Monochrome"
                                value: "scheme-monochrome"
                            }
                            ListElement {
                                name: "Neutral"
                                value: "scheme-neutral"
                            }
                            ListElement {
                                name: "Rainbow"
                                value: "scheme-rainbow"
                            }
                            ListElement {
                                name: "Tonal Spot"
                                value: "scheme-tonal-spot"
                            }
                        }

                        editable: false

                        textRole: "name"

                        function initialize() {
                            const scheme = Preferences.matugenScheme;
                            for (let i = 0; i < matugenSchemesModel.count; i++) {
                                if (matugenSchemesModel.get(i).value === scheme) {
                                    dropdown.currentIndex = i;
                                    break;
                                }
                            }
                        }

                        onCurrentIndexChanged: {
                            if (!initializing) {
                                const scheme = matugenSchemesModel.get(currentIndex).value;
                                Preferences.setColorScheme(scheme, false);
                            }
                        }

                        Component.onCompleted: {
                            initialize();
                            initializing = false;
                        }

                        Connections {
                            target: Preferences

                            function onColorSchemeChanged() {
                                const scheme = Preferences.getColorScheme();
                                // console.debug(scheme);
                                dropdown.initializing = true;
                                for (let i = 0; i < matugenSchemesModel.count; i++) {
                                    if (matugenSchemesModel.get(i).value === scheme) {
                                        dropdown.currentIndex = i;
                                        break;
                                    }
                                }
                                dropdown.initializing = false;
                            }
                        }

                        delegate: ItemDelegate {
                            id: delegateItem
                            required property int index

                            width: ListView.view.width

                            text: matugenSchemesModel.get(delegateItem.index).name
                            highlighted: dropdown.highlightedIndex === delegateItem.index

                            background: Rectangle {
                                color: delegateItem.highlighted || delegateItem.hovered ? Colors.primary_container : Colors.surface_container
                                radius: Theme.ui.radius.sm
                            }
                            contentItem: Text {
                                text: matugenSchemesModel.get(delegateItem.index).name
                                color: delegateItem.highlighted || delegateItem.hovered ? Colors.on_primary_container : Colors.on_surface_variant
                                font.pixelSize: Theme.font.size.md
                            }
                        }

                        popup: Popup {
                            y: dropdown.height
                            width: dropdown.width
                            implicitHeight: contentItem.implicitHeight
                            padding: 2

                            background: Rectangle {
                                radius: 6
                                color: Colors.surface_container
                                border.color: Colors.surface_bright
                            }

                            contentItem: ListView {
                                clip: true
                                implicitHeight: contentHeight
                                model: dropdown.popup.visible ? dropdown.delegateModel : null
                                currentIndex: dropdown.highlightedIndex
                                highlightFollowsCurrentItem: true
                                keyNavigationEnabled: true

                                ScrollIndicator.vertical: ScrollIndicator {}
                            }
                        }
                    }
                }

                StyledText {
                    Layout.fillWidth: true
                    text: Wallpapers.effectiveDirectory
                    font.pixelSize: Theme.font.size.sm
                    color: Colors.on_surface_variant
                    elide: Text.ElideMiddle
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 4
                    visible: Wallpapers.thumbnailGenerationRunning
                    color: Colors.surface_variant
                    radius: 2

                    Rectangle {
                        width: parent.width * Wallpapers.thumbnailGenerationProgress
                        height: parent.height
                        color: Colors.primary
                        radius: parent.radius
                    }
                }

                GridView {
                    id: grid
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    readonly property int columns: content.columns
                    readonly property int rows: Math.max(1, Math.ceil(count / columns))
                    property int currentIndex: 0

                    cellWidth: width / content.columns
                    cellHeight: cellWidth / content.previewCellAspectRatio
                    interactive: true
                    clip: true
                    keyNavigationWraps: true
                    boundsBehavior: Flickable.StopAtBounds

                    Component.onCompleted: {
                        content.updateThumbnails();
                    }

                    function moveSelection(delta) {
                        currentIndex = Math.max(0, Math.min(grid.model.count - 1, currentIndex + delta));
                        positionViewAtIndex(currentIndex, GridView.Contain);
                    }

                    function activateCurrent() {
                        const filePath = grid.model.get(currentIndex, "filePath");
                        content.selectWallpaperPath(filePath);
                    }

                    model: Wallpapers.folderModel
                    onModelChanged: currentIndex = 0
                    delegate: WallpaperDirectoryItem {
                        required property var modelData
                        fileModelData: modelData
                        grid: grid
                        width: grid.cellWidth
                        height: grid.cellHeight
                        colText: (index === grid.currentIndex || containsMouse) ? Colors.on_primary_container : Colors.on_surface_variant
                        colBackground: (index === grid.currentIndex || containsMouse) ? root.makeTranslucent(Colors.primary_container) : root.makeTranslucent(Colors.secondary_container)

                        onEntered: {
                            grid.currentIndex = index;
                        }

                        onActivated: {
                            content.selectWallpaperPath(fileModelData.filePath);
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.ui.padding.sm

                    StyledButton {
                        text: "Random"
                        onClicked: Wallpapers.randomFromCurrentFolder()
                    }

                    TextField {
                        id: filterField
                        Layout.fillWidth: true
                        placeholderText: "Search wallpapers (or press /)"
                        font.pixelSize: Theme.font.size.sm
                        onTextChanged: {
                            Wallpapers.searchQuery = text;
                        }

                        background: Rectangle {
                            color: Colors.surface_variant
                            radius: Theme.ui.radius.sm
                        }
                        color: Colors.on_surface
                    }

                    StyledButton {
                        text: "Close"
                        onClicked: {
                            GlobalStates.wallpaperPickerOpen = false;
                        }
                    }
                }
            }
        }

        Connections {
            target: GlobalStates
            function onWallpaperPickerOpenChanged() {
                if (GlobalStates.wallpaperPickerOpen) {
                    filterField.forceActiveFocus();
                }
            }
        }

        Connections {
            target: Wallpapers
            function onChanged() {
                GlobalStates.wallpaperPickerOpen = false;
            }
        }
    }
}
