pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.common
import qs.services
import qs.widgets

Rectangle {
    id: root

    signal activated()

    readonly property string homeDir: Quickshell.env("HOME")
    readonly property string path: Preferences.wallpaperPath.length > 0 ? Preferences.wallpaperPath : Preferences.defaultWallpaperPath
    readonly property string fileName: root.path.split("/").pop()
    readonly property string folder: {
        const dir = FileUtils.parentDirectory(root.path);
        if (dir === root.homeDir) return "~";
        if (dir.startsWith(root.homeDir + "/")) return "~" + dir.slice(root.homeDir.length);
        return dir;
    }

    readonly property bool hot: mouseArea.containsMouse
    readonly property int animMs: Theme.anim.durations.xs * 0.6

    Layout.fillWidth: true
    implicitHeight: 64

    color: root.hot ? Qt.alpha(Colors.fgSurface, 0.03) : "transparent"
    Behavior on color { ColorAnimation { duration: root.animMs } }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 14
        anchors.rightMargin: 14
        spacing: 12

        Rectangle {
            Layout.preferredWidth: 72
            Layout.preferredHeight: 44
            Layout.alignment: Qt.AlignVCenter
            radius: Theme.ui.radius.sm
            color: Colors.surfaceContainer
            border.color: root.hot ? Colors.hairHot : Colors.hair
            border.width: Theme.ui.mainBarHairWidth
            clip: true

            Image {
                anchors.fill: parent
                anchors.margins: 1
                source: root.path.length > 0 ? FileUtils.toFileUrl(root.path) : ""
                asynchronous: true
                cache: true
                smooth: true
                fillMode: Image.PreserveAspectCrop
                sourceSize.width: 160
                sourceSize.height: 100
                opacity: status === Image.Ready ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: Theme.anim.durations.xs } }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 1

            Text {
                Layout.fillWidth: true
                text: root.fileName
                color: Colors.fgSurface
                font.family: Theme.font.family.inter_medium
                font.pixelSize: Theme.font.size.body
                font.weight: Font.Medium
                elide: Text.ElideMiddle
            }

            Text {
                Layout.fillWidth: true
                text: root.folder
                color: Colors.inkDimmer
                font.family: Theme.font.family.inter
                font.pixelSize: Theme.font.size.caption
                elide: Text.ElideLeft
            }
        }

        Text {
            Layout.alignment: Qt.AlignVCenter
            text: "Change"
            color: root.hot ? Colors.fgSurface : Colors.inkDim
            font.family: Theme.font.family.inter
            font.pixelSize: Theme.font.size.body
            Behavior on color { ColorAnimation { duration: root.animMs } }
        }

        MaterialSymbol {
            Layout.alignment: Qt.AlignVCenter
            icon: "chevron_right"
            iconSize: 14
            fontColor: Colors.inkFaint
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.activated()
    }
}
