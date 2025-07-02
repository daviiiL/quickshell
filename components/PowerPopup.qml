import QtQuick
import Quickshell

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

            implicitWidth: 200
            implicitHeight: 200
        }
    }
}
