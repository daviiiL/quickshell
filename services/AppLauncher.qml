pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import qs.services

Singleton {
    id: root

    property string query: ""

    property list<var> results: {
        if (root.query === "")
            return [];

        return AppSearch.fuzzyQuery(root.query).map(entry => resultComp.createObject(null, {
            "type": "App",
            "name": entry.name,
            "iconName": entry.icon,
            "iconType": "system",
            "verb": "Launch",
            "comment": entry.description || "",
            "genericName": "",
            "keywords": [],
            "runInTerminal": entry.runInTerminal,
            "execute": () => {
                if (!entry.runInTerminal) {
                    entry.execute();
                    return;
                }
                const terminalCmd = Quickshell.env("TERMINAL") || "kitty";
                Quickshell.execDetached(["bash", '-c', `${terminalCmd} -e '${StringUtils.shellSingleQuoteEscape(entry.command.join(' '))}'`]);
            },
            "actions": []
        }));
    }

    Component {
        id: resultComp

        QtObject {
            property string type: ""
            property string name: ""
            property string iconName: ""
            property string iconType: ""
            property string verb: ""
            property string comment: ""
            property string genericName: ""
            property list<string> keywords: []
            property bool runInTerminal: false
            property var execute: () => {}
            property var actions: []
        }
    }
}
