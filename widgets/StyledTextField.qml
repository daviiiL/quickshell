import QtQuick
import QtQuick.Controls
import qs.common

TextField {
    id: root

    padding: 8
    leftPadding: 12
    rightPadding: 12

    background: Rectangle {
        radius: Theme.ui.radius.md
        color: Qt.alpha(root.activeFocus ? Colors.primary_container : Colors.secondary_container, 0.4)

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
