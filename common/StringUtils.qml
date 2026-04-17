pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

Singleton {
    id: root

    // Strips leading bracketed annotations commonly seen in track titles
    // (e.g. "(Official Video)", "[Lyrics]", "【MV】").
    function cleanMusicTitle(title) {
        if (!title)
            return "";
        return title
            .replace(/^ *\([^)]*\) */g, " ")
            .replace(/^ *\[[^\]]*\] */g, " ")
            .replace(/^ *\{[^\}]*\} */g, " ")
            .replace(/^ *【[^】]*】/, "")
            .replace(/^ *《[^》]*》/, "")
            .replace(/^ *「[^」]*」/, "")
            .replace(/^ *『[^』]*』/, "")
            .trim();
    }

    function friendlyTimeForSeconds(seconds) {
        if (isNaN(seconds) || seconds < 0)
            return "0:00";
        seconds = Math.floor(seconds);
        const h = Math.floor(seconds / 3600);
        const m = Math.floor((seconds % 3600) / 60);
        const s = seconds % 60;
        const pad = n => n.toString().padStart(2, '0');
        return h > 0 ? `${h}:${pad(m)}:${pad(s)}` : `${m}:${pad(s)}`;
    }

    function escapeHtml(str) {
        if (typeof str !== 'string')
            return str;
        return str
            .replace(/&/g, '&amp;')
            .replace(/</g, '&lt;')
            .replace(/>/g, '&gt;')
            .replace(/"/g, '&quot;')
            .replace(/'/g, '&#39;');
    }

    function shellSingleQuoteEscape(str) {
        return String(str).replace(/'/g, "'\\''");
    }
}
