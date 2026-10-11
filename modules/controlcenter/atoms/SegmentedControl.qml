pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.common

Rectangle {
    id: root

    property var options: []
    property string current: ""

    signal selected(string id)

    readonly property int animMs: Theme.anim.durations.xs * 0.6

    implicitWidth: row.implicitWidth
    implicitHeight: 26
    radius: Theme.ui.radius.sm
    color: Colors.surfaceContainer
    border.color: Colors.hair
    border.width: Theme.ui.mainBarHairWidth
    clip: true

    RowLayout {
        id: row
        anchors.fill: parent
        spacing: 0

        Repeater {
            model: root.options

            Rectangle {
                id: seg
                required property var modelData
                required property int index

                readonly property bool on: seg.modelData.id === root.current
                readonly property bool hot: segMouse.containsMouse

                Layout.fillHeight: true
                implicitWidth: segText.implicitWidth + 24
                color: seg.on ? Colors.surfaceContainerHigh : (seg.hot ? Qt.alpha(Colors.fgSurface, 0.03) : "transparent")
                Behavior on color { ColorAnimation { duration: root.animMs } }

                Rectangle {
                    visible: seg.index > 0
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: Theme.ui.mainBarHairWidth
                    color: Colors.hair
                }

                Text {
                    id: segText
                    anchors.centerIn: parent
                    text: seg.modelData.label
                    color: seg.on ? Colors.fgSurface : Colors.inkDim
                    font.family: Theme.font.family.inter_medium
                    font.pixelSize: Theme.font.size.caption
                    font.weight: Font.Medium
                    Behavior on color { ColorAnimation { duration: root.animMs } }
                }

                MouseArea {
                    id: segMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: { if (!seg.on) root.selected(seg.modelData.id) }
                }
            }
        }
    }
}
