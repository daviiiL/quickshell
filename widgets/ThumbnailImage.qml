import QtQuick
import Quickshell
import Quickshell.Io
import qs.common
import qs.widgets

/**
 * Thumbnail image component that follows the FreeDesktop.org thumbnail specification
 * https://specifications.freedesktop.org/thumbnail-spec/thumbnail-spec-latest.html
 *
 * Automatically generates thumbnails on-demand using ImageMagick if they don't exist.
 * Thumbnails are cached in ~/.cache/thumbnails/<size>/<md5hash>.png
 */
StyledImage {
    id: root

    property bool generateThumbnail: true
    required property string sourcePath
    property string thumbnailSizeName: Images.thumbnailSizeNameForDimensions(sourceSize.width, sourceSize.height)
    property string thumbnailPath: {
        if (sourcePath.length == 0) return "";
        const resolvedUrlWithoutFileProtocol = FileUtils.trimFileProtocol(`${Qt.resolvedUrl(sourcePath)}`);
        const encodedUrlWithoutFileProtocol = resolvedUrlWithoutFileProtocol.split("/").map(part => encodeURIComponent(part)).join("/");
        const md5Hash = Qt.md5(`file://${encodedUrlWithoutFileProtocol}`);
        const cacheDir = `${Quickshell.env("HOME")}/.cache`;
        return `${cacheDir}/thumbnails/${thumbnailSizeName}/${md5Hash}.png`;
    }

    // Check if thumbnail exists before loading to avoid warnings
    source: ""

    smooth: true
    mipmap: false

    Component.onCompleted: {
        checkAndLoadThumbnail();
    }

    onSourceSizeChanged: {
        checkAndLoadThumbnail();
    }

    function checkAndLoadThumbnail() {
        thumbnailCheckProc.running = false;
        thumbnailCheckProc.running = true;
    }

    Process {
        id: thumbnailCheckProc
        command: ["test", "-f", FileUtils.trimFileProtocol(root.thumbnailPath)]
        onExited: exitCode => {
            if (exitCode === 0) {
                // Thumbnail exists, load it
                root.source = root.thumbnailPath;
            } else if (root.generateThumbnail) {
                // Thumbnail doesn't exist and we should generate it
                thumbnailGeneration.running = true;
            }
            // If exitCode !== 0 and !generateThumbnail, do nothing (no warning)
        }
    }

    Process {
        id: thumbnailGeneration
        command: {
            const maxSize = Images.thumbnailSizes[root.thumbnailSizeName];
            const cacheDir = `${Quickshell.env("HOME")}/.cache`;
            return ["bash", "-c",
                `mkdir -p '${cacheDir}/thumbnails/${root.thumbnailSizeName}' && magick '${root.sourcePath}' -resize ${maxSize}x${maxSize} '${FileUtils.trimFileProtocol(root.thumbnailPath)}'`
            ]
        }
        onExited: exitCode => {
            if (exitCode === 0) {
                root.source = "";
                root.source = root.thumbnailPath; // Force reload
            }
        }
    }
}
