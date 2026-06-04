pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.common
import qs.widgets

Item {
    id: root

    property string iconSymbol: ""
    property url iconImage: ""
    required property string label
    property string sub: ""
    property real value: 0
    property bool available: true
    property real trackWidth: 220
    property bool showSeparator: false

    signal moved(real v)

    Layout.fillWidth: true
    implicitHeight: 44

    readonly property real progress: Math.max(0, Math.min(1, root.value))
    readonly property bool hot: drag.containsMouse || drag.pressed

    opacity: root.available ? 1.0 : 0.45
    Behavior on opacity { NumberAnimation { duration: Theme.anim.durations.xs * 0.6 } }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 14
        anchors.rightMargin: 14
        spacing: 12

        Rectangle {
            Layout.preferredWidth: 26
            Layout.preferredHeight: 26
            Layout.alignment: Qt.AlignVCenter
            radius: 3
            color: Colors.surfaceContainer
            border.color: Colors.hair
            border.width: Theme.ui.mainBarHairWidth

            Image {
                id: appIcon
                anchors.centerIn: parent
                width: 18
                height: 18
                sourceSize.width: 18
                sourceSize.height: 18
                fillMode: Image.PreserveAspectFit
                smooth: true
                source: root.iconImage
                visible: root.iconImage != "" && status === Image.Ready
            }

            MaterialSymbol {
                anchors.centerIn: parent
                visible: !appIcon.visible
                icon: root.iconSymbol
                iconSize: 13
                fontColor: Colors.inkDim
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 1

            Text {
                Layout.fillWidth: true
                text: root.label
                color: Colors.fgSurface
                font.family: Theme.font.family.inter
                font.pixelSize: 12
                elide: Text.ElideRight
            }

            Text {
                visible: root.sub.length > 0
                Layout.fillWidth: true
                text: root.sub
                color: Colors.inkDimmer
                font.family: Theme.font.family.inter
                font.pixelSize: 10
                font.letterSpacing: 0.2
                elide: Text.ElideRight
            }
        }

        Item {
            id: track
            Layout.preferredWidth: root.trackWidth
            Layout.preferredHeight: 14
            Layout.alignment: Qt.AlignVCenter

            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.right: parent.right
                height: 4
                radius: 2
                color: Colors.surfaceContainer
            }

            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                width: root.progress * parent.width
                height: 4
                radius: 2
                color: Colors.barAccent
            }

            Rectangle {
                width: 12
                height: 12
                radius: 6
                color: Colors.fgSurface
                anchors.verticalCenter: parent.verticalCenter
                x: root.progress * (parent.width - width)
                visible: root.hot
            }

            MouseArea {
                id: drag
                anchors.fill: parent
                hoverEnabled: root.available
                acceptedButtons: Qt.LeftButton
                cursorShape: root.available ? Qt.PointingHandCursor : Qt.ArrowCursor
                onPressed: mouse => { if (root.available) root.commit(mouse.x) }
                onPositionChanged: mouse => { if (root.available && pressed) root.commit(mouse.x) }
            }
        }

        Text {
            Layout.preferredWidth: 32
            Layout.alignment: Qt.AlignVCenter
            horizontalAlignment: Text.AlignRight
            text: Math.round(root.progress * 100) + "%"
            color: Colors.inkDim
            font.family: Theme.font.family.inter
            font.pixelSize: 11
            font.letterSpacing: 0.2
        }
    }

    Rectangle {
        visible: root.showSeparator
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: Theme.ui.mainBarHairWidth
        color: Colors.hair
    }

    function commit(x: real): void {
        const t = Math.max(0, Math.min(1, x / track.width));
        root.moved(t);
    }
}
