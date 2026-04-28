pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

Singleton {
    id: root

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

    function highlightSubstring(text, query, color) {
        if (!query || query.length === 0)
            return root.escapeHtml(text);
        const idx = text.toLowerCase().indexOf(query.toLowerCase());
        if (idx < 0) return root.escapeHtml(text);
        const hex = "#"
            + Math.round(color.r * 255).toString(16).padStart(2, "0")
            + Math.round(color.g * 255).toString(16).padStart(2, "0")
            + Math.round(color.b * 255).toString(16).padStart(2, "0");
        return root.escapeHtml(text.slice(0, idx))
            + `<b><u><font color="${hex}">`
            + root.escapeHtml(text.slice(idx, idx + query.length))
            + `</font></u></b>`
            + root.escapeHtml(text.slice(idx + query.length));
    }

    function relativeTime(t) {
        if (!t) return "";
        const diff = Math.max(0, Date.now() - t);
        const m = Math.floor(diff / 60000);
        if (m < 1)  return "now";
        if (m < 60) return m + "m";
        const h = Math.floor(m / 60);
        if (h < 24) return h + "h";
        return Math.floor(h / 24) + "d";
    }
}
