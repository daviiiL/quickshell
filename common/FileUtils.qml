pragma Singleton
import Quickshell

Singleton {
    id: root

    function trimFileProtocol(str) {
        const s = (typeof str === "string") ? str : str.toString();
        return s.startsWith("file://") ? s.slice(7) : s;
    }

    function fileNameForPath(str) {
        if (typeof str !== "string")
            return "";
        return trimFileProtocol(str).split(/[\\/]/).pop();
    }

    function folderNameForPath(str) {
        if (typeof str !== "string")
            return "";
        const trimmed = trimFileProtocol(str);
        const noTrailing = trimmed.endsWith("/") ? trimmed.slice(0, -1) : trimmed;
        return noTrailing ? noTrailing.split(/[\\/]/).pop() : "";
    }

    function trimFileExt(str) {
        if (typeof str !== "string")
            return "";
        const trimmed = trimFileProtocol(str);
        const lastDot = trimmed.lastIndexOf(".");
        if (lastDot > trimmed.lastIndexOf("/"))
            return trimmed.slice(0, lastDot);
        return trimmed;
    }

    function parentDirectory(str) {
        if (typeof str !== "string")
            return "";
        const parts = trimFileProtocol(str).split(/[\\/]/);
        if (parts.length <= 1)
            return "";
        parts.pop();
        return parts.join("/");
    }
}
