import QtQuick
import QtQuick.Layouts

import qs.common
import qs.widgets
import qs.services

Rectangle {
    id: root
    Layout.preferredHeight: icon.implicitHeight + 4
    Layout.rightMargin: Theme.ui.padding.sm
    Layout.preferredWidth: icon.implicitWidth
    color: Qt.rgba(hoverBgColor.r, hoverBgColor.g, hoverBgColor.b, 0)
    radius: Theme.ui.radius.md

    readonly property color iconColor: Preferences.darkMode ? Colors.secondary : Colors.primary
    readonly property color hoverIconColor: Preferences.darkMode ? Colors.on_primary_container : Colors.on_primary_container
    readonly property color hoverBgColor: Preferences.darkMode ? Colors.primary_container : Colors.primary_container

    MaterialSymbol {
        id: icon
        anchors.fill: parent
        fontColor: root.iconColor
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        icon: "settings_power"
        iconSize: 15
    }

    Behavior on color {
        ColorAnimation {
            easing.type: Easing.Bezier
            easing.bezierCurve: Theme.anim.curves.standard
            duration: 200
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true

        onEntered: {
            icon.fontColor = root.hoverIconColor;
            parent.color = root.hoverBgColor;
        }

        onExited: {
            icon.fontColor = root.iconColor;
            parent.color = Qt.rgba(root.hoverBgColor.r, root.hoverBgColor.g, root.hoverBgColor.b, 0);
        }

        onPressed: {
            GlobalStates.powerPanelOpen = true;
        }
    }
}
