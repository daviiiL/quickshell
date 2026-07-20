import QtQuick
import QtQuick.Controls
import qs.common

TextField {
    id: root

    property color focusedBgColor: Colors.surfaceContainer
    property color unfocusedBgColor: Colors.surfaceContainerLow
    property color focusedTextColor: Colors.fgSurface
    property color unfocusedTextColor: Colors.fgSurface

    padding: 8
    leftPadding: 12
    rightPadding: 12

    background: Rectangle {
        radius: Theme.ui.radius.md
        color: Qt.alpha(root.activeFocus ? root.focusedBgColor : root.unfocusedBgColor, 0.4)

        border {
            color: root.activeFocus ? root.focusedBgColor : root.unfocusedBgColor
        }
    }

    color: root.activeFocus ? root.focusedTextColor : root.unfocusedTextColor

    font {
        family: Theme.font.family.inter_thin
        pixelSize: Theme.font.size.sm
    }

    selectionColor: root.focusedBgColor
    selectedTextColor: root.focusedTextColor
}
