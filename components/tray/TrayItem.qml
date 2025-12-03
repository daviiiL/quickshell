import QtQuick
import QtQuick.Effects
import Quickshell.Widgets
import Quickshell.Services.SystemTray
import Quickshell
import qs.common

Rectangle {
    id: root

    property var popup
    required property int index
    required property SystemTrayItem modelData
    property alias itemHeight: root.implicitHeight
    required property list<real> parentPositions
    property alias menu: menu

    implicitHeight: 20
    implicitWidth: 20

    color: "transparent"

    signal trayItemClicked(nums: list<real>)

    TapHandler {
        id: trayItemTapHandler
        onTapped: {
            root.trayItemClicked([root.parentPositions[0] + root.x, root.parentPositions[1] + root.y]);
        }
    }
    QsMenuAnchor {
        id: menu
        menu: root.modelData.menu
        anchor.window: this.QsWindow.window
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
