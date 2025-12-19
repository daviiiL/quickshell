import QtQuick
import QtQuick.Layouts
import qs.common
import qs.services.apis
import qs.components.widgets

Rectangle {
    id: root

    color: "transparent"
    radius: 4
    implicitWidth: 400

    function normalizeSensorTemp(val) {
        return val > 100 ? 1 : val / 100;
    }

    component SensorRow: RowLayout {
        property alias label: labelText.text
        property alias value: indicator.value

        StyledText {
            id: labelText
            Layout.fillWidth: true
            color: Colors.current.primary
        }
        CircularProgress {
            id: indicator
        }
    }

    component SensorSection: ColumnLayout {
        property alias title: titleText.text
        property list<QtObject> sensors

        Layout.rightMargin: root.implicitWidth / 10

        StyledText {
            id: titleText
            Layout.bottomMargin: 10
            fontSize: Theme.font.size.large
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 4

        anchors.topMargin: Theme.ui.padding.normal

        StyledText {
            text: "> System Status"
            fontSize: Theme.font.size.larger
            color: Colors.current.primary
        }

        RowLayout {
            Layout.fillHeight: true
            Layout.fillWidth: true

            SensorSection {
                title: "Processor"
                SensorRow {
                    label: "TEMPERATURE"
                    value: root.normalizeSensorTemp(Glances.cpu.packageTemp)
                }
                SensorRow {
                    label: "UTILIZATION"
                    value: root.normalizeSensorTemp(Glances.cpu.totalUtilization)
                }
                SensorRow {
                    label: "FREQUENCY"
                    value: root.normalizeSensorTemp(Glances.cpu.frequencyPercentage)
                }
            }

            SensorSection {
                title: "Graphics"
                SensorRow {
                    label: "TEMPERATURE"
                    value: root.normalizeSensorTemp(Glances.gpu.temp)
                }
                SensorRow {
                    label: "UTILIZATION"
                    value: root.normalizeSensorTemp(Glances.gpu.utilization)
                }
                SensorRow {
                    label: "VRAM"
                    value: root.normalizeSensorTemp(Glances.gpu.vramUtilization)
                }
            }
        }

        RowLayout {
            StyledText {
                text: "RAM"
                Layout.fillWidth: true
            }
            StyledText {
                text: "TEMPERATURE"
                color: Colors.current.primary
            }
            ReactiveSensorIndicator {
                value: Glances.ram.temp
            }
        }

        RowLayout {
            StyledText {
                text: "STORAGE"
                Layout.fillWidth: true
            }
            StyledText {
                text: "TEMPERATURE"
                color: Colors.current.primary
            }
            ReactiveSensorIndicator {
                value: Glances.storage.temp
            }
        }
    }
}
