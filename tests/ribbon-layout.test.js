const test = require("node:test");
const assert = require("node:assert/strict");
const L = require("../services/RibbonLayout.js");

test("windowRange shows everything when count <= cap", () => {
    assert.deepEqual(L.windowRange(0, 0, 5), { start: 0, end: 0 });
    assert.deepEqual(L.windowRange(3, 1, 5), { start: 0, end: 3 });
    assert.deepEqual(L.windowRange(5, 4, 5), { start: 0, end: 5 });
});

test("windowRange centres on focus and clamps at both ends", () => {
    assert.deepEqual(L.windowRange(13, 6, 5), { start: 4, end: 9 });
    assert.deepEqual(L.windowRange(13, 0, 5), { start: 0, end: 5 });
    assert.deepEqual(L.windowRange(13, 12, 5), { start: 8, end: 13 });
    assert.deepEqual(L.windowRange(6, 5, 5), { start: 1, end: 6 });
});

test("columnX accumulates widths plus the niri gap", () => {
    assert.deepEqual(L.columnX([], 8), []);
    assert.deepEqual(L.columnX([2036, 2036, 1000], 8), [0, 2044, 4088]);
});

test("viewOffset keeps the focused column inside the view with minimal scroll", () => {
    assert.equal(L.viewOffset(0, 0, 2036, 4096, 4088 + 1000), 0);
    assert.equal(L.viewOffset(0, 4088, 1000, 4096, 5088), 992);
    assert.equal(L.viewOffset(992, 2044, 2036, 4096, 5088), 992);
    assert.equal(L.viewOffset(992, 0, 2036, 4096, 5088), 0);
    assert.equal(L.viewOffset(3000, 0, 5000, 4096, 5000), 904);
});

test("visibleFraction", () => {
    assert.equal(L.visibleFraction(0, 2036, 0, 4096), 1);
    assert.equal(L.visibleFraction(4088, 1000, 0, 4096), 8 / 1000);
    assert.equal(L.visibleFraction(0, 5000, 0, 4096), 4096 / 5000);
    assert.equal(L.visibleFraction(6000, 100, 0, 4096), 0);
});

test("sliverWidths maps proportionally against max(sum, view) with a floor", () => {
    const two = L.sliverWidths([2036, 2036], 4096, 160, 26, 2);
    assert.deepEqual(two.px.map(Math.round), [79, 79]);
    assert.deepEqual(two.x.map(Math.round), [0, 81]);
    assert.ok(Math.abs(two.used - 4072 / 4096 * 160) < 1e-9);

    const one = L.sliverWidths([5000], 4096, 160, 26, 2);
    assert.deepEqual(one.px, [160]);
    assert.equal(one.used, 160);

    const empty = L.sliverWidths([], 4096, 160, 26, 2);
    assert.deepEqual(empty, { px: [], x: [], used: 0 });

    const five = L.sliverWidths([640, 640, 640, 640, 640], 4096, 160, 26, 2);
    assert.ok(five.px.every(p => p === 26));
    assert.equal(five.used, 26 * 5 + 2 * 4);
    assert.ok(five.px.every(p => !Number.isNaN(p)));
});
