pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.common
import qs.services

RowLayout {
    id: dockRow
    spacing: Theme.ui.mainBarDockItemGap

    property var apps: []

    function rebuildApps() {
        const groups = ({});
        const order = [];
        for (let i = 0; i < winProbe.count; ++i) {
            const obj = winProbe.objectAt(i);
            if (!obj) continue;
            const appId = obj.appId || "";
            const key = appId || ("win-" + obj.wid);
            if (!groups[key]) {
                groups[key] = {
                    key: key,
                    appId: appId,
                    icon: obj.iconPath || "",
                    title: obj.title || appId,
                    focused: false,
                    urgent: false,
                    firstWindowId: obj.wid
                };
                order.push(key);
            }
            const g = groups[key];
            if (obj.focused) g.focused = true;
            if (obj.urgent)  g.urgent  = true;
            if (!g.icon && obj.iconPath) g.icon = obj.iconPath;
        }
        apps = order.map(k => groups[k]);
    }

    Instantiator {
        id: winProbe
        model: SystemNiri.windows
        delegate: QtObject {
            required property var model
            readonly property string appId:    model.appId    ?? ""
            readonly property string iconPath: model.iconPath ?? ""
            readonly property string title:    model.title    ?? ""
            readonly property var    wid:      model.id
            readonly property bool   focused:  model.isFocused ?? false
            readonly property bool   urgent:   model.isUrgent  ?? false
            onFocusedChanged: dockRow.rebuildApps()
            onUrgentChanged:  dockRow.rebuildApps()
        }
        onObjectAdded:   dockRow.rebuildApps()
        onObjectRemoved: dockRow.rebuildApps()
    }

    Repeater {
        model: dockRow.apps

        DockItem {
            required property var modelData

            iconSource: {
                const p = modelData.icon;
                if (!p) return "";
                if (p.indexOf("://") !== -1) return p;
                return "file://" + p;
            }
            label:       modelData.title
            focused:     modelData.focused
            running:     true
            unreadCount: modelData.urgent ? 1 : 0

            onActivated: SystemNiri.niri.focusWindow(modelData.firstWindowId)
        }
    }
}
