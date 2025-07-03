import Quickshell
import QtQuick
import QtQuick.Controls
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
                color: "transparent"
            }

            PowerPopup {
                id: popupLoader
                pWindow: bar
            }

            Button {
                text: "test brightness"
                anchors.centerIn: parent
                onClicked: function () {
                    const brightness = Brightness.getBrightness();
                    console.log(brightness);
                }

                Connections {
                    target: Brightness
                    function onBrightnessChanged(val) {
                        console.log("brightness change", val);
                    }
                }
            }

            Connections {
                target: power
                function onMouseCaptured(val) {
                    val ? popupLoader.show() : popupLoader.hide();
                }
            }
        }
    }
}
