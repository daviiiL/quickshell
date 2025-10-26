import QtQuick
import QtQuick.Layouts
import Quickshell.Services.UPower
import "../../common/"
import "../../services/"
import "../widgets"

Item {
    id: root

    // Only show sensors in performance mode
    visible: PowerProfiles.profile === PowerProfile.Performance

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

            MaterialSymbol {
                icon: "memory"
                iconSize: 14
                fontColor: Colors.current.on_primary_container
                animated: true
            }

            Text {
                font.family: Theme.font.style.departureMono
                font.pixelSize: 12
                color: parent.tempColor
                text: Sensors.formatTemp(Sensors.cpuTemp)
            }
        }

        // GPU Temperature
        RowLayout {
            spacing: 4
            visible: Sensors.gpuTemp > 0

            property color tempColor: Sensors.gpuTemp > 70 ? "#ef5350" : Sensors.gpuTemp >= 50 ? "#ffeb3b" : "#66bb6a"

            MaterialSymbol {
                icon: "videogame_asset"
                iconSize: 14
                fontColor: Colors.current.on_primary_container
                animated: true
            }

            Text {
                font.family: Theme.font.style.departureMono
                font.pixelSize: 12
                color: parent.tempColor
                text: Sensors.formatTemp(Sensors.gpuTemp)
            }
        }

        // NVMe Temperature
        RowLayout {
            spacing: 4
            visible: Sensors.nvmeTemp > 0

            property color tempColor: Sensors.nvmeTemp > 70 ? "#ef5350" : Sensors.nvmeTemp >= 50 ? "#ffeb3b" : "#66bb6a"

            MaterialSymbol {
                icon: "storage"
                iconSize: 14
                fontColor: Colors.current.on_primary_container
                animated: true
            }

            Text {
                font.family: Theme.font.style.departureMono
                font.pixelSize: 12
                color: parent.tempColor
                text: Sensors.formatTemp(Sensors.nvmeTemp)
            }
        }
    }
}
