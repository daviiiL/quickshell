import QtQuick
import Quickshell
import qs.common
import qs.components.notification
import qs.services

Scope {
    id: root

    property bool visible: Notifications.popupList.length > 0
    property int animationDuration: 200
    property int popupWidth: 400
    property int maxHeight: 600

    LazyLoader {
        active: root.visible

        PanelWindow {
            id: popup

            anchors {
                left: true
                top: true
            }

            margins {
                top: 2
                left: 2
            }

            implicitWidth: root.popupWidth
            implicitHeight: contentRect.implicitHeight + 20
            color: "transparent"

            aboveWindows: true
            focusable: false

            Rectangle {
                id: contentRect
                anchors.fill: parent
                anchors.margins: 10
                radius: Theme.ui.radius.md
                color: Colors.primary_container
                opacity: 0
                implicitHeight: Math.min(listview.contentHeight + 20, root.maxHeight)

                Component.onCompleted: function () {
                    Qt.callLater(() => {
                        this.opacity = 1;
                    });
                }

                Connections {
                    function onVisibleChanged() {
                        if (root.visible) {
                            contentRect.opacity = 1;
                        }
                    }

                    target: root
                }

                NotificationListView {
                    id: listview
                    anchors.fill: parent
                    anchors.margins: 10
                    popup: true
                }

                Behavior on opacity {
                    NumberAnimation {
                        duration: root.animationDuration
                        easing.type: Easing.BezierSpline
                        easing.bezierCurve: Theme.anim.curves.standard
                    }
                }
            }

            mask: Region {}

            Behavior on implicitHeight {
                NumberAnimation {
                    duration: root.animationDuration
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: Theme.anim.curves.standard
                }
            }
        }
    }
}
