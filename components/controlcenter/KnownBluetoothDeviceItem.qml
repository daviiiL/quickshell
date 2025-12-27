pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell.Bluetooth

import qs.common
import qs.services
import qs.widgets

Rectangle {
    id: knownItem
    required property BluetoothDevice device
    height: 60
    radius: Theme.ui.radius.md
    color: knownMouseArea.containsMouse || unpairMouseArea.containsMouse ? Colors.surface_container_high : Colors.surface_container

    Behavior on color {
        ColorAnimation {
            duration: Theme.anim.durations.sm
            easing.type: Easing.Bezier
            easing.bezierCurve: Theme.anim.curves.emphasized
        }
    }

    MouseArea {
        id: knownMouseArea
        anchors.fill: parent
        hoverEnabled: true
        z: -1
        onClicked: {
            Bluetooth.connectDevice(knownItem.device);
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: Theme.ui.padding.md
        spacing: Theme.ui.padding.md

        MaterialSymbol {
            icon: {
                const type = knownItem.device?.type ?? "";
                if (type.includes("audio") || type.includes("headset") || type.includes("headphone"))
                    return "headphones";
                if (type.includes("phone"))
                    return "phone_android";
                if (type.includes("computer"))
                    return "computer";
                if (type.includes("keyboard"))
                    return "keyboard";
                if (type.includes("mouse"))
                    return "mouse";
                return "bluetooth";
            }
            fontColor: Colors.on_surface_variant
            iconSize: Theme.font.size.xl
        }

        Text {
            Layout.fillWidth: true
            text: knownItem.device?.name ?? "Unknown Device"
            font {
                pixelSize: Theme.font.size.md
                family: Theme.font.family.inter_regular
            }
            color: Colors.on_surface
            elide: Text.ElideRight
        }

        Rectangle {
            Layout.alignment: Qt.AlignRight
            Layout.preferredHeight: icon.implicitHeight + 4
            Layout.preferredWidth: icon.implicitWidth + 4
            radius: Theme.ui.radius.md
            color: unpairMouseArea.containsMouse ? Colors.error_container : "transparent"

            MaterialSymbol {
                id: icon
                anchors.centerIn: parent
                icon: "delete"
                fontColor: Colors.on_surface
                iconSize: 15
                animated: true
                colorAnimated: true
            }

            MouseArea {
                id: unpairMouseArea
                anchors.fill: parent
                hoverEnabled: true
                onClicked: {
                    Bluetooth.unpairDevice(knownItem.device);
                }
            }
        }
    }
}
