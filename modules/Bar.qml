import Quickshell
import QtQuick
import "../components/"
import "../utils"

Scope {
    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: bar
            property var modelData
            screen: modelData

            anchors {
                top: true
                left: true
                bottom: true
            }

            implicitWidth: Config.bar.width

            color: Colors.values.background

            StatusIcons {
                anchors.bottom: clock.top
            }

            ClockWidget {
                id: clock
                anchors.bottom: power.top
            }
            PowerIndicator {
                id: power
                anchors.bottom: bottom_spacer.top
            }
            VerticalSpacer {
                id: bottom_spacer
                anchors.bottom: parent.bottom
                // color: "transparent"
            }

            PowerPopup {
                id: popupLoader
                pWindow: bar
                Connections {
                    target: power
                    function onMouseCaptured(val) {
                        val ? popupLoader.show() : popupLoader.hide();
                    }
                }
            }
        }
    }
}
