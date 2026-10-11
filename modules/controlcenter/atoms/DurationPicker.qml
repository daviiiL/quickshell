pragma ComponentBehavior: Bound

import QtQuick

DevicePicker {
    id: root

    property int seconds: 0
    property bool available: true

    signal picked(int seconds)

    enabled: available
    opacity: available ? 1 : 0.45

    readonly property var durations: [0, 60, 120, 300, 600, 900, 1800, 3600]

    function formatDuration(s: int): string {
        if (s <= 0) return "Never";
        if (s % 3600 === 0) return (s / 3600) + (s === 3600 ? " hour" : " hours");
        if (s % 60 === 0) return (s / 60) + (s === 60 ? " minute" : " minutes");
        return s + " s";
    }

    options: root.durations.map(d => ({ label: root.formatDuration(d), value: { id: d } }))
    currentValue: ({ id: root.seconds })
    currentLabel: root.formatDuration(root.seconds)

    onSelected: value => root.picked(value.id)
}
