pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
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

    readonly property var paneScreen: QsWindow.window?.screen ?? null
    onPaneScreenChanged: if (paneScreen) console.log("[ControlCenter.display] screen " + paneScreen.name + " / " + paneScreen.model)
    readonly property string screenLabel: {
        if (Brightness.deviceAvailable) return "Built-in screen";
        const name = root.paneScreen?.name ?? "";
        const model = (root.paneScreen?.model ?? "").trim();
        if (name.length === 0) return "Screen";
        if (/^(eDP|LVDS|DSI)/i.test(name)) return "Built-in screen";
        return model.length > 0 ? model + " · " + name : name;
    }

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

        GroupLabel { Layout.topMargin: 0; text: root.screenLabel }

        GroupBox {
            SliderRow {
                visible: Brightness.available || Brightness.probing
                iconSymbol: root.brightnessIcon
                label: "Brightness"
                value: Brightness.brightness / 100
                available: Brightness.available
                onMoved: v => Brightness.setBrightness(Math.round(v * 100))
            }

            NoteRow {
                visible: !Brightness.available && !Brightness.probing
                iconSymbol: "brightness_alert"
                label: "Monitor brightness isn't adjustable"
                sub: Brightness.unavailableReason

                function traceNote() {
                    if (visible) console.log("[ControlCenter.display] brightness note: " + sub);
                }
                Component.onCompleted: Qt.callLater(traceNote)
                onVisibleChanged: Qt.callLater(traceNote)
            }
        }

        GroupLabel { text: "Color" }

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

        GroupLabel { text: "Wallpaper" }

        GroupBox {
            WallpaperRow {
                onActivated: GlobalStates.openWallpaperPicker("controlcenter")
            }
        }

        GroupLabel { text: "Text" }

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
