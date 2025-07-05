pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import "../utils/"

Item {
    id: root
    required property var screen

    anchors {
        left: parent.right
    }

    function calculateWindowDimensions() {
        root.implicitWidth = screen.width * 0.45;
        root.implicitHeight = root.implicitWidth * 3 / 4;
    }

    function show() {
        modalLoader.item.visible = true;
    }

    function hide() {
        modalLoader.item.visible = false;
    }

    Component.onCompleted: {
        //initialize
        root.calculateWindowDimensions();
    }

    LazyLoader {
        id: modalLoader
        loading: true
        PanelWindow {
            id: modalWindow
            visible: false
            implicitHeight: root.implicitHeight
            implicitWidth: root.implicitWidth

            color: "transparent"

            Rectangle {
                id: modal
                anchors.fill: parent
                color: Colors.values.background
                radius: Theme.rounding.large
            }
        }
    }
}
