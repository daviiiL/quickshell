import Quickshell
import QtQuick
import "../components/"

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

            implicitWidth: 50

            ClockWidget {}
        }
    }
}
