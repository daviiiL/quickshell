pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

import qs.services
import qs.widgets
import qs.common

Rectangle {
    id: root
    color: "transparent"

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.ui.padding.lg

        spacing: Theme.ui.padding.lg

        Text {
            text: "Battery & Power Profiles"
            font {
                pixelSize: Theme.font.size.xxl
                family: Theme.font.family.inter_bold
                weight: Font.Bold
            }

            antialiasing: true

            color: Colors.on_surface
        }

        Rectangle {
            visible: GlobalStates.isLaptop

            Layout.fillWidth: true
            Layout.preferredHeight: 100

            color: Colors.surface_container_high
            radius: Theme.ui.radius.md

            RowLayout {
                anchors.fill: parent

                ColumnLayout {
                    Layout.fillHeight: true
                    Layout.preferredWidth: root.width >= 450 ? parent.width * 0.6 : parent.width

                    RowLayout {
                        Layout.alignment: Qt.AlignLeft
                        Layout.leftMargin: Theme.ui.padding.sm
                        Text {
                            Layout.alignment: Qt.AlignLeft
                            Layout.leftMargin: Theme.ui.padding.sm
                            text: `${Power.percentage * 100}%`

                            color: Colors.primary
                            font {
                                pixelSize: Theme.font.size.xxxl
                                family: Theme.font.family.inter_bold
                                weight: Font.Bold
                            }
                        }

                        Text {
                            Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                            text: "• " + Power.batteryStatusText

                            color: Colors.secondary

                            font {
                                pixelSize: Theme.font.size.lg
                                family: Theme.font.family.inter_medium
                                weight: Font.Medium
                            }
                        }
                    }

                    BatteryProgressBar {
                        Layout.preferredHeight: 20
                        Layout.preferredWidth: parent.width
                        value: Power.percentage
                        total: 1
                    }
                }

                ColumnLayout {
                    visible: root.width >= 450
                    Layout.fillHeight: true
                    Layout.preferredWidth: parent.width * 0.4

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignLeft
                        Layout.rightMargin: Theme.ui.padding.sm

                        property color healthColor: {
                            if (Power.healthPercentage >= 0.8) {
                                return Preferences.darkMode ? "#4a9d4a" : "#2d7a2d";
                            } else {
                                return Colors.error;
                            }
                        }

                        MaterialSymbol {
                            id: checkIcon
                            icon: "check_circle"
                            iconSize: Theme.font.size.xxl
                            fontColor: parent.healthColor
                        }

                        Text {
                            Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                            Layout.fillWidth: true
                            text: `Health ${Math.round(Power.healthPercentage * 100)}%`
                            color: parent.healthColor
                            wrapMode: Text.Wrap
                            font {
                                pixelSize: Theme.font.size.xl
                                family: Theme.font.family.inter_medium
                                weight: Font.Medium
                            }
                        }
                    }

                    Text {
                        text: Power.batteryChangeRateText

                        color: Colors.secondary
                        font {
                            pixelSize: Theme.font.size.md
                            family: Theme.font.family.inter_regular
                            weight: Font.Normal
                        }
                        Layout.leftMargin: checkIcon.implicitWidth + Theme.ui.padding.sm
                    }
                }
            }
        }
        ColumnLayout {
            visible: root.width < 450
            Layout.fillHeight: true
            Layout.preferredWidth: parent.width * 0.4

            RowLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignLeft
                Layout.rightMargin: Theme.ui.padding.sm

                property color healthColor: {
                    if (Power.healthPercentage >= 0.8) {
                        return Preferences.darkMode ? "#4a9d4a" : "#2d7a2d";
                    } else {
                        return Colors.error;
                    }
                }

                MaterialSymbol {
                    icon: "check_circle"
                    iconSize: Theme.font.size.xxl
                    fontColor: parent.healthColor
                }

                Text {
                    Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                    Layout.fillWidth: true
                    text: `Health ${Math.round(Power.healthPercentage * 100)}%`
                    color: parent.healthColor
                    wrapMode: Text.Wrap
                    font {
                        pixelSize: Theme.font.size.xl
                        family: Theme.font.family.inter_medium
                        weight: Font.Medium
                    }
                }
            }

            Text {
                text: Power.batteryChangeRateText

                color: Colors.secondary
                font {
                    pixelSize: Theme.font.size.md
                    family: Theme.font.family.inter_regular
                    weight: Font.Normal
                }
                Layout.leftMargin: checkIcon.implicitWidth + Theme.ui.padding.sm
            }
        }

        ColumnLayout {
            Layout.fillWidth: true

            spacing: Theme.ui.padding.md

            Text {
                text: "Power Profiles"
                font {
                    pixelSize: Theme.font.size.xl
                    family: Theme.font.family.inter_bold
                    weight: Font.Bold
                }

                antialiasing: true

                color: Colors.on_surface
            }

            PowerProfileButton {
                Layout.fillWidth: true
                Layout.preferredHeight: 48
                text: "Power Saver"
                icon: "energy_savings_leaf"

                checked: Power.currentProfile === "PowerSaver"

                onClicked: {
                    Power.setPowerProfile("PowerSaver");
                }
            }
            PowerProfileButton {
                Layout.fillWidth: true
                Layout.preferredHeight: 48
                text: "Balanced"
                icon: "donut_large"

                checked: Power.currentProfile === "Balanced"

                onClicked: {
                    Power.setPowerProfile("Balanced");
                }
            }
            PowerProfileButton {
                Layout.fillWidth: true
                Layout.preferredHeight: 48
                text: "Performance"
                icon: "speed"

                checked: Power.currentProfile === "Performance"

                onClicked: {
                    Power.setPowerProfile("Performance");
                }
            }
        }
        Item {
            Layout.fillHeight: true
        }
    }

    component PowerProfileButton: Rectangle {
        id: buttonRoot

        required property string icon
        required property string text
        signal clicked

        property bool checked: false

        property bool hovered: false

        function makeTranslucent(color) {
            return Qt.rgba(color.r, color.g, color.b, 0.4);
        }

        radius: Theme.ui.radius.md
        color: hovered || checked ? buttonRoot.makeTranslucent(Colors.primary_container) : buttonRoot.makeTranslucent(Colors.secondary_container)

        border {
            color: hovered || checked ? Colors.primary_container : Colors.secondary_container
        }

        Behavior on color {
            ColorAnimation {
                duration: 150
                easing.type: Easing.InOutQuad
            }
        }

        Behavior on border.color {
            ColorAnimation {
                duration: 150
                easing.type: Easing.InOutQuad
            }
        }

        Canvas {
            anchors.fill: parent
            antialiasing: true
            visible: opacity > 0
            opacity: buttonRoot.hovered || buttonRoot.checked ? 1 : 0

            Behavior on opacity {
                NumberAnimation {
                    duration: 150
                    easing.type: Easing.InOutQuad
                }
            }

            onPaint: {
                const ctx = getContext("2d");
                ctx.reset();

                ctx.strokeStyle = Colors.primary;
                ctx.lineWidth = 3;
                ctx.lineCap = "round";

                const lineY = 2;
                const lineWidth = this.width * 0.2;
                const startX = (this.width - lineWidth) / 2;
                const endX = startX + lineWidth;

                ctx.beginPath();
                ctx.moveTo(startX, lineY);
                ctx.lineTo(endX, lineY);
                ctx.stroke();
            }

            Component.onCompleted: requestPaint()
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: Theme.ui.padding.md
            anchors.rightMargin: Theme.ui.padding.md
            spacing: Theme.ui.padding.md

            MaterialSymbol {
                Layout.alignment: Qt.AlignVCenter
                icon: buttonRoot.icon
                iconSize: Theme.font.size.xl
                fontColor: buttonRoot.hovered ? Colors.on_primary_container : Colors.on_secondary_container

                Behavior on fontColor {
                    ColorAnimation {
                        duration: 150
                        easing.type: Easing.InOutQuad
                    }
                }
            }

            Text {
                Layout.alignment: Qt.AlignVCenter
                text: buttonRoot.text
                font.pixelSize: Theme.font.size.md
                font.weight: Font.Medium
                color: buttonRoot.hovered ? Colors.on_primary_container : Colors.on_secondary_container

                Behavior on color {
                    ColorAnimation {
                        duration: 150
                        easing.type: Easing.InOutQuad
                    }
                }
            }

            Item {
                Layout.fillWidth: true
            }
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            onClicked: buttonRoot.clicked()

            onEntered: {
                buttonRoot.hovered = true;
            }

            onExited: {
                buttonRoot.hovered = false;
            }
        }
    }
}
