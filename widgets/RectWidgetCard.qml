import QtQuick
import QtQuick.Layouts

import qs.common

Rectangle {
    id: root
    color: contentBackground

    radius: Theme.ui.radius.md

    property bool showTitle: false
    property string title: ""
    property color contentBackground: Colors.background

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
            color: Qt.rgba(Colors.secondary_container.r, Colors.secondary_container.g, Colors.secondary_container.b, 0.5)
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
