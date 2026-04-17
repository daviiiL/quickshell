import QtQuick
import Quickshell
import Quickshell.Io
import qs.common
import qs.widgets

StyledImage {
    id: root

    property bool generateThumbnail: true
    required property string sourcePath
    property string thumbnailSizeName: Images.thumbnailSizeNameForDimensions(sourceSize.width, sourceSize.height)
    property string thumbnailPath: {
        if (sourcePath.length == 0)
            return "";
        const resolvedUrlWithoutFileProtocol = FileUtils.trimFileProtocol(`${Qt.resolvedUrl(sourcePath)}`);
        const encodedUrlWithoutFileProtocol = resolvedUrlWithoutFileProtocol.split("/").map(part => encodeURIComponent(part)).join("/");
        const md5Hash = Qt.md5(`file://${encodedUrlWithoutFileProtocol}`);
        const cacheDir = `${Quickshell.env("HOME")}/.cache`;
        return `${cacheDir}/thumbnails/${thumbnailSizeName}/${md5Hash}.png`;
    }

    // Deferred: actual source is assigned only after the existence check below succeeds,
    // so Image doesn't emit a load warning for a path that may not exist yet.
    source: ""

    smooth: true
    mipmap: false

    Component.onCompleted: checkAndLoadThumbnail()
    onThumbnailPathChanged: checkAndLoadThumbnail()

    function checkAndLoadThumbnail() {
        thumbnailCheckProc.running = false;
        thumbnailCheckProc.running = true;
    }

    Process {
        id: thumbnailCheckProc
        command: ["test", "-f", FileUtils.trimFileProtocol(root.thumbnailPath)]
        onExited: exitCode => {
            if (exitCode === 0)
                root.source = root.thumbnailPath;
            else if (root.generateThumbnail)
                thumbnailGeneration.running = true;
        }
    }

    Process {
        id: thumbnailGeneration
        command: {
            const maxSize = Images.thumbnailSizes[root.thumbnailSizeName];
            const cacheDir = `${Quickshell.env("HOME")}/.cache`;
            return ["bash", "-c", `mkdir -p '${cacheDir}/thumbnails/${root.thumbnailSizeName}' && magick '${root.sourcePath}' -resize ${maxSize}x${maxSize} '${FileUtils.trimFileProtocol(root.thumbnailPath)}'`];
        }
        onExited: exitCode => {
            if (exitCode === 0) {
                // Reset then reassign to force the Image to reload from disk.
                root.source = "";
                root.source = root.thumbnailPath;
            }
        }
    }
}
