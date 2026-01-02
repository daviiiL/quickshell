import QtQuick
import QtQuick.Layouts

import qs.common
import qs.services

Rectangle {
    id: root
    color: contentBackground

    radius: Theme.ui.radius.md

    property bool showTitle: false
    property string title: ""
    property color contentBackground: Preferences.darkMode ? Colors.background : Colors.surface_variant

    default property alias content: contentRect.data

    implicitHeight: (showTitle ? 30 : 0) + contentRect.implicitHeight

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            id: titleRect
            visible: root.showTitle
            Layout.fillWidth: true
            Layout.preferredHeight: 30
            color: Preferences.darkMode ? Qt.rgba(Colors.secondary_container.r, Colors.secondary_container.g, Colors.secondary_container.b, 0.5) : Qt.rgba(Colors.secondary_fixed_dim.r, Colors.secondary_fixed_dim.g, Colors.secondary_fixed_dim.b, 0.5)
            topRightRadius: Theme.ui.radius.md
            topLeftRadius: Theme.ui.radius.md

            Layout.alignment: Qt.AlignTop

            Text {
                anchors.centerIn: parent
                text: root.title
                color: Colors.on_secondary_container
                font.family: Theme.font.family.inter_thin
                font.pixelSize: Theme.font.size.md
                renderType: Text.QtRendering
                renderTypeQuality: Text.HighRenderTypeQuality
            }
        }

        Rectangle {
            id: contentRect
            Layout.fillWidth: true
            implicitHeight: childrenRect.height
            Layout.preferredHeight: implicitHeight
            bottomLeftRadius: Theme.ui.radius.md
            bottomRightRadius: Theme.ui.radius.md
            topLeftRadius: root.showTitle ? 0 : Theme.ui.radius.md
            topRightRadius: root.showTitle ? 0 : Theme.ui.radius.md
            color: root.contentBackground
        }
    }
}
