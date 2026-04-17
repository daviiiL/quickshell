pragma ComponentBehavior: Bound

import QtQuick
import Qt5Compat.GraphicalEffects
import qs.common
import qs.services

Item {
    id: root
    width: parent.width
    property int total: 100
    property real value: 0
    property bool charging: false

    property color trackColor: Colors.secondaryContainer
    property color fillColor: Colors.primary
    property color lowFillColor: Colors.error
    property color chargingColor: Colors.success
    property color accentColor: Colors.primary

    readonly property real progressFraction: value / total

    Rectangle {
        id: background
        anchors.fill: parent
        color: Preferences.focusedMode ? "transparent" : root.trackColor
        anchors.leftMargin: Theme.ui.padding.sm
        anchors.rightMargin: Theme.ui.padding.sm
        radius: Preferences.focusedMode ? 1 : (Theme.ui.radius.lg - 2)
        antialiasing: true
        smooth: true

        border {
            width: Preferences.focusedMode ? 1 : 0
            color: Preferences.focusedMode ? Qt.alpha(root.accentColor, 0.4) : "transparent"
        }

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
                    color: root.chargingColor

                    property real animProgress: 0
                    width: parent.width * (root.progressFraction + animProgress * (1 - root.progressFraction))

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

                    anchors {
                        left: parent.left
                        top: parent.top
                        bottom: parent.bottom
                    }
                    width: parent.width * root.progressFraction
                    color: {
                        if (root.charging)
                            return root.chargingColor;
                        if (root.value <= root.total * 0.2)
                            return root.lowFillColor;
                        return root.fillColor;
                    }
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
                radius: Preferences.focusedMode ? 1 : Theme.ui.radius.md
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
