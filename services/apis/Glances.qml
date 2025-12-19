pragma Singleton

import Quickshell
import QtQuick
import qs.common

Singleton {
    property bool isServerRunning: false
    property bool cpuInitialized: false
    property bool allInitialized: false

    property string glancesVersion: ""

    function onError(status, error) {
        console.warn("Glances Server Error: ", status, error);
    }

    ApiClient {
        id: glances
        baseUrl: "http://0.0.0.0:61208/api/4/"
    }

    function checkServerStatus() {
        glances.get("status", function (data) {
            glancesVersion = data.version;
            isServerRunning = true;
        }, function (status, error) {
            onError(status, error);
            isServerRunning = false;
        });
    }

    Component.onCompleted: {
        checkServerStatus();
        console.log("Glances services initialized");
    }
}
