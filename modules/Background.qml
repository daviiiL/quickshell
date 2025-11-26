import "../common/"
import Qt5Compat.GraphicalEffects
import QtQuick
import Quickshell
import Quickshell.Wayland

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
                implicitWidth: Theme.bar.width
                color: Colors.current.background

                anchors {
                    top: parent.top
                    left: parent.left
                    bottom: parent.bottom
                }

            }

            Rectangle {
                color: Colors.current.background

                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                    leftMargin: Theme.bar.width
                }

                Image {
                    id: wallpaperImage

                    anchors.fill: parent
                    source: Qt.resolvedUrl("../../../Pictures/wallpapers/Hyprland/SolarizedAngel.png")
                    fillMode: Image.PreserveAspectCrop
                    visible: false
                    layer.enabled: GlobalStates.screenLocked

                    layer.effect: FastBlur {
                        radius: GlobalStates.screenLocked ? 64 : 0

                        Behavior on radius {
                            NumberAnimation {
                                duration: Theme.anim.durations.normal
                                easing.type: Easing.OutCubic
                            }

                        }

                    }

                }

                Rectangle {
                    id: roundedMask

                    anchors.fill: wallpaperImage
                    radius: Theme.rounding.large
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
