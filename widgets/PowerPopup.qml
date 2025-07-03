import QtQuick
import Quickshell
import "../utils/"

Item {
    property var pWindow

    function show() {
        popupLoader.item.visible = true;
    }

    function hide() {
        popupLoader.item.visible = false;
    }

    LazyLoader {
        id: popupLoader

        loading: true
        PopupWindow {
            anchor.window: pWindow
            anchor.rect.x: pWindow.width
            anchor.rect.y: pWindow.height

            implicitHeight: windowRect.height
            implicitWidth: windowRect.width

            color: "transparent"

            Rectangle {
                id: windowRect
                implicitHeight: 200
                implicitWidth: 200

                topRightRadius: Theme.rounding.regular
                bottomRightRadius: Theme.rounding.regular
                color: Colors.values.background
            }
        }
    }
}
