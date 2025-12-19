import QtQuick
import QtQuick.Layouts
import qs.common
import qs.services.apis
import qs.components.widgets

Rectangle {
    id: root
    width: 100
    color: "transparent"
    // color: "#2e3440"
    radius: 4

    property bool isServerRunning: Glances.isServerRunning

    implicitWidth: titleText.implicitWidth

    ColumnLayout {
        spacing: 4

        anchors.fill: parent

        StyledText {
            id: titleText
            text: "System Status"
            fontSize: Theme.font.size.larger
        }

        RowLayout {
            id: contentContainer
            Layout.fillHeight: true
            Layout.fillWidth: true
            function normalizeSensorTemp(val) {
                return val > 100 ? 1 : val / 100;
            }
            Column {
                StyledText {
                    text: "Processor"
                    fontSize: Theme.font.size.large
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

        RowLayout {
            StyledText {
                text: "RAM"
                Layout.fillWidth: true
            }
            ColumnLayout {
                RowLayout {
                    StyledText {
                        text: "TEMPERATURE"
                    }
                    // value: Glances.ram.
                    ReactiveSensorIndicator {
                        value: Glances.ram.temp
                        //> 100 ? 100 : Glances.ram.temp
                    }
                }
            }
        }
        RowLayout {
            StyledText {
                text: "GPU"
                Layout.fillWidth: true
            }
            ColumnLayout {
                RowLayout {
                    StyledText {
                        text: "TEMPERATURE"
                    }
                    // value: Glances.ram.
                    ReactiveSensorIndicator {
                        value: Glances.gpu.temp
                        //> 100 ? 100 : Glances.ram.temp
                    }
                }
            }
        }
        RowLayout {
            Layout.fillWidth: true
            StyledText {
                Layout.fillWidth: true
                text: "STORAGE"
            }
            ColumnLayout {
                RowLayout {
                    StyledText {
                        text: "TEMPERATURE"
                    }
                    // value: Glances.ram.
                    ReactiveSensorIndicator {
                        value: Glances.storage.temp
                        //> 100 ? 100 : Glances.ram.temp
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
