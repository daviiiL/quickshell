pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Shapes
import Quickshell
import qs.common
import qs.services
import "../../../services/RibbonLayout.js" as L

Item {
    id: root

    required property var entry
    required property string wsId
    required property real viewWidth
    property bool interactive: false

    signal sliverActivated(var windowId)

    readonly property int ribbonW: Theme.ui.mainBarRibbonWidth
    readonly property int cap:     Theme.ui.mainBarRibbonCap

    readonly property var viewByWs: ({})
    readonly property var noSliver: ({ column: ({ urgent: false, iconPath: "", appId: "" }), x: 0, w: 0, tone: "off", wide: false, ordinal: 0 })
    property Item hoverSliver: null

    function fitView(xs, widths, fi): real {
        const n = widths.length;
        const total = n ? xs[n - 1] + widths[n - 1] : 0;
        const prev = root.viewByWs[root.wsId]?.viewX ?? 0;
        if (fi < 0) return L.clamp(prev, 0, Math.max(0, total - root.viewWidth));
        const fc = root.entry.columns[fi];
        if (Number.isFinite(fc.tilePosX)) return xs[fi] - fc.tilePosX;
        return L.viewOffset(prev, xs[fi], widths[fi], root.viewWidth, total);
    }

    function unfocusedRange(xs, viewX): var {
        const n = xs.length;
        const kept = root.viewByWs[root.wsId]?.start;
        if (kept !== undefined) {
            const start = L.clamp(kept, 0, Math.max(0, n - root.cap));
            return { start: start, end: Math.min(n, start + root.cap) };
        }
        const a = xs.findIndex(x => x >= viewX);
        return L.windowRange(n, L.clamp(a < 0 ? n - 1 : a, 0, Math.max(0, n - 1)), root.cap);
    }

    readonly property var geom: {
        const cols = root.entry.columns;
        const n = cols.length;
        const widths = cols.map(c => c.width);
        const xs = L.columnX(widths, Theme.ui.niriColumnGap);
        const fi = root.entry.focusedColumn > 0 ? cols.findIndex(c => c.index === root.entry.focusedColumn) : -1;
        const viewX = root.fitView(xs, widths, fi);
        const r = fi >= 0 ? L.windowRange(n, fi, root.cap) : root.unfocusedRange(xs, viewX);
        const sub = cols.slice(r.start, r.end);
        const sw = L.sliverWidths(sub.map(c => c.width), root.viewWidth, root.ribbonW,
                                  Theme.ui.mainBarRibbonSliverMin, Theme.ui.mainBarRibbonGap);
        const slivers = sub.map((c, i) => ({
            column: c,
            ordinal: r.start + i + 1,
            x: sw.x[i],
            w: sw.px[i],
            wide: sw.px[i] >= Theme.ui.mainBarRibbonWideAt,
            tone: r.start + i === fi ? "focus"
                : (L.visibleFraction(xs[r.start + i], c.width, viewX, root.viewWidth) >= 0.5 ? "on" : "off")
        }));
        const urgentL = cols.slice(0, r.start).some(c => c.urgent);
        const urgentR = cols.slice(r.end).some(c => c.urgent);
        return { slivers: slivers, count: n, used: sw.used, hiddenL: r.start > 0, hiddenR: r.end < n,
                 urgentL: urgentL, urgentR: urgentR, viewX: viewX, start: r.start };
    }

    // Mutated in place: reassigning the map would loop back into the geom binding.
    onGeomChanged: if (root.entry.wsId === root.wsId && root.viewWidth > 0) viewByWs[wsId] = { viewX: geom.viewX, start: geom.start }

    implicitWidth: Math.max(root.ribbonW, root.geom.used)
    implicitHeight: Theme.ui.mainBarRibbonHeight

    Behavior on implicitWidth { NumberAnimation { duration: Theme.anim.durations.expressiveFastSpatial; easing.bezierCurve: Theme.anim.curves.expressiveFastSpatial } }

    Shape {
        visible: root.geom.count === 0
        anchors.fill: parent
        opacity: 0.18
        ShapePath {
            strokeColor: Colors.barAccent
            strokeWidth: Theme.ui.mainBarHairWidth
            strokeStyle: ShapePath.DashLine
            dashPattern: [Theme.ui.mainBarRibbonDash, Theme.ui.mainBarRibbonDash]
            fillColor: "transparent"
            startX: 0.5; startY: 0.5
            PathLine { x: root.width - 0.5; y: 0.5 }
            PathLine { x: root.width - 0.5; y: root.height - 0.5 }
            PathLine { x: 0.5;              y: root.height - 0.5 }
            PathLine { x: 0.5;              y: 0.5 }
        }
    }

    Repeater {
        model: root.geom.slivers.length

        RibbonSliver {
            id: sliver
            required property int index
            // Outlived delegates read noSliver until the Repeater drops them.
            readonly property var s: root.geom.slivers[index] ?? root.noSliver
            x: s.x
            width: s.w
            tone: s.tone
            wide: s.wide
            urgent: s.column.urgent
            iconSource: {
                const p = s.column.iconPath;
                if (!p) return "";
                return p.indexOf("://") !== -1 ? p : "file://" + p;
            }
            onActivated: root.sliverActivated(s.column.windowId)
            onHoverChanged: function (on) {
                if (on) {
                    root.hoverSliver = sliver;
                } else {
                    // Qt enters the next sliver before it leaves this one.
                    if (root.hoverSliver === sliver) root.hoverSliver = null;
                }
            }
            Component.onDestruction: if (root.hoverSliver === sliver) root.hoverSliver = null
        }
    }

    onSliverActivated: function (windowId) { SystemNiri.niri.focusWindow(windowId) }

    RibbonTip {
        id: tip
        readonly property var s: root.hoverSliver ? root.hoverSliver.s : null
        target: root.hoverSliver
        title: s ? (s.column.appId || "window") : ""
        sub: s ? "column " + s.ordinal + " of " + root.geom.count + (s.column.urgent ? ", needs attention" : "") : ""
    }

    Timer { id: wheelGate; interval: Theme.ui.mainBarRibbonWheelMs }

    function wheelStep(dx, dy) {
        if (!root.interactive || wheelGate.running) return;
        const d = Math.abs(dy) >= Math.abs(dx) ? dy : dx;
        if (d === 0) return;
        wheelGate.restart();
        Quickshell.execDetached(["niri", "msg", "action", d < 0 ? "focus-column-right" : "focus-column-left"]);
    }

    WheelHandler {
        enabled: root.interactive
        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
        onWheel: function (ev) { root.wheelStep(ev.angleDelta.x, ev.angleDelta.y) }
    }

    component EdgeDot: Rectangle {
        property bool lit: false
        property bool ring: false
        width: Theme.ui.mainBarRibbonEdgeDot
        height: Theme.ui.mainBarRibbonEdgeDot
        radius: width / 2
        anchors.verticalCenter: parent.verticalCenter
        color: lit ? Colors.live : Colors.barAccent
        opacity: lit ? 1.0 : 0.14
        border.width: ring ? Theme.ui.mainBarHairWidth : 0
        border.color: Colors.barAccent
        Behavior on color   { ColorAnimation  { duration: Theme.anim.durations.xs } }
        Behavior on opacity { NumberAnimation { duration: Theme.anim.durations.xs } }
    }

    EdgeDot {
        anchors.right: parent.left
        anchors.rightMargin: Theme.ui.mainBarRibbonEdgeDotGap
        lit: root.geom.hiddenL
        ring: root.geom.hiddenL && root.geom.urgentL
    }

    EdgeDot {
        anchors.left: parent.right
        anchors.leftMargin: Theme.ui.mainBarRibbonEdgeDotGap
        lit: root.geom.hiddenR
        ring: root.geom.hiddenR && root.geom.urgentR
    }

    Repeater {
        model: root.entry.floating

        Rectangle {
            required property var modelData
            required property int index
            width: Theme.ui.mainBarRibbonFloatDot
            height: width
            radius: width / 2
            color: Colors.barAccent
            opacity: 0.7
            y: -Theme.ui.mainBarRibbonFloatLift - height
            x: (root.viewWidth > 0 && Number.isFinite(modelData.x))
                ? Math.max(0, Math.min(root.width - width, modelData.x / root.viewWidth * root.width))
                : Theme.ui.mainBarRibbonFloatInset + index * Theme.ui.mainBarRibbonFloatPitch
        }
    }
}
