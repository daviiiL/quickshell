pragma ComponentBehavior: Bound

import QtQuick
import Qt5Compat.GraphicalEffects

import qs.common
import qs.services

Item {
    id: root
    anchors.fill: parent

    default property alias text: titleText.text

    property real max: 100
    property real value: 0
    function makeTranslucent(color) {
        return Qt.rgba(color.r, color.g, color.b, 0.4);
    }

    Text {
        id: titleText
        anchors {
            right: background.left
            top: parent.top
            bottom: parent.bottom
        }

        verticalAlignment: Text.AlignVCenter
        font {
            pixelSize: Theme.font.size.lg
            family: Theme.font.family.inter_semi_bold
        }

        color: Colors.on_surface
        antialiasing: true
        anchors.rightMargin: Theme.ui.padding.sm
    }

    Rectangle {
        id: background
        anchors {
            top: parent.top
            bottom: parent.bottom
            horizontalCenter: parent.horizontalCenter
        }

        implicitWidth: Math.min(500, parent.width)
        color: root.makeTranslucent(Colors.primary_container)
        border.color: Colors.primary_container
        radius: Theme.ui.radius.md
        antialiasing: true
        smooth: true

        anchors.margins: Theme.ui.padding.sm

        Item {
            id: progressContainer
            anchors.fill: parent
            anchors.margins: 2

            Item {
                id: progressLayer
                anchors.fill: parent
                layer.enabled: true
                visible: false

                Rectangle {
                    id: progress
                    anchors {
                        top: parent.top
                        left: parent.left
                        bottom: parent.bottom
                    }

                    width: parent.width * (root.value / root.max)
                    color: Colors.primary

                    Behavior on width {
                        NumberAnimation {
                            duration: Theme.anim.durations.md
                            easing.type: Easing.Bezier
                            easing.bezierCurve: Theme.anim.curves.standard
                        }
                    }
                }
            }

            Rectangle {
                id: mask
                anchors.fill: parent
                radius: Theme.ui.radius.md
                antialiasing: true
                visible: false
            }

            OpacityMask {
                anchors.fill: parent
                source: progressLayer
                maskSource: mask
                smooth: true
            }
        }
    }
}
