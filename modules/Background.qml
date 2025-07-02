import Quickshell
import Quickshell.Wayland
import QtQuick
import Qt5Compat.GraphicalEffects
import "../utils/"

Scope {
    Variants {
        model: Quickshell.screens

        PanelWindow {
            property var modelData
            screen: modelData

            color: "transparent"
            WlrLayershell.exclusionMode: ExclusionMode.Ignore
            WlrLayershell.layer: WlrLayer.Background

            anchors {
                top: true
                left: true
                right: true
                bottom: true
            }

            Rectangle {
                anchors {
                    top: parent.top
                    left: parent.left
                    bottom: parent.bottom
                }

                implicitWidth: Config.bar.width
                color: Colors.values.background
            }

            Rectangle {
                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                    leftMargin: Config.bar.width
                }

                color: Colors.values.background

                Image {
                    id: wallpaperImage
                    anchors.fill: parent
                    source: Qt.resolvedUrl("../../../Pictures/wallpapers/Hyprland/SolarizedAngel.png")
                    fillMode: Image.PreserveAspectCrop
                    visible: false
                }

                Rectangle {
                    id: roundedMask
                    anchors.fill: wallpaperImage
                    radius: Config.rounding.large
                    color: "white"
                    visible: false
                }

                OpacityMask {
                    anchors.fill: wallpaperImage
                    source: wallpaperImage
                    maskSource: roundedMask
                }
            }
        }
    }
}
