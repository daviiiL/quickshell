pragma ComponentBehavior: Bound
pragma Singleton

import Quickshell
import QtQuick

import qs.common

Singleton {
    id: root

    function debug(value: var, source: string): void {
        if (!GlobalStates.debugMode)
            return;
        const msg = JSON.stringify({
            source,
            value
        });

        console.debug(msg);
    }
}
