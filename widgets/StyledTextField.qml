import QtQuick
import QtQuick.Controls
import qs.common

TextField {
    id: root

    property color focusedBgColor: Colors.primaryContainer
    property color unfocusedBgColor: Colors.secondaryContainer
    property color focusedTextColor: Colors.onPrimaryContainer
    property color unfocusedTextColor: Colors.onSecondaryContainer

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
        pixelSize: Theme.font.size.xs
    }

    selectionColor: root.focusedBgColor
    selectedTextColor: root.focusedTextColor
}
