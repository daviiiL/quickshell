pragma ComponentBehavior: Bound

import QtQuick
import qs.common

Item {
    id: root

    property string state: "idle"
    property bool running: true

    readonly property var stateColors: GlobalStates.darkMode ? ({
            "boot": [196, 220, 244],
            "connecting": [221, 193, 150],
            "thinking": [196, 186, 224],
            "responding": [196, 186, 224],
            "idle": [126, 178, 142],
            "offline": [214, 156, 150],
            "dormant": [126, 178, 142],
            "needs-key": [150, 150, 164]
        }) : ({
            "boot": [70, 96, 134],
            "connecting": [150, 116, 58],
            "thinking": [116, 98, 164],
            "responding": [116, 98, 164],
            "idle": [74, 128, 92],
            "offline": [168, 86, 80],
            "dormant": [74, 128, 92],
            "needs-key": [120, 116, 130]
        })
    readonly property bool restful: root.state === "idle" || root.state === "dormant" || root.state === "needs-key"

    property real t: 0
    property real startMs: 0
    property real stateStart: 0
    property var accent: [150, 150, 164]
    property var particles: []

    onStateChanged: stateStart = t

    Component.onCompleted: {
        startMs = Date.now();
        const arr = [];
        for (let k = 0; k < 21; k++)
            arr.push({
                "ring": 0.4 + (k % 3) * 0.22,
                "spd": 0.5 + (k % 5) * 0.14,
                "ph": (k * 2.399) % (Math.PI * 2)
            });
        particles = arr;
    }

    Timer {
        interval: root.restful ? 33 : 16
        repeat: true
        running: root.running
        onTriggered: {
            root.t = Date.now() - root.startMs;
            const tgt = root.stateColors[root.state] || root.stateColors["idle"];
            const k = 0.12;
            root.accent = [root.accent[0] + (tgt[0] - root.accent[0]) * k, root.accent[1] + (tgt[1] - root.accent[1]) * k, root.accent[2] + (tgt[2] - root.accent[2]) * k];
            canvas.requestPaint();
        }
    }

    Canvas {
        id: canvas
        anchors.fill: parent
        onPaint: {
            const ctx = getContext("2d");
            const w = width, h = height;
            ctx.clearRect(0, 0, w, h);
            const cx = w / 2, cy = h / 2, R = Math.min(w, h) * 0.42;
            const t = root.t, st = root.state, a = root.accent, since = t - root.stateStart;
            function AC(al) {
                return "rgba(" + Math.round(a[0]) + "," + Math.round(a[1]) + "," + Math.round(a[2]) + "," + al + ")";
            }

            ctx.fillStyle = AC(0.55 + 0.3 * Math.sin(t * 0.003));
            ctx.beginPath();
            ctx.arc(cx, cy, 3, 0, Math.PI * 2);
            ctx.fill();

            const spin = st === "thinking" ? 3 : root.restful ? 0.55 : st === "connecting" ? 1.6 : 1.1;
            const parts = root.particles;
            for (let i = 0; i < parts.length; i++) {
                const p = parts[i];
                let rad = R * p.ring, alpha = 1;
                let ang = p.ph + t * 0.001 * p.spd * spin;
                if (st === "connecting") {
                    const pr = ((t + p.ph * 260) % 1600) / 1600;
                    rad = R * p.ring + (1 - pr) * R * 1.5;
                    ang += (1 - pr) * 5;
                    alpha = Math.min(1, pr * 1.4);
                } else if (st === "responding") {
                    rad = R * p.ring * (0.72 + 0.5 * (0.5 + 0.5 * Math.sin(t * 0.006 - p.ring * 3)));
                } else if (st === "thinking") {
                    rad += Math.sin(t * 0.01 + p.ph) * 6;
                } else if (st === "offline") {
                    const pr2 = Math.min(1, since / 1300);
                    rad = R * p.ring + pr2 * R * 1.6;
                    alpha = 1 - pr2;
                } else if (st === "boot") {
                    alpha = Math.min(1, since / 900);
                    rad *= alpha;
                }
                const x = cx + Math.cos(ang) * rad, y = cy + Math.sin(ang) * rad;
                ctx.fillStyle = AC(alpha * (0.45 + 0.4 * Math.sin(t * 0.004 + p.ph)));
                ctx.beginPath();
                ctx.arc(x, y, 2.2, 0, Math.PI * 2);
                ctx.fill();
            }
        }
    }
}
