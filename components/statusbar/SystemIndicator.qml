import QtQuick
import QtQuick.Layouts
import qs.common
import qs.services.apis
import qs.components.widgets

Rectangle {
    id: root
    width: 100
    color: "#2e3440"
    radius: 4

    property bool isServerRunning: Glances.isServerRunning
    // property var glances: Glances

    implicitWidth: contentContainer.implicitWidth

    Column {
        spacing: 4

        StyledText {
            text: "System Status"
            fontSize: Theme.font.size.larger
        }

        RowLayout {
            id: contentContainer

            function normalizeSensorTemp(val) {
                return val > 100 ? 1 : val / 100;
            }

            Column {
                StyledText {
                    text: "Processor"
                }

                RowLayout {
                    StyledText {
                        text: "TEMPERATURE"
                    }
                    CircularProgress {
                        value: contentContainer.normalizeSensorTemp(Glances.cpu.packageTemp)
                    }
                }
                RowLayout {
                    StyledText {
                        text: "UTILIZATION"
                    }
                    CircularProgress {
                        value: contentContainer.normalizeSensorTemp(Glances.cpu.totalUtilization)
                    }
                }
                RowLayout {
                    StyledText {
                        text: "FREQUENCY"
                    }
                    CircularProgress {
                        value: contentContainer.normalizeSensorTemp(Glances.cpu.frequencyPercentage)
                    }
                }
            }
        }
    }
    //         Column {
    //             StyledText {
    //                 text: "Processor"
    //             }
    //
    //             RowLayout {
    //                 StyledText {
    //                     text: "TEMPERATURE"
    //                 }
    //                 CircularProgress {
    //                     value: contentContainer.normalizeSensorTemp(Sensors.cpuTemp)
    //                 }
    //             }
    //             RowLayout {
    //                 StyledText {
    //                     text: "UTILIZATION"
    //                 }
    //                 CircularProgress {}
    //             }
    //             RowLayout {
    //                 StyledText {
    //                     text: "FREQUENCY"
    //                 }
    //                 CircularProgress {}
    //             }
    //         }
    //
    //         Column {
    //             StyledText {
    //                 text: "Graphics"
    //             }
    //             RowLayout {
    //                 StyledText {
    //                     text: "TEMPERATURE"
    //                 }
    //                 CircularProgress {
    //                     value: contentContainer.normalizeSensorTemp(Sensors.gpuTemp)
    //                 }
    //             }
    //             RowLayout {
    //                 StyledText {
    //                     text: "UTILIZATION"
    //                 }
    //                 CircularProgress {}
    //             }
    //             RowLayout {
    //                 StyledText {
    //                     text: "FREQUENCY"
    //                 }
    //                 CircularProgress {}
    //             }
    //         }
    //     }
    //     RowLayout {
    //         implicitWidth: parent.implicitWidth
    //         StyledText {
    //             Layout.fillWidth: true
    //             text: "Memory"
    //         }
    //         RowLayout {
    //             StyledText {
    //                 text: "TEMPERATURE"
    //             }
    //             CircularProgress {
    //                 value: contentContainer.normalizeSensorTemp(0)
    //             }
    //         }
    //     }
    //
    //     RowLayout {
    //         implicitWidth: parent.implicitWidth
    //         StyledText {
    //             Layout.fillWidth: true
    //             text: "Storage"
    //         }
    //         RowLayout {
    //             StyledText {
    //                 text: "TEMPERATURE"
    //             }
    //             CircularProgress {
    //                 value: contentContainer.normalizeSensorTemp(Sensors.nvmeTemp)
    //             }
    //         }
    //     }
}
