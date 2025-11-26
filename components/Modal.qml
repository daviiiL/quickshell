pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import "../common/"

Item {
    id: root
    //NOTE: for now, detached mode results in modal in the center

    required property var isDetached
    required property var screen
    property alias modalAnchors: modalWindow.anchors
    property alias color: modal.color
    property alias radius: modal.radius
    property alias topLeftRadius: modal.topLeftRadius
    property alias topRightRadius: modal.topRightRadius
    property alias bottomLeftRadius: modal.bottomLeftRadius
    property alias bottomRightRadius: modal.bottomRightRadius

    property string size: "small"

    property real hWRatio: 3 / 4
    property real modalWidth
    property real modalHeight

    function setAnchorsIfDetached() {
        if (root.isDetached)
            root.modalAnchors = {
                left: true,
                right: true,
                top: true,
                bottom: true
            };
    }

    function calculateWindowDimensions() {
        var widthRatio;
        switch (size) {
        case "small":
            widthRatio = 0.1;
            break;
        case "medium":
            widthRatio = 0.2;
            break;
        case "large":
            widthRatio = 0.45;
            break;
        }

        const w = screen.width * widthRatio;
        const h = w * root.hWRatio;
        root.modalWidth = w;
        root.modalHeight = h;
    }

    function show() {
        modalLoader.item.visible = true;
    }

    function hide() {
        modalLoader.item.visible = false;
    }

    Component.onCompleted: {
        root.calculateWindowDimensions();
        root.setAnchorsIfDetached();
    }

    LazyLoader {
        id: modalLoader
        loading: true
        PanelWindow {
            id: modalWindow

            implicitHeight: root.height
            implicitWidth: root.width

            color: "transparent"

            Rectangle {
                id: modal
                anchors.fill: parent
            }
        }
    }
}
