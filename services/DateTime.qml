pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property string currentTimezone: ""
    property int tzOffsetSeconds: 0

    // SystemClock.date is a Qt::LocalTime QDateTime — its .getTime() re-interprets
    // in whatever tz is current at access time, so it's unreliable across tz
    // changes. Use Date.now() for the UTC instant and clock.date only as the
    // minute-boundary re-eval trigger.
    readonly property string hrs: {
        clock.date;
        if (!root.currentTimezone) return Qt.formatDateTime(new Date(), "hh");
        const w = new Date(Date.now() + root.tzOffsetSeconds * 1000);
        return String(w.getUTCHours()).padStart(2, "0");
    }

    readonly property string mins: {
        clock.date;
        if (!root.currentTimezone) return Qt.formatDateTime(new Date(), "mm");
        const w = new Date(Date.now() + root.tzOffsetSeconds * 1000);
        return String(w.getUTCMinutes()).padStart(2, "0");
    }

    readonly property string date: {
        clock.date;
        if (!root.currentTimezone) return Qt.formatDateTime(new Date(), "ddd d");
        const w = new Date(Date.now() + root.tzOffsetSeconds * 1000);
        return Qt.locale().dayName(w.getUTCDay(), Locale.ShortFormat) + " " + w.getUTCDate();
    }

    readonly property string time: hrs + ":" + mins

    function refresh(): void {
        readTzProc.running = false;
        readTzProc.running = true;
    }

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    Process {
        id: readTzProc
        running: true
        command: ["sh", "-c", "timedatectl show -p Timezone --value; date +%z"]
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.trim().split("\n");
                const match = lines[1]?.match(/([+-])(\d{2})(\d{2})/);
                if (!lines[0] || !match)
                    return;
                root.currentTimezone = lines[0].trim();
                const sign = match[1] === "-" ? -1 : 1;
                root.tzOffsetSeconds = sign * (parseInt(match[2], 10) * 3600 + parseInt(match[3], 10) * 60);
            }
        }
    }
}
