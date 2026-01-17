import QtQuick
import QtQuick.Layouts

import qs.common
import qs.services

Rectangle {
    id: root
    color: contentBackground

    radius: Theme.ui.radius.md

    border {
        width: 0
        color: "transparent"
    }

    property bool showTitle: false
    property string title: ""
    property color contentBackground: Preferences.darkMode ? Colors.background : Colors.surface_variant

    default property alias content: contentRect.data

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
            color: Preferences.darkMode ? Qt.alpha(Colors.secondary_container, 0.2) : Qt.alpha(Colors.secondary_fixed_dim, 0.5)
            topRightRadius: Theme.ui.radius.md
            topLeftRadius: Theme.ui.radius.md

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
                color: Colors.on_secondary_container
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
            bottomLeftRadius: Theme.ui.radius.md
            bottomRightRadius: Theme.ui.radius.md
            topLeftRadius: root.showTitle ? 0 : Theme.ui.radius.md
            topRightRadius: root.showTitle ? 0 : Theme.ui.radius.md
            color: root.contentBackground

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
