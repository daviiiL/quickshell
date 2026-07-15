pragma Singleton

import Quickshell

Singleton {
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
