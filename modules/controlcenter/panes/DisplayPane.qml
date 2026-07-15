pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.common
import qs.services
import qs.modules.controlcenter.atoms

Flickable {
    id: root

    Component.onCompleted: console.log("[ControlCenter.display] loaded")
    Component.onDestruction: console.log("[ControlCenter.display] unloaded")

    contentWidth: width
    contentHeight: column.implicitHeight + column.anchors.topMargin + column.anchors.bottomMargin
    boundsBehavior: Flickable.StopAtBounds
    clip: true

    readonly property string brightnessIcon: {
        const frac = Brightness.brightness / 100;
        if (frac < 0.15) return "brightness_low";
        if (frac < 0.55) return "brightness_medium";
        return "brightness_high";
    }

    ColumnLayout {
        id: column
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.leftMargin: 26
        anchors.rightMargin: 26
        anchors.topMargin: 22
        anchors.bottomMargin: 24
        spacing: 0

        Text {
            text: "Display"
            color: Colors.fgSurface
            font.family: Theme.font.family.inter_medium
            font.pixelSize: Theme.font.size.xxl
            font.weight: Font.Medium
        }

        Text {
            Layout.topMargin: 4
            Layout.bottomMargin: 18
            text: "BRIGHTNESS · COLOR · TEXT"
            color: Colors.inkDimmer
            font.family: Theme.font.family.inter_medium
            font.pixelSize: Theme.font.size.xs
            font.letterSpacing: 2.4
        }

        GroupLabel { text: "BUILT-IN SCREEN" }

        GroupBox {
            SliderRow {
                iconSymbol: root.brightnessIcon
                label: "Brightness"
                value: Brightness.brightness / 100
                available: Brightness.available
                onMoved: v => Brightness.setBrightness(Math.round(v * 100))
            }
        }

        GroupLabel { text: "COLOR" }

        GroupBox {
            RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: 30
                Layout.bottomMargin: 16
                spacing: 28

                Item { Layout.fillWidth: true }

                AppearancePreview {
                    dark: false
                    label: "Light"
                    selected: !GlobalStates.darkMode
                    onClicked: { if (!selected) GlobalStates.toggleDarkMode() }
                }

                AppearancePreview {
                    dark: true
                    label: "Dark"
                    selected: GlobalStates.darkMode
                    onClicked: { if (!selected) GlobalStates.toggleDarkMode() }
                }

                Item { Layout.fillWidth: true }
            }
        }

        GroupLabel { text: "TEXT" }

        GroupBox {
            SliderRow {
                readonly property int span: Preferences.maxFontOffset - Preferences.minFontOffset
                iconSymbol: "format_size"
                label: "Font size"
                value: (Preferences.fontOffset - Preferences.minFontOffset) / span
                valueText: (Preferences.fontOffset > 0 ? "+" : "") + Preferences.fontOffset
                onMoved: v => Preferences.setFontOffset(Preferences.minFontOffset + v * span)
            }
        }
    }
}
