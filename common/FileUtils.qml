pragma Singleton
import Quickshell

Singleton {
    id: root

    function trimFileProtocol(str) {
        const s = (typeof str === "string") ? str : str.toString();
        return s.startsWith("file://") ? s.slice(7) : s;
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
