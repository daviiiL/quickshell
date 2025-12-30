import QtQuick
import QtQuick.Controls
import qs.common

TextField {
    id: root

    function makeTranslucent(color) {
        return Qt.rgba(color.r, color.g, color.b, 0.4);
    }

    padding: 8
    leftPadding: 12
    rightPadding: 12

    background: Rectangle {
        radius: Theme.ui.radius.md
        color: root.activeFocus ? root.makeTranslucent(Colors.primary_container) : root.makeTranslucent(Colors.secondary_container)

        border {
            color: root.activeFocus ? Colors.primary_container : Colors.secondary_container
        }
    }

    color: root.activeFocus ? Colors.on_primary_container : Colors.on_secondary_container

    font {
        family: Theme.font.family.inter_thin
        pixelSize: Theme.font.size.xs
    }

    selectionColor: Colors.primary_container
    selectedTextColor: Colors.on_primary_container
}
