import QtQuick
import QtQuick.Layouts
import qs.common
import qs.components.widgets

Rectangle {
    id: root
    width: 100
    color: "#2e3440"
    radius: 4

    implicitWidth: contentContainer.implicitWidth

    anchors {
        top: parent.top
        bottom: parent.bottom
    }
    Column {
        anchors.fill: parent
        spacing: 4

        StyledText {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "System Status"
            fontSize: Theme.font.size.larger
            Layout.fillHeight: false
        }

        RowLayout {
            id: contentContainer

            Column {
                Layout.fillWidth: true
                StyledText {
                    text: "Processor"
                }

                RowLayout {
                    implicitWidth: parent.implicitWidth
                    StyledText {
                        text: "TEMPERATURE"
                        Layout.fillWidth: true
                    }
                    CircularProgress {}
                }
                RowLayout {
                    implicitWidth: parent.implicitWidth
                    StyledText {
                        text: "UTILIZATION"
                        Layout.fillWidth: true
                    }
                    CircularProgress {}
                }
                RowLayout {
                    implicitWidth: parent.implicitWidth
                    StyledText {
                        text: "FREQUENCY"
                        Layout.fillWidth: true
                    }
                    CircularProgress {}
                }
            }

            Column {
                Layout.fillWidth: true
                StyledText {
                    text: "Graphics"
                }
                RowLayout {
                    StyledText {
                        text: "TEMPERATURE"
                    }
                    CircularProgress {}
                }
                RowLayout {
                    StyledText {
                        text: "UTILIZATION"
                    }
                    CircularProgress {}
                }
                RowLayout {
                    StyledText {
                        text: "FREQUENCY"
                    }
                    CircularProgress {}
                }
            }

            Column {
                Layout.fillWidth: true
                StyledText {
                    text: "Memory"
                }
                RowLayout {
                    StyledText {
                        text: "TEMPERATURE"
                    }
                    CircularProgress {}
                }
                RowLayout {
                    StyledText {
                        text: "UTILIZATION"
                    }
                    CircularProgress {}
                }
                RowLayout {
                    StyledText {
                        text: "FREQUENCY"
                    }
                    CircularProgress {}
                }
            }

            Column {
                Layout.fillWidth: true
                StyledText {
                    text: "Storage"
                }
                RowLayout {
                    StyledText {
                        text: "TEMPERATURE"
                    }
                    CircularProgress {}
                }
                RowLayout {
                    StyledText {
                        text: "UTILIZATION"
                    }
                    CircularProgress {}
                }
                RowLayout {
                    StyledText {
                        text: "FREQUENCY"
                    }
                    CircularProgress {}
                }
            }
        }
    }
}
