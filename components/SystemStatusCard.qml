pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

import qs.common
import qs.services.apis
import qs.widgets

Rectangle {
    id: root
    implicitWidth: layout.implicitWidth + Theme.ui.padding.sm * 2
    implicitHeight: Theme.ui.topBarHeight - 8
    color: "transparent"
    radius: Theme.ui.radius.md

    function getTempColor(temp) {
        if (temp < 60)
            return Colors.primary;
        if (temp < 75)
            return Colors.secondary;
        return Colors.error;
    }

    function getLoadColor(temp) {
        if (temp < 60)
            return Colors.primary;
        if (temp < 75)
            return Colors.secondary;
        return Colors.error;
    }

    RowLayout {
        id: layout
        anchors.fill: parent
        anchors.margins: Theme.ui.padding.sm
        spacing: 10

        RowLayout {
            Layout.fillHeight: true
            spacing: 4

            MaterialSymbol {
                icon: "developer_board"
                iconSize: 16
                fontColor: Colors.secondary
                Layout.alignment: Qt.AlignVCenter
            }

            Text {
                text: Glances.cpu.packageTemp > 0 ? Math.round(Glances.cpu.packageTemp) + "°C" : "--"
                renderType: Text.QtRendering
                renderTypeQuality: Text.HighRenderTypeQuality
                font {
                    family: Theme.font.family.inter_medium
                    pixelSize: Theme.font.size.xs
                }
                color: root.getTempColor(Glances.cpu.packageTemp)
                Layout.alignment: Qt.AlignVCenter

                Behavior on color {
                    ColorAnimation {
                        duration: Theme.anim.durations.sm
                        easing.type: Easing.Bezier
                        easing.bezierCurve: Theme.anim.curves.standard
                    }
                }
            }

            Text {
                text: Glances.cpu.totalUtilization > 0 ? Math.round(Glances.cpu.totalUtilization) + "%" : "--"
                renderType: Text.QtRendering
                renderTypeQuality: Text.HighRenderTypeQuality
                font {
                    family: Theme.font.family.inter_medium
                    pixelSize: Theme.font.size.sm
                }
                color: root.getLoadColor(Glances.cpu.totalUtilization)
                Layout.alignment: Qt.AlignVCenter
                Layout.preferredWidth: 35
                horizontalAlignment: Text.AlignRight
            }
        }

        RowLayout {
            visible: Glances.readDGPU
            Layout.fillHeight: true
            spacing: 4

            MaterialSymbol {
                icon: "graphic_eq"
                iconSize: 16
                fontColor: Colors.secondary
                Layout.alignment: Qt.AlignVCenter
            }

            Text {
                text: Glances.gpu.temp > 0 ? Math.round(Glances.gpu.temp) + "°C" : "--"
                font {
                    family: Theme.font.family.inter_medium
                    pixelSize: Theme.font.size.xs
                }
                color: root.getTempColor(Glances.gpu.temp)
                Layout.alignment: Qt.AlignVCenter

                Behavior on color {
                    ColorAnimation {
                        duration: Theme.anim.durations.sm
                        easing.type: Easing.Bezier
                        easing.bezierCurve: Theme.anim.curves.standard
                    }
                }
            }

            Text {
                text: Glances.gpu.utilization > 0 ? Math.round(Glances.gpu.utilization) + "%" : "--"
                font {
                    family: Theme.font.family.inter_medium
                    pixelSize: Theme.font.size.sm
                }
                color: Colors.secondary
                Layout.alignment: Qt.AlignVCenter
                Layout.preferredWidth: 35
                horizontalAlignment: Text.AlignRight
            }
        }

        RowLayout {
            Layout.fillHeight: true
            spacing: 4

            MaterialSymbol {
                icon: "memory"
                iconSize: 16
                fontColor: Colors.secondary
                Layout.alignment: Qt.AlignVCenter
            }

            Item {
                Layout.preferredWidth: 45
                Layout.preferredHeight: 10
                Layout.alignment: Qt.AlignVCenter

                Rectangle {
                    id: ramBackground
                    anchors.fill: parent
                    color: Colors.surface_container_low
                    radius: Theme.ui.radius.sm
                    border.width: 1
                    border.color: Qt.rgba(Colors.outline.r, Colors.outline.g, Colors.outline.b, 0.3)
                    antialiasing: true

                    Rectangle {
                        id: ramProgress
                        anchors {
                            left: parent.left
                            top: parent.top
                            bottom: parent.bottom
                        }
                        width: parent.width * Math.min(Glances.ram.utilization / 100, 1.0)
                        color: root.getTempColor(Glances.ram.temp)
                        radius: Theme.ui.radius.sm
                        antialiasing: true

                        Behavior on width {
                            NumberAnimation {
                                duration: Theme.anim.durations.sm
                                easing.type: Easing.Bezier
                                easing.bezierCurve: Theme.anim.curves.emphasized
                            }
                        }

                        Behavior on color {
                            ColorAnimation {
                                duration: Theme.anim.durations.sm
                                easing.type: Easing.Bezier
                                easing.bezierCurve: Theme.anim.curves.standard
                            }
                        }
                    }
                }
            }
        }

        // RowLayout {
        //     Layout.fillHeight: true
        //     spacing: 4
        //
        //     MaterialSymbol {
        //         icon: "storage"
        //         iconSize: 16
        //         fontColor: Colors.secondary
        //         Layout.alignment: Qt.AlignVCenter
        //     }
        //
        //     Item {
        //         Layout.preferredWidth: 45
        //         Layout.preferredHeight: 10
        //         Layout.alignment: Qt.AlignVCenter
        //
        //         Rectangle {
        //             id: diskBackground
        //             anchors.fill: parent
        //             color: Colors.surface_container_low
        //             radius: Theme.ui.radius.sm
        //             border.width: 1
        //             border.color: Qt.rgba(Colors.outline.r, Colors.outline.g, Colors.outline.b, 0.3)
        //             antialiasing: true
        //
        //             Rectangle {
        //                 id: diskProgress
        //                 anchors {
        //                     left: parent.left
        //                     top: parent.top
        //                     bottom: parent.bottom
        //                 }
        //                 width: parent.width * Math.min(Glances.storage.temp / 80.0, 1.0)
        //                 color: root.getTempColor(Glances.storage.temp)
        //                 radius: Theme.ui.radius.sm
        //                 antialiasing: true
        //
        //                 Behavior on width {
        //                     NumberAnimation {
        //                         duration: Theme.anim.durations.sm
        //                         easing.type: Easing.Bezier
        //                         easing.bezierCurve: Theme.anim.curves.emphasized
        //                     }
        //                 }
        //
        //                 Behavior on color {
        //                     ColorAnimation {
        //                         duration: Theme.anim.durations.sm
        //                         easing.type: Easing.Bezier
        //                         easing.bezierCurve: Theme.anim.curves.standard
        //                     }
        //                 }
        //             }
        //         }
        //     }
        // }
    }
}
