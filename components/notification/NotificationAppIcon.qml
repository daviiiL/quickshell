import QtQuick
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Notifications
import "notification_utils.js" as NotificationUtils
import "../../common"
import "../widgets"

MaterialCookie {
    id: root
    property var appIcon: ""
    property var summary: ""
    property var urgency: NotificationUrgency.Normal
    property bool isUrgent: urgency === NotificationUrgency.Critical
    property var image: ""
    property real materialIconScale: 0.57
    property real appIconScale: 0.8
    property real materialIconSize: implicitSize * materialIconScale
    property real appIconSize: implicitSize * appIconScale

    implicitSize: (image != "" ? 32 : 38) * scale
    sides: isUrgent ? 10 : 0
    amplitude: implicitSize / 24

    color: isUrgent ? Colors.current.error : Colors.current.secondary_container

    // Material symbol when no app icon
    Loader {
        id: materialSymbolLoader
        active: root.appIcon == ""
        anchors.centerIn: parent
        sourceComponent: MaterialSymbol {
            icon: {
                const defaultIcon = NotificationUtils.findSuitableMaterialSymbol("")
                const guessedIcon = NotificationUtils.findSuitableMaterialSymbol(root.summary)
                return (root.urgency == NotificationUrgency.Critical && guessedIcon === defaultIcon) ?
                    "priority_high" : guessedIcon
            }
            iconSize: root.materialIconSize
            fontColor: isUrgent ? Colors.current.on_error : Colors.current.on_secondary_container
        }
    }

    // App icon when available and no image
    Loader {
        id: appIconLoader
        active: root.image == "" && root.appIcon != ""
        anchors.centerIn: parent
        sourceComponent: IconImage {
            id: appIconImage
            implicitSize: root.appIconSize
            asynchronous: true
            source: Quickshell.iconPath(root.appIcon, "image-missing")
        }
    }

    // Notification image when available
    Loader {
        id: notifImageLoader
        active: root.image != ""
        anchors.fill: parent
        sourceComponent: Item {
            anchors.fill: parent

            Rectangle {
                id: mask
                anchors.fill: parent
                radius: parent.width / 2
                visible: false
            }

            Image {
                id: notifImage
                anchors.fill: parent
                readonly property int size: parent.width

                source: root.image
                fillMode: Image.PreserveAspectCrop
                cache: false
                antialiasing: true
                asynchronous: true

                width: size
                height: size
                sourceSize.width: size
                sourceSize.height: size

                layer.enabled: true
                layer.samplerName: "maskSource"
            }
        }
    }
}
