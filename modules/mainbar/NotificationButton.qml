pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.common
import qs.services

MainBarButton {
    id: root

    readonly property int unread: (typeof Notifications !== "undefined"
                                   && Notifications.unread !== undefined)
                                    ? Notifications.unread
                                    : 3

    onActivated: {}

    contentPadX: 9

    Image {
        Layout.preferredWidth:  Theme.ui.mainBarIconSize
        Layout.preferredHeight: Theme.ui.mainBarIconSize
        source: "../../assets/icons/bell.svg"
        sourceSize.width: Theme.ui.mainBarIconSize * 2
        sourceSize.height: Theme.ui.mainBarIconSize * 2
        smooth: true
        opacity: root.hovered ? 1.0 : 0.56
        Behavior on opacity { NumberAnimation { duration: 150; easing.type: Easing.InOutQuad } }
    }

    Rectangle {
        Layout.preferredHeight: 20
        Layout.preferredWidth: 32
        radius: 2
        color: Colors.barAccent
        visible: root.unread > 0
        border.width: 1
        border.color: Qt.alpha("#ffffff", 0.15)

        Text {
            id: countLabel
            anchors.centerIn: parent
            text: root.unread
            color: "#0a0a0a"
            font.family: Theme.font.family.inter_bold
            font.weight: Font.Bold
            font.pixelSize: 12
        }
    }
}
