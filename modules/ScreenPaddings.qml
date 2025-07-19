import QtQuick
import Quickshell
import Quickshell.Wayland
import "../utils/"


Scope {
    Variants {
        model: Quickshell.screens

        PanelWindow {
            property var modelData
            screen: modelData

            WlrLayershell.exclusiveZone: Theme.ui.padding.normal
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

            anchors {
              top: true
              left: true
              right: true
            }

            implicitHeight : Theme.ui.padding.normal
            color: "transparent"

            Rectangle {
              anchors.fill: parent
              color: Colors.current.background
            }
          }
        }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            property var modelData
            screen: modelData

            WlrLayershell.exclusiveZone: Theme.ui.padding.normal
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.None


            anchors {
              bottom: true
              left: true
              right: true
            }

            implicitHeight : Theme.ui.padding.normal
            color: "transparent"

            Rectangle {
              anchors.fill: parent
              color: Colors.current.background
            }
          }
        }
   Variants {
        model: Quickshell.screens

        PanelWindow {
            property var modelData
            screen: modelData
            WlrLayershell.exclusiveZone: Theme.ui.padding.normal
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

            anchors {
              top: true
              right: true
              bottom: true
            }

            implicitWidth : Theme.ui.padding.normal
            color: "transparent"

            Rectangle {
              anchors.fill: parent
              color: Colors.current.background
            }
          }
    }
}
