import QtQuick
import Quickshell
import Quickshell.Wayland
import "../utils/"
import "../components/"

Scope {
    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: root

            property var modelData
            screen: modelData

            anchors {
                top: true
                left: true
                right: true
                bottom: true
            }

            margins.left: Theme.bar.width

            mask: Region {
                item: null
            }

            color: "transparent"

            WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
            WlrLayershell.exclusionMode: ExclusionMode.Ignore

            readonly property color cornerColor: Colors.current.background

            ScreenCorner {
                id: topLeftCorner
                anchors {
                    top: parent.top
                    left: parent.left
                }
                color: root.cornerColor
                size: Theme.rounding.large
                corner: ScreenCorner.CornerEnum.TopLeft
            }

            ScreenCorner {
                id: topRightCorner
                anchors {
                    top: parent.top
                    right: parent.right
                }
                color: root.cornerColor
                size: Theme.rounding.large
                corner: ScreenCorner.CornerEnum.TopRight
            }

            ScreenCorner {
                id: bottomLeftCorner
                anchors {
                    bottom: parent.bottom
                    left: parent.left
                }
                color: root.cornerColor
                size: Theme.rounding.large
                corner: ScreenCorner.CornerEnum.BottomLeft
            }

            ScreenCorner {
                id: bottomRightCorner
                anchors {
                    bottom: parent.bottom
                    right: parent.right
                }
                color: root.cornerColor
                size: Theme.rounding.large
                corner: ScreenCorner.CornerEnum.BottomRight
            }
        }
    }
}
