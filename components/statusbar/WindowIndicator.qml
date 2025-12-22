pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Io
import qs
import qs.common
import qs.components.widgets

Item {
    id: root

    readonly property HyprlandMonitor monitor: Hyprland.monitorFor(root.QsWindow.window?.screen)
    readonly property Toplevel activeWindow: ToplevelManager.activeToplevel
    readonly property bool hasActiveWindow: activeWindow && activeWindow.activated

    // implicitWidth: Math.max(300, Math.max(150, contentRow.implicitWidth + Theme.ui.padding.normal * 2))
    implicitWidth: 300
    implicitHeight: parent.height

    Process {
        id: lockProcess
        command: ["hyprctl", "dispatch", "global", "quickshell:lock"]
        running: false
    }

    Process {
        id: signoutProcess
        command: ["hyprctl", "dispatch", "exit"]
        running: false
    }

    Process {
        id: poweroffProcess
        command: ["systemctl", "poweroff"]
        running: false
    }

    RowLayout {
        id: contentRow
        visible: !GlobalStates.statusBarExpanded

        anchors.fill: parent
        anchors.margins: Theme.ui.padding.normal
        spacing: 10

        function getAppName(appId) {
            const stringList = appId.split(".");
            if (stringList.length) {
                return stringList[stringList.length - 1];
            }
            return appId;
        }

        Text {
            Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter

            font.family: Theme.font.style.departureMono
            font.pixelSize: Theme.font.size.large
            color: Colors.current.primary

            text: root.hasActiveWindow ? (contentRow.getAppName(root.activeWindow.appId) || "Unknown") : `Workspace ${monitor?.activeWorkspace?.id ?? 1}`

            visible: text.length > 0
        }

        Text {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter

            font.family: Theme.font.style.inter
            font.pixelSize: 14
            color: Colors.current.secondary
            elide: Text.ElideRight

            text: root.hasActiveWindow ? (root.activeWindow.title || "Untitled") : `No Active Window`
        }
    }
    ColumnLayout {
        id: contentColumn
        visible: GlobalStates.statusBarExpanded

        anchors.fill: parent
        anchors.margins: Theme.ui.padding.large

        spacing: 10

        function getAppName(appId) {
            // const stringList = appId.split(".");
            // if (stringList.length) {
            //     return stringList[stringList.length - 1];
            // }
            return appId;
        }
        ColumnLayout {
            Text {
                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter

                font.family: Theme.font.style.departureMono
                font.pixelSize: Theme.font.size.large
                color: Colors.current.primary

                text: root.hasActiveWindow ? (contentColumn.getAppName(root.activeWindow.appId) || "Unknown") : "No Active Window"

                visible: text.length > 0
            }

            Text {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter

                font.family: Theme.font.style.inter
                font.pixelSize: 14
                color: Colors.current.secondary

                text: root.hasActiveWindow ? (root.activeWindow.title || "Untitled") : `Workspace ${monitor?.activeWorkspace?.id ?? 1}`
            }
        }
        ColumnLayout {
            Layout.fillHeight: true
            Layout.fillWidth: true

            TextButton {
                Layout.fillWidth: true
                text: "Lock Screen"
                fontSize: Theme.font.size.large
                onClicked: lockProcess.running = true
            }
            TextButton {
                Layout.fillWidth: true
                text: "Sign out"
                fontSize: Theme.font.size.large
                onClicked: signoutProcess.running = true
            }
            TextButton {
                Layout.fillWidth: true
                text: "Power off"

                fontSize: Theme.font.size.large
                onClicked: poweroffProcess.running = true
            }
        }
    }
}
