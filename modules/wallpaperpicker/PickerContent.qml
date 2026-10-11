pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Qt.labs.folderlistmodel
import qs.common
import qs.services

ColumnLayout {
    id: root

    property string requestedDir: ""

    signal closeRequested()

    readonly property string homeDir: Quickshell.env("HOME")
    readonly property string currentWallpaper: Preferences.wallpaperPath

    spacing: 0

    Component.onCompleted: {
        console.log("[WallpaperPicker.content] loaded");
        root.resolveStartDir();
    }
    Component.onDestruction: console.log("[WallpaperPicker.content] unloaded")

    // Existence is probed in a Process: FolderListModel silently falls back to cwd for a missing folder.
    function resolveStartDir(): void {
        let candidate = root.requestedDir;
        if (candidate.length === 0 && root.currentWallpaper.length > 0 && root.currentWallpaper !== Preferences.defaultWallpaperPath)
            candidate = FileUtils.parentDirectory(root.currentWallpaper);
        startDirProc.command = ["sh", "-c", 'd="$1"; [ -n "$d" ] && [ -d "$d" ] && printf %s "$d" || printf %s "$HOME"', "_", candidate];
        startDirProc.running = true;
    }

    Process {
        id: startDirProc
        stdout: StdioCollector {
            onStreamFinished: {
                const dir = this.text.trim();
                nav.reset(dir.length > 0 ? dir : root.homeDir);
            }
        }
    }

    PickerNav { id: nav }

    FolderListModel {
        id: folderModel
        folder: nav.current.length > 0 ? FileUtils.toFileUrl(nav.current) : ""
        nameFilters: ["*.jpg", "*.jpeg", "*.png", "*.webp"]
        caseSensitive: false
        showDirs: true
        showDirsFirst: true
        showDotAndDotDot: false
        showHidden: false
        showOnlyReadable: true
        sortField: FolderListModel.Name
    }

    function activate(filePath: string, isDir: bool): void {
        if (isDir) {
            nav.go(filePath);
            grid.contentY = 0;
        } else {
            Wallpapers.applyCurrent(filePath);
        }
    }

    Keys.onPressed: event => {
        if (event.key === Qt.Key_Escape) {
            root.closeRequested();
            event.accepted = true;
        } else if (event.key === Qt.Key_Left && (event.modifiers & Qt.AltModifier)) {
            nav.back();
            event.accepted = true;
        } else if (event.key === Qt.Key_Right && (event.modifiers & Qt.AltModifier)) {
            nav.forward();
            event.accepted = true;
        } else if (event.key === Qt.Key_Backspace) {
            nav.up();
            event.accepted = true;
        }
    }

    PickerHeader {
        Layout.fillWidth: true
        nav: nav
        homeDir: root.homeDir
        onCloseRequested: root.closeRequested()
    }

    Item {
        Layout.fillWidth: true
        Layout.fillHeight: true

        GridView {
            id: grid
            anchors.fill: parent
            anchors.margins: 14
            clip: true
            cellWidth: 168
            cellHeight: 150
            cacheBuffer: cellHeight * 2
            boundsBehavior: Flickable.StopAtBounds
            // null until the start-dir probe sets nav.current, so an empty folder never lists the cwd.
            model: nav.current.length > 0 ? folderModel : null

            delegate: PickerTile {
                id: tile
                required property string filePath
                required property bool fileIsDir

                width: grid.cellWidth
                height: grid.cellHeight
                isDir: tile.fileIsDir
                selected: !tile.fileIsDir && tile.filePath === root.currentWallpaper
                onActivated: root.activate(tile.filePath, tile.fileIsDir)
            }
        }

        Column {
            anchors.centerIn: parent
            spacing: 6
            visible: nav.current.length > 0 && folderModel.status !== FolderListModel.Loading && folderModel.count === 0

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "No images here"
                color: Colors.inkDim
                font.family: Theme.font.family.inter_medium
                font.pixelSize: Theme.font.size.body
                font.weight: Font.Medium
            }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "JPG, PNG and WEBP files show up in this view"
                color: Colors.inkFaint
                font.family: Theme.font.family.inter
                font.pixelSize: Theme.font.size.caption
                font.letterSpacing: 0.3
            }
        }
    }
}
