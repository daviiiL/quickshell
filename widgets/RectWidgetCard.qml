import QtQuick
import QtQuick.Layouts

import qs.common
import qs.services

Rectangle {
    id: root

    readonly property int focusedRadius: 2
    readonly property int normalRadius: Theme.ui.radius.md
    readonly property int activeRadius: Preferences.focusedMode ? focusedRadius : normalRadius

    property bool showTitle: false
    property string title: ""

    property color contentBackground: Colors.surfaceVariant
    property color accentColor: Colors.primary
    property color titleColor: Colors.onSecondaryContainer
    property color titleBg: Qt.alpha(Colors.secondaryContainer, 0.2)

    default property alias content: contentRect.data

    color: Preferences.focusedMode ? "transparent" : contentBackground
    radius: activeRadius

    border {
        width: Preferences.focusedMode ? 1 : 0
        color: Preferences.focusedMode ? Qt.alpha(root.accentColor, 0.5) : "transparent"
    }

    Rectangle {
        visible: Preferences.focusedMode
        width: 6
        height: 1
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: -0.5
        anchors.rightMargin: 4
        color: root.accentColor
        opacity: 0.8
    }

    implicitHeight: (showTitle ? 30 : 0) + contentRect.implicitHeight

    Behavior on implicitHeight {
        NumberAnimation {
            duration: Theme.anim.durations.sm
            easing.type: Easing.OutCubic
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            id: titleRect
            visible: root.showTitle
            opacity: root.showTitle ? 1.0 : 0.0
            Layout.fillWidth: true
            Layout.preferredHeight: root.showTitle ? 30 : 0
            color: Preferences.focusedMode ? Qt.alpha(Colors.surface, 0.3) : root.titleBg
            topRightRadius: root.activeRadius
            topLeftRadius: root.activeRadius

            Behavior on color {
                ColorAnimation {
                    duration: Theme.anim.durations.sm
                }
            }

            Behavior on opacity {
                NumberAnimation {
                    duration: Theme.anim.durations.sm
                    easing.type: Easing.OutCubic
                }
            }

            Behavior on Layout.preferredHeight {
                NumberAnimation {
                    duration: Theme.anim.durations.sm
                    easing.type: Easing.OutCubic
                }
            }

            Layout.alignment: Qt.AlignTop

            Text {
                anchors.centerIn: parent
                text: root.title
                color: root.titleColor
                font.family: Theme.font.family.inter_thin
                font.pixelSize: Theme.font.size.md
                renderType: Text.QtRendering
                renderTypeQuality: Text.HighRenderTypeQuality
            }
        }

        Rectangle {
            id: contentRect
            Layout.fillWidth: true
            implicitHeight: childrenRect.height
            Layout.preferredHeight: implicitHeight
            bottomLeftRadius: root.activeRadius
            bottomRightRadius: root.activeRadius
            topLeftRadius: root.showTitle ? 0 : root.activeRadius
            topRightRadius: root.showTitle ? 0 : root.activeRadius
            color: Preferences.focusedMode ? Qt.alpha(Colors.surface, 0.3) : root.contentBackground

            Behavior on color {
                ColorAnimation {
                    duration: Theme.anim.durations.sm
                }
            }

            Behavior on topLeftRadius {
                NumberAnimation {
                    duration: Theme.anim.durations.sm
                    easing.type: Easing.OutCubic
                }
            }

            Behavior on topRightRadius {
                NumberAnimation {
                    duration: Theme.anim.durations.sm
                    easing.type: Easing.OutCubic
                }
            }
        }
    }
}
