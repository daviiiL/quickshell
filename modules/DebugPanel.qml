pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.common
import qs.widgets
import qs.services

Scope {
    id: root
    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: panel

            visible: GlobalStates.debugMode

            required property var modelData
            screen: modelData

            anchors {
                top: true
                bottom: true
                left: true
            }

            implicitWidth: 600

            WlrLayershell.layer: WlrLayer.Top
            WlrLayershell.exclusiveZone: this.implicitWidth
            WlrLayershell.exclusionMode: ExclusionMode.Auto

            color: "transparent"

            Rectangle {
                id: contentRect

                anchors.fill: parent
                anchors.margins: Theme.ui.padding.lg
                radius: Theme.ui.radius.lg

                color: Colors.surface

                StyledText {
                    text: "Debug Panel"
                    font.pixelSize: Theme.font.size.xxl
                    font.family: Theme.font.family.inter_regular
                    font.weight: Font.Bold
                    horizontalAlignment: Text.AlignHCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: Colors.primary
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.topMargin: 60
                }
            }
        }
    }
}
