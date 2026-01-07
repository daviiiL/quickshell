pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import qs.common

Singleton {
    id: root

    readonly property list<DesktopEntry> list: Array.from(DesktopEntries.applications.values).filter((app, index, self) => index === self.findIndex(t => (t.id === app.id)))

    readonly property var preppedNames: list.map(a => ({
                "name": Fuzzy.prepare(`${a.name} `),
                "entry": a
            }))

    function fuzzyQuery(search: string): var {
        if (search === "")
            return [];

        const res = Fuzzy.go(search, preppedNames, {
            "all": true,
            "key": "name"
        }).map(r => r.obj.entry);

        return res;
    }
}
