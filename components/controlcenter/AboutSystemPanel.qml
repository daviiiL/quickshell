pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell

import qs.services
import qs.widgets
import qs.common

Rectangle {
    id: root
    color: "transparent"

    property int padding: Theme.ui.padding.lg

    onVisibleChanged: {
        if (visible && SystemInfo.loaded) {
            refreshTimer.restart();
        } else {
            refreshTimer.stop();
        }
    }

    Text {
        id: titleText
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            margins: Theme.ui.padding.lg
        }

        text: "About This System"
        font {
            pixelSize: Theme.font.size.xxl
            family: Theme.font.family.inter_bold
            weight: Font.Bold
        }

        antialiasing: true
        color: Colors.on_surface
    }

    Rectangle {
        id: loadingRect
        visible: !SystemInfo.loaded
        anchors {
            top: titleText.bottom
            left: parent.left
            right: parent.right
            margins: Theme.ui.padding.lg
        }
        height: 60
        color: Colors.surface_container_high
        radius: Theme.ui.radius.md

        Text {
            anchors.centerIn: parent
            text: "Loading system information..."
            color: Colors.on_surface
            font {
                pixelSize: Theme.font.size.md
                family: Theme.font.family.inter_regular
            }
        }
    }

    ListView {
        visible: SystemInfo.loaded
        anchors {
            top: titleText.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            margins: Theme.ui.padding.lg
            bottomMargin: 0
        }

        clip: true
        spacing: Theme.ui.padding.md

        model: ScriptModel {
            values: {
                var items = [];

                items.push({
                    type: "device",
                    title: "Device Information",
                    icon: "computer"
                });

                items.push({
                    type: "cpu",
                    title: "Processor",
                    icon: "memory"
                });

                if (SystemInfo.gpus.length > 0) {
                    for (var i = 0; i < SystemInfo.gpus.length; i++) {
                        items.push({
                            type: "gpu",
                            title: SystemInfo.gpus.length > 1 ? `Graphics ${i + 1}` : "Graphics",
                            icon: "devices",
                            index: i
                        });
                    }
                }

                items.push({
                    type: "memory",
                    title: "Memory",
                    icon: "storage"
                });

                items.push({
                    type: "storage",
                    title: "Storage",
                    icon: "hard_drive"
                });

                items.push({
                    type: "refresh",
                    title: "",
                    icon: ""
                });

                var rows = [];
                var cellMinWidth = 350;
                var spacing = Theme.ui.padding.md;
                var availableWidth = root.width - (Theme.ui.padding.lg * 2);
                var columns = Math.max(1, Math.floor((availableWidth + spacing) / (cellMinWidth + spacing)));

                for (var j = 0; j < items.length; j += columns) {
                    var rowItems = [];
                    var isRefresh = false;

                    for (var k = 0; k < columns && (j + k) < items.length; k++) {
                        var item = items[j + k];
                        rowItems.push(item);
                        if (item.type === "refresh") {
                            isRefresh = true;
                        }
                    }

                    rows.push({
                        items: rowItems,
                        isRefresh: isRefresh
                    });
                }

                return rows;
            }
        }

        delegate: RowLayout {
            id: infoLayoutRoot
            required property var modelData

            width: ListView.view.width
            spacing: Theme.ui.padding.md

            Repeater {
                model: parent.modelData.items

                Item {
                    required property var modelData

                    Layout.fillWidth: true
                    Layout.preferredHeight: modelData.type === "refresh" ? 60 : 280

                    Loader {
                        id: cardLoader
                        anchors.fill: parent

                        sourceComponent: {
                            switch (infoLayoutRoot.modelData.type) {
                            case "device":
                                return deviceCard;
                            case "cpu":
                                return cpuCard;
                            case "gpu":
                                return gpuCard;
                            case "memory":
                                return memoryCard;
                            case "storage":
                                return storageCard;
                            case "refresh":
                                return refreshButton;
                            default:
                                return null;
                            }
                        }

                        onLoaded: {
                            if (infoLayoutRoot.modelData.type === "gpu" && item) {
                                item.gpuTitle = infoLayoutRoot.modelData.title;
                                item.gpuIndex = infoLayoutRoot.modelData.index;
                            }
                        }
                    }
                }
            }
        }
    }

    Component {
        id: deviceCard
        InfoCard {
            title: "Device Information"
            icon: "computer"

            InfoRow {
                label: "Device"
                value: `${SystemInfo.hostVendor} ${SystemInfo.hostModel}`
            }

            InfoRow {
                label: "Operating System"
                value: SystemInfo.osPrettyName
            }

            InfoRow {
                label: "OS Version"
                value: SystemInfo.osVersion
            }

            InfoRow {
                label: "Kernel"
                value: `${SystemInfo.kernelVersion} (${SystemInfo.kernelArchitecture})`
            }
        }
    }

    Component {
        id: cpuCard
        InfoCard {
            title: "Processor"
            icon: "memory"

            InfoRow {
                label: "CPU"
                value: SystemInfo.cpuModel
            }

            InfoRow {
                label: "Cores / Threads"
                value: `${SystemInfo.cpuCores} cores / ${SystemInfo.cpuThreads} threads`
            }

            InfoRow {
                label: "Frequency"
                value: `${SystemInfo.cpuBaseFrequency} MHz (Max: ${SystemInfo.cpuMaxFrequency} MHz)`
                visible: SystemInfo.cpuMaxFrequency > 0
            }
        }
    }

    Component {
        id: gpuCard
        InfoCard {
            property string gpuTitle: ""
            property int gpuIndex: 0

            title: gpuTitle
            icon: "devices"

            InfoRow {
                label: "GPU"
                value: SystemInfo.gpus[gpuIndex]?.name || ""
            }

            InfoRow {
                label: "Vendor"
                value: SystemInfo.gpus[gpuIndex]?.vendor || ""
            }

            InfoRow {
                label: "Type"
                value: SystemInfo.gpus[gpuIndex]?.type || ""
            }

            InfoRow {
                label: "Driver"
                value: SystemInfo.gpus[gpuIndex]?.driver || ""
            }
        }
    }

    Component {
        id: memoryCard
        InfoCard {
            title: "Memory"
            icon: "storage"

            InfoRow {
                label: "Total RAM"
                value: SystemInfo.formatBytes(SystemInfo.memoryTotal)
            }

            InfoRow {
                label: "Used RAM"
                value: `${SystemInfo.formatBytes(SystemInfo.memoryUsed)} (${Math.round(SystemInfo.memoryPercentage * 100)}%)`
            }

            MemoryProgressBar {
                Layout.fillWidth: true
                Layout.preferredHeight: 20
                Layout.topMargin: Theme.ui.padding.sm
                value: SystemInfo.memoryPercentage
            }
        }
    }

    Component {
        id: storageCard
        InfoCard {
            title: "Storage"
            icon: "hard_drive"

            InfoRow {
                label: "Total Capacity"
                value: SystemInfo.formatBytes(SystemInfo.diskTotal)
            }

            InfoRow {
                label: "Used"
                value: `${SystemInfo.formatBytes(SystemInfo.diskUsed)} (${Math.round(SystemInfo.diskPercentage * 100)}%)`
            }

            InfoRow {
                label: "Available"
                value: SystemInfo.formatBytes(SystemInfo.diskAvailable)
            }

            StorageProgressBar {
                Layout.fillWidth: true
                Layout.preferredHeight: 20
                Layout.topMargin: Theme.ui.padding.sm
                value: SystemInfo.diskPercentage
            }
        }
    }

    Component {
        id: refreshButton
        Item {
            width: parent.width
            height: 60

            Rectangle {
                width: 120
                height: 40
                anchors.centerIn: parent

                radius: Theme.ui.radius.md
                color: refreshMouseArea.containsMouse ? Colors.primary_container : Colors.surface_container_high

                Behavior on color {
                    ColorAnimation {
                        duration: 150
                        easing.type: Easing.InOutQuad
                    }
                }

                RowLayout {
                    anchors.centerIn: parent
                    spacing: Theme.ui.padding.sm

                    MaterialSymbol {
                        icon: "refresh"
                        iconSize: Theme.font.size.lg
                        fontColor: refreshMouseArea.containsMouse ? Colors.on_primary_container : Colors.on_surface
                    }

                    Text {
                        text: "Refresh"
                        color: refreshMouseArea.containsMouse ? Colors.on_primary_container : Colors.on_surface
                        font {
                            pixelSize: Theme.font.size.md
                            family: Theme.font.family.inter_medium
                            weight: Font.Medium
                        }
                    }
                }

                MouseArea {
                    id: refreshMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor

                    onClicked: SystemInfo.refresh()
                }
            }
        }
    }

    component InfoCard: Rectangle {
        id: card

        required property string title
        required property string icon
        default property alias content: contentLayout.children

        width: parent.width
        height: contentLayout.implicitHeight + root.padding * 2

        color: Colors.surface_container_high
        radius: Theme.ui.radius.md

        ColumnLayout {
            id: contentLayout
            anchors.fill: parent
            anchors.margins: root.padding
            spacing: Theme.ui.padding.md

            RowLayout {
                spacing: Theme.ui.padding.sm

                MaterialSymbol {
                    icon: card.icon
                    iconSize: Theme.font.size.xl
                    fontColor: Colors.primary
                }

                Text {
                    text: card.title
                    font {
                        pixelSize: Theme.font.size.lg
                        family: Theme.font.family.inter_bold
                        weight: Font.Bold
                    }
                    color: Colors.on_surface
                }
            }
        }
    }

    component InfoRow: RowLayout {
        id: infoRow
        required property string label
        required property string value

        property int gpuIndex

        Layout.fillWidth: true
        spacing: Theme.ui.padding.md

        Text {
            Layout.preferredWidth: 150
            text: infoRow.label
            color: Colors.secondary
            font {
                pixelSize: Theme.font.size.md
                family: Theme.font.family.inter_regular
            }
            wrapMode: Text.NoWrap
        }

        Text {
            Layout.fillWidth: true
            text: infoRow.value
            color: Colors.on_surface
            font {
                pixelSize: Theme.font.size.md
                family: Theme.font.family.inter_medium
                weight: Font.Medium
            }
            wrapMode: Text.Wrap
        }
    }

    component MemoryProgressBar: Rectangle {
        id: memoryBar
        required property real value

        color: Colors.surface_container
        radius: Theme.ui.radius.sm

        Rectangle {
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: parent.width * Math.min(memoryBar.value, 1)
            radius: parent.radius

            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop {
                    position: 0.0
                    color: Colors.primary
                }
                GradientStop {
                    position: 1.0
                    color: Qt.lighter(Colors.primary, 1.2)
                }
            }

            Behavior on width {
                NumberAnimation {
                    duration: 300
                    easing.type: Easing.InOutQuad
                }
            }
        }
    }

    component StorageProgressBar: Rectangle {
        id: storageProgressBar
        required property real value

        color: Colors.surface_container
        radius: Theme.ui.radius.sm

        property color barColor: {
            if (storageProgressBar.value >= 0.9) {
                return "#dc2626";
            } else if (storageProgressBar.value >= 0.75) {
                return "#f59e0b";
            } else {
                return "#10b981";
            }
        }

        Rectangle {
            id: storageBar
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: parent.width * Math.min(storageProgressBar.value, 1)
            radius: parent.radius

            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop {
                    position: 0.0
                    color: storageProgressBar.barColor
                }
                GradientStop {
                    position: 1.0
                    color: Qt.lighter(storageProgressBar.barColor, 1.2)
                }
            }

            Behavior on width {
                NumberAnimation {
                    duration: 300
                    easing.type: Easing.InOutQuad
                }
            }
        }
    }

    Timer {
        id: refreshTimer
        interval: 5000
        running: false
        repeat: true
        onTriggered: {
            // console.debug("AboutSystemPanel: Timer triggered, calling SystemInfo.refresh()");
            SystemInfo.refresh();
        }
    }

    Connections {
        target: SystemInfo
        function onLoadedChanged() {
            if (SystemInfo.loaded && root.visible) {
                // console.debug("AboutSystemPanel: Timer restarted (loaded)");
                refreshTimer.restart();
            }
        }
    }
}
