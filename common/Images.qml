pragma Singleton

import Quickshell

Singleton {
    // Supported image formats
    readonly property list<string> validImageTypes: ["jpeg", "png", "webp", "tiff", "svg"]
    readonly property list<string> validImageExtensions: ["jpg", "jpeg", "png", "webp", "tif", "tiff", "svg"]

    function isValidImageByName(name: string): bool {
        return validImageExtensions.some(t => name.endsWith(`.${t}`));
    }

    // Thumbnail bucket sizes per freedesktop thumbnail spec:
    // https://specifications.freedesktop.org/thumbnail-spec/latest/directory.html
    readonly property var thumbnailSizes: ({
            "normal": 128,
            "large": 256,
            "x-large": 512,
            "xx-large": 1024
        })

    function thumbnailSizeNameForDimensions(width: int, height: int): string {
        for (const sizeName of Object.keys(thumbnailSizes)) {
            const maxSize = thumbnailSizes[sizeName];
            if (width <= maxSize && height <= maxSize)
                return sizeName;
        }
        return "xx-large";
    }
}
