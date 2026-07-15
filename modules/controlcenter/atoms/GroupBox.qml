pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.common

Rectangle {
    id: root

    Layout.fillWidth: true

    color: Colors.surfaceContainerLow
    radius: Theme.ui.radius.sm
    border.color: Colors.hair
    border.width: Theme.ui.mainBarHairWidth
    clip: true

    implicitHeight: column.implicitHeight

    default property alias content: column.data

    ColumnLayout {
        id: column
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        spacing: 0
    }
}
