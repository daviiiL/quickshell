pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import qs.services
import qs.common

Rectangle {
    id: root
    color: "transparent"

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.ui.padding.lg
        spacing: Theme.ui.padding.md
        Text {
            Layout.fillHeight: false
            Layout.fillWidth: true
            Layout.preferredHeight: implicitHeight

            text: "Preferences"
            font {
                pixelSize: Theme.font.size.xxl
                family: Theme.font.family.inter_bold
                weight: Font.Bold
            }

            antialiasing: true

            color: Colors.on_surface
        }

        ScrollView {
            Layout.fillHeight: true
            Layout.fillWidth: true

            contentWidth: availableWidth

            ColumnLayout {
                id: colorModeSection
                width: parent.width

                property int selectedMode: Preferences.darkMode ? 0 : 1

                Text {
                    Layout.fillHeight: false
                    Layout.fillWidth: true
                    Layout.preferredHeight: implicitHeight

                    text: "Color Mode"
                    font {
                        pixelSize: Theme.font.size.lg
                        family: Theme.font.family.inter_regular
                        weight: Font.Normal
                    }

                    antialiasing: true

                    color: Colors.on_surface
                }

                Rectangle {

                    Layout.preferredWidth: Math.min(500, colorModeSection.width)
                    Layout.preferredHeight: 150

                    color: "transparent"

                    Rectangle {

                        MouseArea {
                            id: darkModeArea
                            anchors.fill: parent
                            onClicked: () => Preferences.toggleDarkMode(0)
                            hoverEnabled: true
                        }

                        border {
                            width: colorModeSection.selectedMode === 0 || darkModeArea.containsMouse ? 2 : 0
                            color: colorModeSection.selectedMode === 0 ? Colors.primary : (darkModeArea.containsMouse ? Colors.tertiary : "transparent")

                            Behavior on width {
                                NumberAnimation {
                                    duration: 200
                                    easing.type: Easing.OutCubic
                                }
                            }

                            Behavior on color {
                                ColorAnimation {
                                    duration: 200
                                    easing.type: Easing.OutCubic
                                }
                            }
                        }
                        anchors {
                            left: parent.left
                            top: parent.top
                            bottom: parent.bottom
                        }
                        radius: Theme.ui.radius.md
                        width: parent.width / 2

                        color: "transparent"

                        Rectangle {
                            anchors.fill: parent
                            anchors.margins: Theme.ui.padding.sm
                            color: "#2a2a2a"
                            radius: Theme.ui.radius.md
                            Rectangle {
                                id: leftBarDark
                                anchors {
                                    top: parent.top
                                    left: parent.left
                                    bottom: parent.bottom
                                    margins: 2
                                }
                                topLeftRadius: parent.radius
                                bottomLeftRadius: parent.radius
                                implicitWidth: 20
                                color: "#3a3a3a"
                            }
                            Rectangle {
                                id: topBarDark
                                anchors {
                                    top: parent.top
                                    left: leftBarDark.right
                                    right: parent.right
                                    margins: Theme.ui.padding.sm - 3
                                }

                                implicitHeight: 20
                                radius: parent.radius
                                color: "#1a1a1a"
                            }

                            Rectangle {
                                anchors {
                                    bottom: parent.bottom
                                    left: leftBarDark.right
                                    right: parent.right
                                    top: topBarDark.bottom
                                    margins: Theme.ui.padding.sm - 3
                                }

                                radius: parent.radius
                                color: "#3d2f5f"
                                border {
                                    color: "#7b4dff"
                                    width: 2
                                }
                            }
                        }
                    }

                    Rectangle {
                        anchors {
                            right: parent.right
                            top: parent.top
                            bottom: parent.bottom
                        }

                        MouseArea {
                            id: lightModeArea
                            anchors.fill: parent
                            onClicked: () => Preferences.toggleDarkMode(1)
                            hoverEnabled: true
                        }

                        width: parent.width / 2
                        radius: Theme.ui.radius.md
                        border {
                            width: colorModeSection.selectedMode === 1 || lightModeArea.containsMouse ? 2 : 0
                            color: colorModeSection.selectedMode === 1 ? Colors.primary : (lightModeArea.containsMouse ? Colors.tertiary : "transparent")

                            Behavior on width {
                                NumberAnimation {
                                    duration: 200
                                    easing.type: Easing.OutCubic
                                }
                            }

                            Behavior on color {
                                ColorAnimation {
                                    duration: 200
                                    easing.type: Easing.OutCubic
                                }
                            }
                        }
                        color: "transparent"

                        Rectangle {
                            anchors.fill: parent
                            anchors.margins: Theme.ui.padding.sm
                            color: "#e8e5e1"
                            radius: Theme.ui.radius.md

                            Rectangle {
                                id: leftBarLight
                                anchors {
                                    top: parent.top
                                    left: parent.left
                                    bottom: parent.bottom
                                    margins: 2
                                }
                                topLeftRadius: parent.radius
                                bottomLeftRadius: parent.radius
                                implicitWidth: 20
                                color: "#f5f3f0"
                            }
                            Rectangle {
                                id: topBarLight
                                anchors {
                                    top: parent.top
                                    left: leftBarLight.right
                                    right: parent.right
                                    margins: Theme.ui.padding.sm - 3
                                }

                                implicitHeight: 20
                                radius: parent.radius
                                color: "#fdfcfb"
                            }

                            Rectangle {
                                anchors {
                                    bottom: parent.bottom
                                    left: leftBarLight.right
                                    right: parent.right
                                    top: topBarLight.bottom
                                    margins: Theme.ui.padding.sm - 3
                                }

                                radius: parent.radius
                                color: "#e3d5ff"
                                border {
                                    color: "#9b6dff"
                                    width: 2
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
