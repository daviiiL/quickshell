pragma ComponentBehavior: Bound

import QtQuick
import Qt5Compat.GraphicalEffects
import qs.common

Item {
    id: root
    width: parent.width
    property int total: 100
    property real value: 0
    property bool charging: false

    Rectangle {
        id: background
        anchors.fill: parent
        color: Colors.surface_container
        anchors.leftMargin: Theme.ui.padding.sm
        anchors.rightMargin: Theme.ui.padding.sm
        radius: Theme.ui.radius.md
        antialiasing: true
        smooth: true


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
                    id: chargingPreview
                    visible: root.charging
                    anchors {
                        left: parent.left
                        top: parent.top
                        bottom: parent.bottom
                    }
                    color: "#4a9d4a"

                    property real animProgress: 0
                    width: parent.width * ((root.value / root.total) + animProgress * (1 - root.value / root.total))

                    SequentialAnimation on animProgress {
                        running: root.charging
                        loops: Animation.Infinite
                        NumberAnimation {
                            from: 0
                            to: 1
                            duration: Theme.anim.durations.xl
                            easing.type: Easing.Bezier
                            easing.bezierCurve: Theme.anim.curves.emphasized
                        }
                        NumberAnimation {
                            from: 1
                            to: 0
                            duration: Theme.anim.durations.xl
                            easing.type: Easing.Bezier
                            easing.bezierCurve: Theme.anim.curves.emphasized
                        }
                    }
                }

                Rectangle {
                    id: progress

                    readonly property color successColor: "#4a9d4a"
                    readonly property color warningColor: "#ffd4ab"

                    anchors {
                        left: parent.left
                        top: parent.top
                        bottom: parent.bottom
                    }
                    width: parent.width * (root.value / root.total)
                    color: root.charging ? successColor : root.value <= (root.total * 0.2) ? Colors.error : root.value <= (root.total * 0.8) ? Colors.primary : successColor

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
