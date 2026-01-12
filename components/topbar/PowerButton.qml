import QtQuick
import QtQuick.Layouts

import qs.common
import qs.widgets
import qs.services

Rectangle {
    id: root
    Layout.preferredHeight: Preferences.focusedMode ? 24 : (icon.implicitHeight + 4)
    Layout.rightMargin: Theme.ui.padding.sm
    Layout.preferredWidth: Preferences.focusedMode ? 24 : icon.implicitWidth
    color: Qt.alpha(hoverBgColor, 0)
    radius: Preferences.focusedMode ? 1 : Theme.ui.radius.md

    readonly property color iconColor: Preferences.darkMode ? Colors.secondary : Colors.primary
    readonly property color hoverIconColor: Preferences.darkMode ? Colors.on_primary_container : Colors.on_primary_container
    readonly property color hoverBgColor: Preferences.focusedMode ? Qt.alpha(Colors.primary_container, 0.3) : Colors.primary_container

    border {
        width: Preferences.focusedMode ? 1 : 0
        color: Preferences.focusedMode ? Qt.alpha(Colors.primary, 0.6) : Colors.outline
    }

    Rectangle {
        visible: Preferences.focusedMode
        width: 6
        height: 1
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.bottomMargin: -0.5
        anchors.rightMargin: 2
        color: Colors.primary
        opacity: 0.7
    }

    MaterialSymbol {
        id: icon
        fontColor: root.iconColor
        anchors.centerIn: parent
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
            parent.color = Qt.alpha(root.hoverBgColor, 0);
        }

        onPressed: {
            GlobalStates.powerPanelOpen = true;
        }
    }
}
