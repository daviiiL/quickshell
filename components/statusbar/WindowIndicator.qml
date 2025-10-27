import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import "../../common/"

Item {
    id: root

    // Get the monitor for this window
    readonly property HyprlandMonitor monitor: Hyprland.monitorFor(root.QsWindow.window?.screen)

    // Get the active window from ToplevelManager
    readonly property Toplevel activeWindow: ToplevelManager.activeToplevel

    // Determine if there's an active window
    readonly property bool hasActiveWindow: activeWindow && activeWindow.activated

    implicitWidth: Math.min(300, Math.max(150, contentRow.implicitWidth + Theme.ui.padding.normal * 2))
    implicitHeight: parent.height

    RowLayout {
        id: contentRow

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

        // App ID (smaller, subdued)
        Text {
            width: 50
            Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter

            font.family: Theme.font.style.departureMono
            font.pixelSize: Theme.font.size.large
            color: Colors.current.primary
            // elide: Text.ElideRight

            text: root.hasActiveWindow ? (contentRow.getAppName(root.activeWindow.appId) || "Unknown") : ""

            visible: text.length > 0
        }

        // Window Title (larger, prominent)
        Text {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter

            font.family: Theme.font.style.inter
            font.pixelSize: 14
            color: Colors.current.secondary
            elide: Text.ElideRight

            text: root.hasActiveWindow ? (root.activeWindow.title || "Untitled") : `Workspace ${monitor?.activeWorkspace?.id ?? 1}`
        }
    }
}
