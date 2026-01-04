pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick
import Qt.labs.folderlistmodel
import Quickshell
import Quickshell.Io

import qs.common
import qs.common.models
import qs.services

Singleton {
    id: root

    readonly property string homeDir: Quickshell.env("HOME")
    readonly property string picturesDir: `${homeDir}/Pictures`
    readonly property string scriptsDir: `${homeDir}/.config/quickshell/scripts`
    readonly property string thumbnailScriptPath: `${scriptsDir}/thumbnails/generate-thumbnails.sh`
    readonly property string wallpaperSwitchScriptPath: `${scriptsDir}/wallpaper/switch_wall.sh`

    property alias directory: folderModel.folder
    readonly property string effectiveDirectory: FileUtils.trimFileProtocol(folderModel.folder.toString())
    property url defaultFolder: defaultFolderProc.defaultFolder
    property alias folderModel: folderModel
    property string searchQuery: ""
    property string matugenScheme: Preferences.matugenScheme || "scheme-tonal-spot"
    property string darkMode: Preferences.darkMode ? "dark" : "light" || "dark"

    readonly property list<string> extensions: ["jpg", "jpeg", "png", "webp", "avif", "bmp", "svg"]

    property list<string> wallpapers: []

    readonly property bool thumbnailGenerationRunning: thumbgenProc.running
    property real thumbnailGenerationProgress: 0

    signal changed
    signal thumbnailGenerated(directory: string)
    signal thumbnailGeneratedFile(filePath: string)

    function load() {
    }
    QtObject {
        id: defaultFolderProc
        property url defaultFolder: Qt.resolvedUrl(root.homeDir)

        Component.onCompleted: {
            checkDefaultFolderProc.exec(["test", "-d", `${root.picturesDir}/wallpapers`]);
        }
    }

    Process {
        id: checkDefaultFolderProc
        onExited: (exitCode, exitStatus) => {
            if (exitCode === 0) {
                defaultFolderProc.defaultFolder = Qt.resolvedUrl(`${root.picturesDir}/wallpapers`);
            } else {
                defaultFolderProc.defaultFolder = Qt.resolvedUrl(root.homeDir);
            }
        }
    }

    function apply(path) {
        if (!path || path.length === 0)
            return;

        // console.debug(`Applying wallpaper ${path}`);
        applyProc.exec([wallpaperSwitchScriptPath, path]);
        Preferences.setWallpaperPath(path);
        root.changed();
    }

    function applyWithCurPreferences(path: string, isDarkMode: bool, scheme: string): void {
        if (!path || path.length === 0)
            return;

        console.debug(`Applying wallpaper ${path} with current preferences: darkMode=${isDarkMode}, scheme=${scheme}`);
        applyProc.exec([wallpaperSwitchScriptPath, "--scheme", scheme, "--mode", isDarkMode ? "dark" : "light", path]);
        Preferences.setWallpaperPath(path);
        root.changed();
    }

    Process {
        id: applyProc
    }

    Process {
        id: selectProc
        property string filePath: ""
        function select(filePath) {
            selectProc.filePath = filePath;
            selectProc.exec(["test", "-d", FileUtils.trimFileProtocol(filePath)]);
        }
        onExited: (exitCode, exitStatus) => {
            if (exitCode === 0) {
                root.setDirectory(selectProc.filePath);
                return;
            }
            root.apply(selectProc.filePath);
        }
    }

    function select(filePath) {
        selectProc.select(filePath);
    }

    function randomFromCurrentFolder() {
        if (folderModel.count === 0)
            return;
        const randomIndex = Math.floor(Math.random() * folderModel.count);
        const filePath = folderModel.get(randomIndex, "filePath");
        root.select(filePath);
    }

    Process {
        id: validateDirProc
        property string nicePath: ""
        function setDirectoryIfValid(path) {
            validateDirProc.nicePath = FileUtils.trimFileProtocol(path).replace(/\/+$/, "");
            if (/^\/*$/.test(validateDirProc.nicePath))
                validateDirProc.nicePath = "/";
            validateDirProc.exec(["bash", "-c", `if [ -d "${validateDirProc.nicePath}" ]; then echo dir; elif [ -f "${validateDirProc.nicePath}" ]; then echo file; else echo invalid; fi`]);
        }
        stdout: SplitParser {
            onRead: data => {
                root.directory = Qt.resolvedUrl(validateDirProc.nicePath);
                const result = data.trim();
                if (result === "dir") {
                    root.directory = Qt.resolvedUrl(validateDirProc.nicePath);
                } else if (result === "file") {
                    root.directory = Qt.resolvedUrl(FileUtils.parentDirectory(validateDirProc.nicePath));
                }
            }
        }
    }

    function setDirectory(path) {
        validateDirProc.setDirectoryIfValid(path);
    }

    function navigateUp() {
        folderModel.navigateUp();
    }

    function navigateBack() {
        folderModel.navigateBack();
    }

    function navigateForward() {
        folderModel.navigateForward();
    }

    FolderListModelWithHistory {
        id: folderModel
        folder: Qt.resolvedUrl(root.defaultFolder)
        caseSensitive: false
        nameFilters: root.extensions.map(ext => `*${root.searchQuery.split(" ").filter(s => s.length > 0).map(s => `*${s}*`)}*.${ext}`)
        showDirs: true
        showDotAndDotDot: false
        showOnlyReadable: true
        sortField: FolderListModel.Time
        sortReversed: false
        onCountChanged: {
            root.wallpapers = [];
            for (let i = 0; i < folderModel.count; i++) {
                const path = folderModel.get(i, "filePath") || FileUtils.trimFileProtocol(folderModel.get(i, "fileURL"));
                if (path && path.length)
                    root.wallpapers.push(path);
            }
        }
    }

    function generateThumbnail(size: string) {
        if (!["normal", "large", "x-large", "xx-large"].includes(size)) {
            console.error("Invalid thumbnail size:", size);
            return;
        }
        thumbgenProc.directory = root.directory;
        thumbgenProc.running = false;
        thumbgenProc.command = ["bash", thumbnailScriptPath, "--size", size, "--machine_progress", "-d", FileUtils.trimFileProtocol(root.directory)];
        root.thumbnailGenerationProgress = 0;
        thumbgenProc.running = true;
    }

    Process {
        id: thumbgenProc
        property string directory
        stdout: SplitParser {
            onRead: data => {
                let match = data.match(/PROGRESS (\d+)\/(\d+)/);
                if (match) {
                    const completed = parseInt(match[1]);
                    const total = parseInt(match[2]);
                    root.thumbnailGenerationProgress = completed / total;
                }
                match = data.match(/FILE (.+)/);
                if (match) {
                    const filePath = match[1];
                    root.thumbnailGeneratedFile(filePath);
                }
            }
        }
        onExited: (exitCode, exitStatus) => {
            root.thumbnailGenerated(thumbgenProc.directory);
        }
    }
}
