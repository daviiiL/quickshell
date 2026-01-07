pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import qs.services
import qs.common
import qs.widgets

Rectangle {
    id: root
    color: "transparent"

    ScrollView {
        anchors.fill: parent
        anchors.margins: Theme.ui.padding.lg

        contentWidth: availableWidth

        ColumnLayout {
            id: colorModeSection
            width: parent.width

            property int selectedMode: Preferences.darkMode ? 0 : 1

            Text {
                Layout.fillHeight: false
                Layout.fillWidth: true
                Layout.preferredHeight: implicitHeight

                text: "Style"
                font {
                    pixelSize: Theme.font.size.lg
                    family: Theme.font.family.inter_regular
                    weight: Font.Bold
                }

                antialiasing: true

                color: Colors.on_surface
            }

            Rectangle {

                Layout.preferredWidth: Math.min(500, colorModeSection.width)
                Layout.preferredHeight: 190

                color: Colors.surface_container_high
                radius: Theme.ui.radius.md

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: Theme.ui.padding.sm
                    spacing: Theme.ui.padding.sm

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: "transparent"

                        PreferenceDesktopPreview {
                            anchors {
                                left: parent.left
                                top: parent.top
                                bottom: parent.bottom
                            }
                            width: parent.width / 2

                            isDarkMode: true
                            isSelected: colorModeSection.selectedMode === 0
                            onPreviewClicked: () => {
                                Preferences.setColorMode(0);
                                Preferences.applySelectedVisualPreferences();
                            }
                        }

                        PreferenceDesktopPreview {
                            anchors {
                                right: parent.right
                                top: parent.top
                                bottom: parent.bottom
                            }
                            width: parent.width / 2

                            isDarkMode: false
                            isSelected: colorModeSection.selectedMode === 1
                            onPreviewClicked: () => {
                                Preferences.setColorMode(1);
                                Preferences.applySelectedVisualPreferences();
                            }
                        }
                    }

                    MatugenSchemeComboBox {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 32
                    }
                }
            }
        }
    }

    component PreferenceDesktopPreview: Rectangle {
        id: previewRoot

        required property bool isDarkMode
        required property bool isSelected

        signal previewClicked

        color: "transparent"
        radius: Theme.ui.radius.md

        MouseArea {
            id: previewArea
            anchors.fill: parent
            onClicked: previewRoot.previewClicked()
            hoverEnabled: true
        }

        border {
            width: previewRoot.isSelected || previewArea.containsMouse ? 2 : 0
            color: previewRoot.isSelected ? Colors.primary : (previewArea.containsMouse ? Colors.tertiary : "transparent")

            Behavior on width {
                NumberAnimation {
                    duration: 200
                    easing.type: Easing.OutCubic
                }
            }

            Behavior on color {
                ColorAnimation {
                    duration: 200
                    easing.type: Easing.OutCubic
                }
            }
        }

        Rectangle {
            anchors.fill: parent
            anchors.margins: Theme.ui.padding.sm
            color: previewRoot.isDarkMode ? "#2a2a2a" : "#e8e5e1"
            radius: Theme.ui.radius.md

            Rectangle {
                id: leftBar
                anchors {
                    top: parent.top
                    left: parent.left
                    bottom: parent.bottom
                    margins: 2
                }
                topLeftRadius: parent.radius
                bottomLeftRadius: parent.radius
                implicitWidth: 20
                color: previewRoot.isDarkMode ? "#3a3a3a" : "#f5f3f0"
            }

            Rectangle {
                id: topBar
                anchors {
                    top: parent.top
                    left: leftBar.right
                    right: parent.right
                    margins: Theme.ui.padding.sm - 3
                }

                implicitHeight: 20
                radius: parent.radius
                color: previewRoot.isDarkMode ? "#1a1a1a" : "#fdfcfb"
            }

            Rectangle {
                anchors {
                    bottom: parent.bottom
                    left: leftBar.right
                    right: parent.right
                    top: topBar.bottom
                    margins: Theme.ui.padding.sm - 3
                }

                radius: parent.radius
                color: previewRoot.isDarkMode ? "#3d2f5f" : "#e3d5ff"
                border {
                    color: previewRoot.isDarkMode ? "#7b4dff" : "#9b6dff"
                    width: 2
                }
            }
        }
    }

    component MatugenSchemeComboBox: RowLayout {
        spacing: Theme.ui.padding.md

        Text {
            text: "Color"
            font.pixelSize: Theme.font.size.md
            font.family: Theme.font.family.inter_regular
            color: Colors.on_surface_variant
            verticalAlignment: Text.AlignVCenter
        }

        ComboBox {
            id: colorSchemeDropdown
            Layout.preferredWidth: 180
            Layout.fillWidth: true

            property bool isInitializing: true

            background: Rectangle {
                color: Colors.surface_container
                radius: Theme.ui.radius.sm
                border.width: 1
                border.color: colorSchemeDropdown.activeFocus ? Colors.primary : Colors.outline_variant
            }

            contentItem: Text {
                leftPadding: Theme.ui.padding.sm
                rightPadding: colorSchemeDropdown.indicator.width + Theme.ui.padding.sm
                text: colorSchemeDropdown.displayText
                font.pixelSize: Theme.font.size.md
                color: Colors.on_surface
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
            }

            model: ListModel {
                id: colorSchemesModel
                ListElement {
                    name: "Tonal Spot"
                    value: "scheme-tonal-spot"
                }
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
            }

            editable: false
            textRole: "name"

            Connections {
                target: Preferences

                function onColorSchemeChanged() {
                    const scheme = Preferences.getColorScheme();
                    // console.debug(scheme);
                    for (let i = 0; i < colorSchemesModel.count; i++) {
                        if (colorSchemesModel.get(i).value === scheme) {
                            colorSchemeDropdown.currentIndex = i;
                            break;
                        }
                    }
                }
            }

            onCurrentIndexChanged: {
                if (colorSchemeDropdown.isInitializing) {
                    return;
                }

                const scheme = colorSchemesModel.get(currentIndex).value;
                Preferences.setColorScheme(scheme);

                // console.debug(`[pref panel] Matugen scheme changed to ${scheme} via combobox`);
                // Wallpapers.applyWithCurPreferences(Preferences.wallpaperPath, Preferences.darkMode, scheme);
            }

            Component.onCompleted: {
                const scheme = Preferences.getColorScheme();

                for (let i = 0; i < colorSchemesModel.count; i++) {
                    const item = colorSchemesModel.get(i);
                    if (item.value === scheme) {
                        colorSchemeDropdown.currentIndex = i;
                        break;
                    }
                }
                colorSchemeDropdown.isInitializing = false;
            }

            delegate: ItemDelegate {
                id: delegateItem
                required property int index

                width: ListView.view.width
                text: colorSchemesModel.get(delegateItem.index).name
                highlighted: colorSchemeDropdown.highlightedIndex === delegateItem.index

                background: Rectangle {
                    color: delegateItem.highlighted || delegateItem.hovered ? Colors.primary_container : Colors.surface_container
                    radius: Theme.ui.radius.sm
                }

                contentItem: Text {
                    text: colorSchemesModel.get(delegateItem.index).name
                    color: delegateItem.highlighted || delegateItem.hovered ? Colors.on_primary_container : Colors.on_surface_variant
                    font.pixelSize: Theme.font.size.md
                }
            }

            popup: Popup {
                y: colorSchemeDropdown.height
                width: colorSchemeDropdown.width
                implicitHeight: contentItem.implicitHeight
                padding: 2

                background: Rectangle {
                    radius: Theme.ui.radius.sm
                    color: Colors.surface_container
                    border.color: Colors.surface_bright
                }

                contentItem: ListView {
                    clip: true
                    implicitHeight: contentHeight
                    model: colorSchemeDropdown.popup.visible ? colorSchemeDropdown.delegateModel : null
                    currentIndex: colorSchemeDropdown.highlightedIndex
                    highlightFollowsCurrentItem: true
                    keyNavigationEnabled: true

                    ScrollIndicator.vertical: ScrollIndicator {}
                }
            }
        }

        Rectangle {
            id: applyButton
            Layout.preferredWidth: 60
            Layout.preferredHeight: 32

            color: applyArea.containsMouse ? Colors.primary_container : Colors.surface_bright
            radius: Theme.ui.radius.sm
            border.width: 1
            border.color: Colors.outline_variant

            Behavior on color {
                ColorAnimation {
                    duration: 150
                    easing.type: Easing.OutCubic
                }
            }

            MouseArea {
                id: applyArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                onClicked: {
                    const scheme = colorSchemesModel.get(colorSchemeDropdown.currentIndex).value;
                    // console.debug(`[pref panel] Applying color scheme: ${scheme}`);
                    Wallpapers.applyWithCurPreferences(Preferences.wallpaperPath, Preferences.darkMode, scheme);
                }
            }

            Text {
                anchors.centerIn: parent
                text: "Apply"
                font.pixelSize: Theme.font.size.md
                font.family: Theme.font.family.inter_regular
                color: applyArea.containsMouse ? Colors.on_primary_container : Colors.primary

                Behavior on color {
                    ColorAnimation {
                        duration: 150
                        easing.type: Easing.OutCubic
                    }
                }
            }
        }
    }
}
