pragma ComponentBehavior: Bound

import QtQuick
import qs.common
import qs.services

Item {
    id: wsRow

    property var screen: null

    readonly property int slots: 5
    readonly property int tileSize: Theme.ui.mainBarWsSize
    readonly property int tileGap:  Theme.ui.mainBarWsGap

    implicitWidth:  slots * tileSize + (slots - 1) * tileGap
    implicitHeight: tileSize

    property var occupiedIds: []

    function rebuildOccupied() {
        const seen = ({});
        const out = [];
        for (let i = 0; i < winProbe.count; ++i) {
            const obj = winProbe.objectAt(i);
            if (!obj) continue;
            const id = obj.wsId;
            if (id === undefined || id === null) continue;
            if (!seen[id]) { seen[id] = true; out.push(id); }
        }
        occupiedIds = out;
    }

    Instantiator {
        id: winProbe
        model: SystemNiri.windows
        delegate: QtObject {
            required property var model
            readonly property var wsId: model.workspaceId
        }
        onObjectAdded: wsRow.rebuildOccupied()
        onObjectRemoved: wsRow.rebuildOccupied()
    }

    property var wsByIdx: ({})

    function rebuildIndex() {
        const m = ({});
        for (let i = 0; i < wsProbe.count; ++i) {
            const obj = wsProbe.objectAt(i);
            if (!obj || !obj.onThisScreen) continue;
            m[obj.idx] = obj.source;
        }
        wsByIdx = m;
    }

    Instantiator {
        id: wsProbe
        model: SystemNiri.workspaces
        delegate: QtObject {
            required property var model
            readonly property var    source: model
            readonly property int    idx:    model.index
            readonly property string output: model.output ?? ""
            readonly property bool   onThisScreen: output === (wsRow.screen?.name ?? "")
            onOutputChanged: wsRow.rebuildIndex()
        }
        onObjectAdded:   wsRow.rebuildIndex()
        onObjectRemoved: wsRow.rebuildIndex()
    }

    Row {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        spacing: wsRow.tileGap

        Repeater {
            model: wsRow.slots

            Rectangle {
                id: slot
                required property int index
                readonly property int slotIdx: index + 1
                readonly property var ws: wsRow.wsByIdx[slotIdx] ?? null
                readonly property bool live:     ws !== null
                readonly property bool focused:  live && ws.isFocused
                readonly property bool occupied: live && wsRow.occupiedIds.indexOf(ws.id) !== -1

                width:  wsRow.tileSize
                height: wsRow.tileSize
                radius: Theme.ui.mainBarWsRadius
                border.width: Theme.ui.mainBarHairWidth

                Behavior on scale {
                    NumberAnimation {
                        duration: 180
                        easing.type: Easing.OutBack
                        easing.overshoot: 1.4
                    }
                }

                color: focused ? Qt.alpha(Colors.barAccent, 0.05) : "transparent"
                border.color: {
                    if (focused) return Colors.barAccent;
                    if (!live)   return Qt.alpha(Colors.hair, 0.55);
                    return hoverArea.containsMouse ? Colors.hairHot : Colors.hair;
                }

                Behavior on color        { ColorAnimation { duration: 150 } }
                Behavior on border.color { ColorAnimation { duration: 150 } }

                Text {
                    anchors.centerIn: parent
                    text: slot.slotIdx
                    font.family: Theme.font.family.inter_medium
                    font.pixelSize: 10
                    font.weight: Font.Medium
                    color: {
                        if (slot.focused) return Colors.barAccent;
                        if (!slot.live)   return Colors.inkFaint;
                        return hoverArea.containsMouse ? Colors.fgSurface : Colors.inkDim;
                    }
                    opacity: slot.live ? 1.0 : 0.45
                    Behavior on color   { ColorAnimation  { duration: 150 } }
                    Behavior on opacity { NumberAnimation { duration: 150 } }
                }

                Rectangle {
                    visible: slot.occupied
                    anchors.top: parent.top
                    anchors.right: parent.right
                    anchors.topMargin: 4
                    anchors.rightMargin: 4
                    width: 3
                    height: 3
                    radius: 1.5
                    color: slot.focused ? Colors.barAccent : Colors.inkFaint
                    Behavior on color { ColorAnimation { duration: 150 } }
                }

                MouseArea {
                    id: hoverArea
                    anchors.fill: parent
                    enabled: slot.live
                    hoverEnabled: slot.live
                    cursorShape: slot.live ? Qt.PointingHandCursor : Qt.ArrowCursor
                    onClicked: {
                        if (slot.live) SystemNiri.niri.focusWorkspaceById(slot.ws.id);
                    }
                }
            }
        }
    }
}
