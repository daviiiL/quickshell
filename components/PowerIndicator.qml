import QtQuick
import QtQuick.Layouts
import qs.common
import qs.services
import qs.components.widgets

ExpandingContainer {
    id: root

    function formatTime(seconds) {
        if (seconds <= 0)
            return "--:--";

        var hours = Math.floor(seconds / 3600);
        var minutes = Math.floor((seconds % 3600) / 60);
        if (hours > 0)
            return hours + "h " + minutes + "m";
        else
            return minutes + "m";
    }

    implicitHeight: 30
    collapsedWidth: Theme.bar.width
    expandedWidth: Theme.bar.width * 4
    collapsedHeight: root.implicitHeight
    expandedHeight: root.expandedWidth
    color: Colors.current.background
    verticalExpansion: true
    animationDuration: 250

    CircularProgress {
        id: progressIndicator

        value: Power.percentage
        anchors.left: parent.left
        anchors.leftMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        primaryColor: Power.onBattery ? Colors.current.on_secondary_container : Colors.current.primary_fixed

        transform: Rotation {
            id: rotation

            origin.x: progressIndicator.width / 2
            origin.y: progressIndicator.height / 2
            angle: root.expanded ? -360 : 0

            Behavior on angle {
                NumberAnimation {
                    duration: root.animationDuration * 1.5
                    easing.type: Easing.OutCubic
                }
            }
        }

        SequentialAnimation on opacity {
            running: !Power.onBattery
            loops: Animation.Infinite

            NumberAnimation {
                from: 1
                to: 0.4
                duration: 1000
                easing.type: Easing.InOutSine
            }

            NumberAnimation {
                from: 0.4
                to: 1
                duration: 1000
                easing.type: Easing.InOutSine
            }
        }
    }

    Rectangle {
        id: contentContainer

        color: root.color
        radius: Theme.rounding.regular
        opacity: root.expanded ? 1 : 0

        anchors {
            left: progressIndicator.right
            top: parent.top
            bottom: parent.bottom
            right: parent.right
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.leftMargin: 10
            anchors.topMargin: 20

            Text {
                id: timeText

                text: {
                    if (Power.percentage > 0.999)
                        return "Fully charged";

                    return `  ${root.formatTime(Power.timeToGoal)} ${Power.onBattery ? "remaining" : "to full"}`;
                }
                color: Colors.current.primary
                font.pointSize: Theme.font.size.regular
                font.family: Theme.font.style.departureMono
            }

            ColumnLayout {
                id: powerProfiles

                spacing: 10

                PowerProfileButton {
                    profile: "PowerSaver"
                    icon: "energy_savings_leaf"
                    isActive: Power.currentProfile === "PowerSaver"
                    onClicked: Power.setPowerProfile("PowerSaver")
                }

                PowerProfileButton {
                    profile: "Balanced"
                    icon: "balance"
                    isActive: Power.currentProfile === "Balanced"
                    onClicked: Power.setPowerProfile("Balanced")
                }

                PowerProfileButton {
                    profile: "Performance"
                    icon: "rocket_launch"
                    isActive: Power.currentProfile === "Performance"
                    onClicked: Power.setPowerProfile("Performance")
                }
            }
        }

        Behavior on opacity {
            NumberAnimation {
                duration: root.animationDuration
                easing.type: Easing.OutCubic
            }
        }
    }

    component PowerProfileButton: Rectangle {
        id: profile

        property string profile
        property string icon
        property bool isActive

        signal clicked

        implicitHeight: profileText.implicitHeight + 12
        implicitWidth: 140
        color: profile.isActive ? Colors.current.primary_container : Colors.current.secondary_container
        radius: Theme.rounding.small

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onPressed: profile.clicked()
        }

        Text {
            id: profileText

            text: profile.profile
            anchors.centerIn: parent
            horizontalAlignment: Text.AlignHCenter
            color: profile.isActive ? Colors.current.on_primary_container : Colors.current.on_secondary_container
            font.pointSize: Theme.font.size.regular
            font.family: Theme.font.style.departureMono
        }
    }
}
