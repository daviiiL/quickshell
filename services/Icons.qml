pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import qs.common

Singleton {
    id: root

    readonly property string tone: GlobalStates.darkMode ? "gray100" : "gray900"

    function url(name: string): string {
        return Qt.resolvedUrl("../assets/icons/" + root.tone + "/" + name + ".svg");
    }

    readonly property string bell:         root.url("bell")
    readonly property string charging:     root.url("charging")
    readonly property string ethernet:     root.url("ethernet")
    readonly property string brightness1:  root.url("brightness-1")
    readonly property string brightness2:  root.url("brightness-2")
    readonly property string brightness3:  root.url("brightness-3")
    readonly property string volume:       root.url("volume")
    readonly property string volumeLow:    root.url("volume-low")
    readonly property string volumeMedium: root.url("volume-medium")
    readonly property string volumeMuted:  root.url("volume-muted")
    readonly property string wifi1:        root.url("wifi-1")
    readonly property string wifi2:        root.url("wifi-2")
    readonly property string wifi3:        root.url("wifi-3")
}
