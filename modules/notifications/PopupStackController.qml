pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import qs.common
import qs.services

Singleton {
    id: root

    readonly property int minReadTime: 3000
    readonly property int normalTimeout: 7000
    readonly property int lowTimeout: 4000

    signal exitStarted(int id)

    // Suppression gates. The service's `popupInhibited` already prevents NEW
    // notifs from popping when sidebar/silent is set; these properties handle
    // the runtime case where the gate flips while popups are already on screen.
    // Critical popups survive sidebar/launcher but not silent (DND).
    readonly property bool suppressedNonCritical: GlobalStates.rightPanelOpen
                                                || GlobalStates.appLauncherOpen
                                                || Notifications.silent
    readonly property bool suppressedAll: Notifications.silent

    onSuppressedNonCriticalChanged: {
        if (!root.suppressedNonCritical) return;
        root.cards.forEach(c => {
            if (c.exiting || c.urgency === "critical") return;
            Notifications.timeoutNotification(c.id);
            c.mergeIds.forEach(mid => Notifications.timeoutNotification(mid));
        });
    }

    onSuppressedAllChanged: {
        if (!root.suppressedAll) return;
        root.cards.forEach(c => {
            if (c.exiting) return;
            Notifications.timeoutNotification(c.id);
            c.mergeIds.forEach(mid => Notifications.timeoutNotification(mid));
        });
    }

    // Bumped whenever a card's `exiting` flag changes so Surface role bindings
    // re-evaluate without replacing the `cards` reference (which would rebuild
    // all Repeater delegates and destroy in-flight promotion animations).
    property int _exitStateVersion: 0

    // { id, notif, mergeIds: [int], mergeCount: int, urgency: string,
    //   activatedAt: number, createdAt: number, exiting: bool }
    property var cards: []

    function _emit() { root.cards = root.cards.slice(0); }

    function _findIndexById(id) {
        for (let i = 0; i < root.cards.length; i++) {
            if (root.cards[i].id === id || root.cards[i].mergeIds.indexOf(id) !== -1) return i;
        }
        return -1;
    }

    function _reconcile() {
        const popupList = Notifications.popupList;

        const popupIds = {};
        for (const n of popupList) popupIds[n.notificationId] = true;

        // Do NOT rebuild the cards array — ScriptModel rebuilds delegates on
        // every reference change, destroying the delegate mid-exit-animation.
        // Mutate in place and bump the version counter so role bindings re-evaluate.
        for (const c of root.cards) {
            if (c.exiting) continue;
            const stillLive = popupIds[c.id] === true
                           || c.mergeIds.some(mid => popupIds[mid] === true);
            if (!stillLive) {
                _cancelTimer(c.id);
                c.exiting = true;
                root._exitStateVersion++;
                root.exitStarted(c.id);
            }
        }

        for (const notif of popupList) {
            const id = notif.notificationId;
            if (_findIndexById(id) !== -1) continue;

            const urg = (notif.urgency ?? "").toString().toLowerCase();

            // Same-app merge: fold the new notif into an existing non-exiting,
            // non-critical card. The new id becomes primary; the old id parks in
            // mergeIds so reconcile still recognizes the family.
            if (urg !== "critical") {
                const mergeTarget = root.cards.find(c =>
                    !c.exiting && c.urgency !== "critical" && c.notif?.appName && c.notif.appName === notif.appName
                );
                if (mergeTarget) {
                    mergeTarget.mergeIds = [...mergeTarget.mergeIds, mergeTarget.id];
                    mergeTarget.id = id;
                    mergeTarget.notif = notif;
                    mergeTarget.mergeCount += 1;
                    mergeTarget.urgency = urg;
                    mergeTarget.activatedAt = Date.now();
                    mergeTarget.timeoutMs = _computeTimeoutForCard(mergeTarget);
                    Notifications.cancelTimeout(id);
                    if (root.cards[0] === mergeTarget) _startTimer(mergeTarget);
                    console.warn("[PopupStack] merge id=" + id + " app=" + notif.appName + " mergeCount=" + mergeTarget.mergeCount);
                    continue;
                }
            }

            const now = Date.now();
            const card = { id, notif, mergeIds: [], mergeCount: 0, urgency: urg,
                           activatedAt: now, createdAt: now, exiting: false };
            card.timeoutMs = _computeTimeoutForCard(card);
            root.cards = [...root.cards, card];
            console.warn("[PopupStack] push id=" + id + " app=" + notif.appName + " urgency=" + urg);
            Notifications.cancelTimeout(id);
            if (root.cards[0] === card) _startTimer(card);
        }

        const activeCard = root.cards.find(c => !c.exiting);
        if (activeCard && !root._timers[activeCard.id]) {
            activeCard.activatedAt = Date.now();
            _startTimer(activeCard);
        }
    }

    Component {
        id: cardTimerComponent
        Timer {
            property int cardId
            repeat: false
            running: false
        }
    }

    property var _timers: ({})   // id -> Timer instance

    function _timeoutForUrgency(u) {
        if (u === "critical") return -1;
        if (u === "low")      return root.lowTimeout;
        return root.normalTimeout;
    }

    function _computeTimeoutForCard(card) {
        if (card.urgency === "critical") return 0;
        const expire = card.notif?.notification?.expireTimeout ?? -1;
        const base = expire > 0 ? expire : _timeoutForUrgency(card.urgency);
        return Math.max(base, root.minReadTime);
    }

    function finalizeRemoval(id) {
        const i = root._findIndexById(id);
        if (i !== -1) {
            root.cards.splice(i, 1);
            root._emit();
        }
    }

    function beginExit(id) {
        const c = root.cards.find(x => x.id === id);
        if (!c || c.exiting) return;
        c.exiting = true;
        _cancelTimer(id);
        root._exitStateVersion++;
        root.exitStarted(id);
    }

    function _startTimer(card) {
        const dur = card.timeoutMs ?? 0;
        if (dur <= 0) return;
        _cancelTimer(card.id);
        const age = Date.now() - (card.activatedAt ?? Date.now());
        const effective = Math.max(dur - age, 0);
        if (effective <= 0) {
            Qt.callLater(() => root.beginExit(card.id));
            return;
        }
        const t = cardTimerComponent.createObject(root, { cardId: card.id, interval: effective });
        t.triggered.connect(() => root.beginExit(card.id));
        t.start();
        root._timers[card.id] = t;
    }

    function _cancelTimer(id) {
        const t = root._timers[id];
        if (t) {
            t.stop();
            t.destroy();
            delete root._timers[id];
        }
    }

    property var _pauseState: ({})   // id -> remaining ms at pause time

    function pause(id) {
        const card = root.cards.find(c => c.id === id);
        if (!card) return;
        const t = root._timers[id];
        if (!t || !t.running) return;
        const elapsed = Date.now() - (card.activatedAt ?? Date.now());
        const remaining = Math.max((card.timeoutMs ?? 0) - elapsed, 0);
        root._pauseState[id] = remaining;
        _cancelTimer(id);
    }

    function resume(id) {
        const remaining = root._pauseState[id];
        if (remaining === undefined) return;
        delete root._pauseState[id];
        const card = root.cards.find(c => c.id === id);
        if (!card) return;
        card.activatedAt = Date.now() - ((card.timeoutMs ?? 0) - remaining);
        _startTimer(card);
    }

    Connections {
        target: Notifications
        function onPopupListChanged() { root._reconcile(); }
    }

    Component.onCompleted: root._reconcile()
}
