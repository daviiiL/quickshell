import QtQuick
import QtQuick.Effects
import Quickshell
import QtQuick.Controls
import Quickshell.Widgets
import Quickshell.Services.SystemTray
import "../utils/"

Rectangle {
    id: root

    required property SystemTrayItem modelData
    property alias itemHeight: root.implicitHeight
    implicitHeight: Theme.bar.width / 2
    implicitWidth: root.implicitHeight

    color: "transparent"

    TapHandler {
        id: trayItemTapHandler
        onTapped: {
            console.log(`system tray item ${root.modelData.id.toString()} was clicked`);
        }
    }

    IconImage {
        id: iconImage

        asynchronous: true
        anchors.fill: parent
        source: {
            let icon = root.modelData.icon;
            if (icon.includes("?path=")) {
                const [name, path] = icon.split("?path=");
                icon = `file://${path}/${name.slice(name.lastIndexOf("/") + 1)}`;
            }
            console.log(icon);
            return icon;
        }
    }

    MultiEffect {
        anchors.fill: parent
        source: iconImage
        colorization: 1

        colorizationColor: Colors.hexToQtRgba(Colors.current.primary)
    }
}
