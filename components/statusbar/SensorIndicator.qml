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
            Layout.fillHeight: true
            spacing: 4

            StyledText {
                text: "CPU"
                color: Colors.current.primary
            }

            ReactiveSensorIndicator {
                value: Glances.cpu.packageTemp
                isTempSensor: true
            }
        }

        RowLayout {
            visible: Glances.readDGPU
            spacing: 4

            StyledText {
                text: "GPU"
                color: Colors.current.primary
            }

            ReactiveSensorIndicator {
                value: Glances.gpu.temp
                isTempSensor: true
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
                isTempSensor: true
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
                isTempSensor: true
            }
        }
    }
}
