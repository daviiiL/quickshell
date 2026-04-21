pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.common
import qs.services
import qs.modules.notifications

Scope {
    id: scope

    Loader {
        id: panelLoader
        active: PopupStackController.cards.length > 0

        sourceComponent: PanelWindow {
            id: win

            screen: {
                const name = SystemNiri.focusedOutput;
                const screens = Quickshell.screens;
                for (let i = 0; i < screens.length; i++) {
                    if (screens[i].name === name) return screens[i];
                }
                return screens[0] ?? null;
            }

            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.namespace: "quickshell:notifications"
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

            anchors { top: true; right: true }
            implicitWidth: 340 + 40
            implicitHeight: 600
            exclusiveZone: 0
            color: "transparent"

            Item {
                anchors.fill: parent
                anchors.topMargin: 20
                anchors.rightMargin: 20

                Repeater {
                    model: ScriptModel {
                        values: PopupStackController.cards
                    }

                    delegate: PopupCard {
                        id: cardDelegate
                        required property int index
                        required property var modelData
                        card: modelData
                        role: {
                            void PopupStackController._exitStateVersion;
                            if (modelData.exiting) return "dismissing";
                            let nonExitingIdx = 0;
                            const all = PopupStackController.cards;
                            for (let i = 0; i < index; i++) {
                                if (!all[i].exiting) nonExitingIdx++;
                            }
                            return nonExitingIdx === 0 ? "active"
                                 : nonExitingIdx === 1 ? "peek1"
                                 : nonExitingIdx === 2 ? "peek2"
                                 : "hidden";
                        }
                        visible: role !== "hidden"

                        anchors.top: parent?.top
                        anchors.right: parent?.right

                        onDismissRequested: (id, reason) => PopupStackController.beginExit(id)
                        onDefaultActionRequested: (id) => Notifications.attemptInvokeAction(id, "default")
                        onExitFinished: (id) => {
                            const allIds = [cardDelegate.card.id, ...cardDelegate.card.mergeIds];
                            allIds.forEach(mid => Notifications.timeoutNotification(mid));
                            PopupStackController.finalizeRemoval(id);
                        }
                        onPauseRequested: (id) => PopupStackController.pause(id)
                        onResumeRequested: (id) => PopupStackController.resume(id)

                        Connections {
                            target: PopupStackController
                            function onExitStarted(id) {
                                if (cardDelegate.card?.id === id) cardDelegate.exiting = true;
                            }
                        }
                    }
                }
            }
        }
    }
}
