function clamp(v, lo, hi) { return Math.max(lo, Math.min(hi, v)); }

function windowRange(count, focus0, cap) {
    if (count <= cap) return { start: 0, end: count };
    const start = clamp(focus0 - Math.floor(cap / 2), 0, count - cap);
    return { start: start, end: start + cap };
}

function columnX(widths, colGap) {
    const xs = [];
    let x = 0;
    for (let i = 0; i < widths.length; ++i) { xs.push(x); x += widths[i] + colGap; }
    return xs;
}

function viewOffset(prevX, fx, fw, viewW, total) {
    let v = prevX;
    if (fx < v) v = fx;
    if (fx + fw > v + viewW) v = fx + fw - viewW;
    return clamp(v, 0, Math.max(0, total - viewW));
}

function visibleFraction(cx, cw, viewX, viewW) {
    if (cw <= 0) return 0;
    const a = Math.max(cx, viewX), z = Math.min(cx + cw, viewX + viewW);
    return clamp((z - a) / cw, 0, 1);
}

function sliverWidths(widths, viewW, ribbonW, minW, gap) {
    const k = widths.length;
    if (!k) return { px: [], x: [], used: 0 };
    let total = 0;
    for (let i = 0; i < k; ++i) total += widths[i];
    const strip = Math.max(total, viewW);
    const px = [], x = [];
    let cursor = 0;
    for (let i = 0; i < k; ++i) {
        const w = Math.max(minW, widths[i] / strip * ribbonW - gap * (k - 1) / k);
        px.push(w); x.push(cursor); cursor += w + gap;
    }
    return { px: px, x: x, used: cursor - gap };
}

if (typeof module !== "undefined")
    module.exports = { windowRange, columnX, viewOffset, visibleFraction, sliverWidths };
