import QtQuick
import QtQuick.Layouts
import "../../common"

/**
 * A horizontal group of buttons with consistent styling.
 */
RowLayout {
    id: root
    spacing: 5
    property real baseHeight: 36

    Layout.fillWidth: true
    Layout.preferredHeight: baseHeight
}
