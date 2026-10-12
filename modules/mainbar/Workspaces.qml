pragma ComponentBehavior: Bound

import QtQuick
import qs.common
import qs.services
import qs.modules.mainbar.ribbon

Item {
    id: wsRow

    property var screen: null

    readonly property string screenName: wsRow.screen?.name ?? ""

    implicitWidth:  row.implicitWidth
    implicitHeight: Math.max(Theme.ui.mainBarRibbonHeight, ticks.implicitHeight)

    property var wsByIdx: ({})
    property var activeWs: null

    function rebuildIndex() {
        const m = ({});
        let active = null;
        for (let i = 0; i < wsProbe.count; ++i) {
            const obj = wsProbe.objectAt(i);
            if (!obj || !obj.onThisScreen) continue;
            m[obj.idx] = obj.source;
            if (obj.active) active = obj.source;
        }
        wsByIdx = m;
        activeWs = active;
    }

    Instantiator {
        id: wsProbe
        model: SystemNiri.workspaces
        delegate: QtObject {
            required property var model
            readonly property var    source: model
            readonly property int    idx:    model.index
            readonly property string output: model.output ?? ""
            readonly property bool   active: model.isActive ?? false
            readonly property bool   onThisScreen: output === wsRow.screenName
            onIdxChanged:    wsRow.rebuildIndex()
            onOutputChanged: wsRow.rebuildIndex()
            onActiveChanged: wsRow.rebuildIndex()
        }
        onObjectAdded:   wsRow.rebuildIndex()
        onObjectRemoved: wsRow.rebuildIndex()
    }

    readonly property var occupiedSlots: {
        const live = NiriColumns.revision >= 0 ? NiriColumns.byWorkspace : ({});
        const out = [];
        for (let i = 1; i <= 5; ++i) {
            const ws = wsRow.wsByIdx[i] ?? null;
            out.push(ws !== null && String(ws.id) in live);
        }
        return out;
    }

    readonly property int currentSlot: {
        for (let i = 1; i <= 5; ++i) {
            const ws = wsRow.wsByIdx[i] ?? null;
            if (ws !== null && wsRow.activeWs !== null && ws.id === wsRow.activeWs.id) return i;
        }
        return 0;
    }

    Row {
        id: row
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        spacing: Theme.ui.mainBarTickRibbonGap + Theme.ui.mainBarRibbonEdgeDotGap + Theme.ui.mainBarRibbonEdgeDot
        rightPadding: Theme.ui.mainBarRibbonEdgeDotGap + Theme.ui.mainBarRibbonEdgeDot

        WorkspaceTicks {
            id: ticks
            anchors.verticalCenter: parent.verticalCenter
            currentIdx: wsRow.currentSlot
            occupied: wsRow.occupiedSlots
            onActivated: function (idx) {
                const ws = wsRow.wsByIdx[idx] ?? null;
                if (ws !== null) SystemNiri.niri.focusWorkspaceById(ws.id);
            }
        }

        ColumnRibbon {
            anchors.verticalCenter: parent.verticalCenter
            entry: NiriColumns.revision >= 0 && wsRow.activeWs !== null ? NiriColumns.workspace(wsRow.activeWs.id) : NiriColumns.emptyEntry
            wsId: wsRow.activeWs !== null ? String(wsRow.activeWs.id) : "none"
            viewWidth: wsRow.screen ? wsRow.screen.width : 0
            interactive: wsRow.activeWs !== null && (wsRow.activeWs.isFocused ?? false)
        }
    }
}
