pragma ComponentBehavior: Bound

import QtQuick
import Qt5Compat.GraphicalEffects

import qs.common
import qs.services

Item {
    id: root
    anchors.fill: parent

    default property alias text: titleText.text

    property color bgColor: Preferences.focusedMode ? Qt.alpha(Colors.surface, 0.3) : makeTranslucent(Colors.surface)
    property color fgColor: Colors.primary
    property real max: 100
    property real value: 0
    function makeTranslucent(color) {
        return Qt.alpha(color, 0.8);
    }

    property int borderRadius: Preferences.focusedMode ? 2 : Theme.ui.radius.md

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

        color: Colors.primary
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
        color: root.bgColor
        border.color: Preferences.focusedMode ? Qt.alpha(Colors.primary, 0.6) : Colors.primary_container
        border.width: 1
        radius: root.borderRadius
        antialiasing: true
        smooth: true

        anchors.margins: Theme.ui.padding.sm

        Rectangle {
            visible: Preferences.focusedMode
            width: 10
            height: 1
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.topMargin: -0.5
            anchors.leftMargin: 10
            color: Colors.primary
            opacity: 0.8
        }
        Rectangle {
            visible: Preferences.focusedMode
            width: 10
            height: 1
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            anchors.bottomMargin: -0.5
            anchors.rightMargin: 10
            color: Colors.primary
            opacity: 0.8
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
                    id: progress
                    anchors {
                        top: parent.top
                        left: parent.left
                        bottom: parent.bottom
                    }

                    width: parent.width * (root.value / root.max)
                    color: root.fgColor

                    Behavior on width {
                        NumberAnimation {
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
                radius: root.borderRadius
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
