import QtQuick
import QtQuick.Layouts
import Quickshell.Services.UPower
import "../../common/"
import "../../services/"
import "../widgets/"

Item {
    id: root

    // Only show sensors in performance mode
    visible: PowerProfiles.profile != PowerProfile.PowerSaver

    implicitWidth: contentRow.implicitWidth + Theme.ui.padding.normal * 2
    implicitHeight: parent.height

    function getTempColor(temp) {
        if (temp > 70)
            return "#ef5350";  // Red
        if (temp >= 50)
            return "#ffeb3b";  // Yellow
        return "#66bb6a";  // Green
    }

    RowLayout {
        id: contentRow

        anchors.fill: parent
        anchors.margins: Theme.ui.padding.normal
        spacing: 12

        // CPU Temperature
        RowLayout {
            spacing: 4
            visible: Sensors.cpuTemp > 0

            property color tempColor: Sensors.cpuTemp > 70 ? "#ef5350" : Sensors.cpuTemp >= 50 ? "#ffeb3b" : "#66bb6a"

            StyledText {
                text: "CPU"
                color: Colors.current.primary
            }

            ReactiveSensorIndicator {
                value: Sensors.cpuTemp
            }
        }

        // GPU Temperature
        RowLayout {
            spacing: 4
            visible: Sensors.gpuTemp > 0

            property color tempColor: Sensors.gpuTemp > 70 ? "#ef5350" : Sensors.gpuTemp >= 50 ? "#ffeb3b" : "#66bb6a"

            StyledText {
                text: "GPU"
                color: Colors.current.primary
            }

            ReactiveSensorIndicator {
                value: Sensors.gpuTemp
            }
        }

        // NVMe Temperature
        RowLayout {
            spacing: 4
            visible: Sensors.nvmeTemp > 0

            property color tempColor: Sensors.nvmeTemp > 70 ? "#ef5350" : Sensors.nvmeTemp >= 50 ? "#ffeb3b" : "#66bb6a"

            StyledText {
                text: "STORAGE"
                color: Colors.current.primary
            }

            ReactiveSensorIndicator {
                value: Sensors.nvmeTemp
            }
        }
    }
}
