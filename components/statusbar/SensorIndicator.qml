import QtQuick
import QtQuick.Layouts
import Quickshell.Services.UPower
import qs.common
import qs.services.apis
import qs.components.widgets

Item {
    id: root

    visible: PowerProfiles.profile != PowerProfile.PowerSaver

    implicitWidth: contentRow.implicitWidth + Theme.ui.padding.normal * 2
    implicitHeight: parent.height

    RowLayout {
        id: contentRow

        anchors.fill: parent
        anchors.margins: Theme.ui.padding.small
        spacing: 12

        StyledText {
            text: "TEMPS"
            color: Colors.current.secondary
        }

        RowLayout {
            spacing: 4

            StyledText {
                text: "CPU"
                color: Colors.current.primary
            }

            ReactiveSensorIndicator {
                value: Glances.cpu.packageTemp
            }
        }

        RowLayout {
            spacing: 4

            StyledText {
                text: "GPU"
                color: Colors.current.primary
            }

            ReactiveSensorIndicator {
                value: Glances.gpu.temp
            }
        }

        RowLayout {
            spacing: 4

            StyledText {
                text: "STORAGE"
                color: Colors.current.primary
            }

            ReactiveSensorIndicator {
                value: Glances.storage.temp
            }
        }

        RowLayout {
            spacing: 4

            StyledText {
                text: "RAM"
                color: Colors.current.primary
            }

            ReactiveSensorIndicator {
                value: Glances.ram.temp
            }
        }
    }
}
