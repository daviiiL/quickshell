pragma ComponentBehavior: Bound

import QtQuick
import qs.common
import qs.widgets

// Sized by the GridView (168 x 150); content is inset 8px.
Item {
    id: root

    required property string fileName
    required property url fileUrl
    required property bool isDir
    property bool selected: false

    signal activated()

    readonly property bool hot: mouseArea.containsMouse
    readonly property int animMs: Theme.anim.durations.xs * 0.6

    Rectangle {
        id: frame
        x: 8
        y: 8
        width: parent.width - 16
        height: 100
        radius: Theme.ui.radius.md
        color: root.hot && !root.selected ? Colors.surfaceContainerHigh : Colors.surfaceContainerLow
        border.color: root.selected ? Colors.barAccent : (root.hot ? Colors.hairHot : Colors.hair)
        border.width: root.selected ? 2 : Theme.ui.mainBarHairWidth
        clip: true

        Behavior on color { ColorAnimation { duration: root.animMs } }
        Behavior on border.color { ColorAnimation { duration: root.animMs } }

        Image {
            id: thumb
            anchors.fill: parent
            anchors.margins: 2
            visible: !root.isDir
            source: root.isDir ? "" : root.fileUrl
            asynchronous: true
            cache: true
            smooth: true
            mipmap: false
            fillMode: Image.PreserveAspectCrop
            sourceSize.width: 320
            sourceSize.height: 200
            opacity: status === Image.Ready ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: Theme.anim.durations.xs } }
        }

        MaterialSymbol {
            anchors.centerIn: parent
            visible: root.isDir || thumb.status === Image.Error
            icon: root.isDir ? "folder" : "broken_image"
            iconSize: 28
            fontColor: root.isDir ? Colors.inkDim : Colors.inkFaint
            fill: root.isDir ? 1 : 0
        }

        Rectangle {
            visible: root.selected
            width: 18
            height: 18
            radius: 9
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.margins: 6
            color: Colors.barAccent
            border.color: Colors.panelBg
            border.width: 1.5

            MaterialSymbol {
                anchors.centerIn: parent
                icon: "check"
                iconSize: 12
                fontColor: Colors.panelBg
            }
        }
    }

    Text {
        anchors.top: frame.bottom
        anchors.topMargin: 7
        anchors.left: frame.left
        anchors.right: frame.right
        horizontalAlignment: Text.AlignHCenter
        text: root.fileName
        color: root.selected ? Colors.fgSurface : (root.isDir ? Colors.inkDim : Colors.inkDimmer)
        font.family: root.selected ? Theme.font.family.inter_medium : Theme.font.family.inter
        font.pixelSize: Theme.font.size.caption
        font.weight: root.selected ? Font.Medium : Font.Normal
        elide: Text.ElideMiddle
        maximumLineCount: 1
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.activated()
    }
}
