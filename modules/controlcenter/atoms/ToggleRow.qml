pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.common

Item {
    id: root

    required property string label
    property bool checked: false
    property bool available: true
    property bool showSeparator: false

    signal toggled()

    Layout.fillWidth: true
    implicitHeight: 44

    opacity: root.available ? 1.0 : 0.45

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 14
        anchors.rightMargin: 14
        spacing: 12

        Text {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            text: root.label
            color: Colors.fgSurface
            font.family: Theme.font.family.inter
            font.pixelSize: Theme.font.size.sm
            elide: Text.ElideRight
        }

        SettingsSwitch {
            Layout.alignment: Qt.AlignVCenter
            checked: root.checked
            available: root.available
            onToggled: root.toggled()
        }
    }

    Rectangle {
        visible: root.showSeparator
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: Theme.ui.mainBarHairWidth
        color: Colors.hair
    }
}