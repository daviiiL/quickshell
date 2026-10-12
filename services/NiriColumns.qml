pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

Singleton {
    id: root

    property var byWorkspace: ({})
    property int revision: 0

    readonly property var emptyEntry: ({ columns: [], floating: [], focusedColumn: 0 })

    function workspace(wsId: var): var {
        const e = byWorkspace[String(wsId)];
        return e ? e : emptyEntry;
    }

    function rebuild() {
        const out = ({});
        for (let i = 0; i < probe.count; ++i) {
            const w = probe.objectAt(i);
            if (!w || w.wsId === undefined || w.wsId === null) continue;
            const key = String(w.wsId);
            if (!out[key]) out[key] = { cols: ({}), floating: [], focusedColumn: 0 };
            const e = out[key];
            if (w.floating || !(w.column > 0)) {
                e.floating.push({ windowId: w.wid, appId: w.appId, iconPath: w.iconPath, urgent: w.urgent, x: w.tilePosX });
                continue;
            }
            let c = e.cols[w.column];
            if (!c) {
                c = { index: w.column, width: 0, windowId: w.wid, appId: w.appId, title: w.title, iconPath: w.iconPath,
                      urgent: false, focused: false, firstTile: w.tile, tilePosX: NaN };
                e.cols[w.column] = c;
            }
            if (w.tile < c.firstTile) {
                c.firstTile = w.tile; c.windowId = w.wid; c.appId = w.appId; c.title = w.title; c.iconPath = w.iconPath;
            }
            if (w.tileWidth > c.width) c.width = w.tileWidth;
            if (w.urgent) c.urgent = true;
            if (w.focused) { c.focused = true; e.focusedColumn = w.column; c.tilePosX = w.tilePosX; }
        }
        const result = ({});
        for (const key in out) {
            const e = out[key];
            const columns = Object.keys(e.cols).map(k => e.cols[k]).sort((a, b) => a.index - b.index);
            columns.forEach(c => { delete c.firstTile; });
            result[key] = { columns: columns, floating: e.floating, focusedColumn: e.focusedColumn, wsId: key };
        }
        byWorkspace = result;
        revision += 1;
    }

    Timer {
        id: coalesce
        interval: 16
        onTriggered: root.rebuild()
    }

    function schedule() { if (!coalesce.running) coalesce.start(); }

    Instantiator {
        id: probe
        model: SystemNiri.windows
        delegate: QtObject {
            required property var model
            readonly property var    wid:       model.id
            readonly property var    wsId:      model.workspaceId
            readonly property string appId:    model.appId    ?? ""
            readonly property string title:    model.title    ?? ""
            readonly property string iconPath: model.iconPath ?? ""
            readonly property bool   focused:  model.isFocused  ?? false
            readonly property bool   floating: model.isFloating ?? false
            readonly property bool   urgent:   model.isUrgent   ?? false
            readonly property int    column:   model.columnIndex ?? 0
            readonly property int    tile:     model.tileIndex   ?? 0
            readonly property real   tileWidth: model.tileWidth  ?? 0
            readonly property real   tilePosX:  model.tilePosX   ?? NaN
            onWsIdChanged:      root.schedule()
            onFocusedChanged:   root.schedule()
            onFloatingChanged:  root.schedule()
            onUrgentChanged:    root.schedule()
            onColumnChanged:    root.schedule()
            onTileChanged:      root.schedule()
            onTileWidthChanged: root.schedule()
            onTilePosXChanged:  root.schedule()
            onTitleChanged:     root.schedule()
            onIconPathChanged:  root.schedule()
        }
        onObjectAdded:   root.schedule()
        onObjectRemoved: root.schedule()
    }
}
