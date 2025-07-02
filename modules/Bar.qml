import Quickshell
import QtQuick
import "../components/"
import "../utils"

Scope {
    Variants {
        model: Quickshell.screens

        PanelWindow {
            property var modelData
            screen: modelData

            anchors {
                top: true
                left: true
                bottom: true
            }

            implicitWidth: Config.bar.width
            color: Colors.values.background
            // color: Colors.dark.background
            ClockWidget {}
        }
    }
}
