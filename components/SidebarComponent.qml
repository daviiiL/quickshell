pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import qs
import qs.common
import qs.services
import qs.components.widgets
import qs.components.notification

Item {
    id: root
    required property var scopeRoot
    property int sidebarPadding: Theme.ui.padding.large
    anchors.fill: parent

    function focusActiveItem() {
        contentStack.forceActiveFocus();
    }

    Keys.onPressed: event => {
        if (event.key === Qt.Key_Escape) {
            GlobalStates.sidebarLeftOpen = false;
            event.accepted = true;
        }
    }

    TabBar {
        id: bar
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }

        TabButton {
            text: "Notifications"
        }
        TabButton {
            text: "ChatGPT"
        }
    }

    StackLayout {
        id: contentStack
        anchors.fill: parent
        currentIndex: bar.currentIndex
        Item {
            id: notifCenterTab
            NotificationCenterView {
                sidebarPadding: root.sidebarPadding
            }
        }
    }
}
