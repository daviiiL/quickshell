import QtQuick
import QtQuick.Layouts
import Quickshell
import "../components/"
import "../utils/"

ExpandingContainer {
    id: root

    // Dimensions
    implicitHeight: 30
    collapsedWidth: Theme.bar.width
    expandedWidth: Theme.bar.width * 4
    collapsedHeight: root.implicitHeight
    expandedHeight: root.expandedWidth

    // Appearance
    color: Colors.current.background
    verticalExpansion: true
    animationDuration: 250

    CircularProgress {
        id: progressIndicator
        value: Power.percentage
        anchors.left: parent.left
        anchors.leftMargin: 8
        anchors.verticalCenter: parent.verticalCenter

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
    }

    Rectangle {
        id: contentContainer
        anchors {
            left: progressIndicator.right
            top: parent.top
            bottom: parent.bottom
            right: parent.right
        }

        color: root.color
        radius: Theme.rounding.regular
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop {
                position: 0.0
                color: Colors.current.background
            }
            GradientStop {
                position: 1.0
                color: root.expanded ? Qt.darker(Colors.current.primary, 4.0) : Colors.current.background

                Behavior on color {
                    ColorAnimation {
                        duration: root.animationDuration
                        easing.type: Easing.InOutQuad
                    }
                }
            }
        }

        opacity: root.expanded ? 1 : 0

        Behavior on opacity {
            NumberAnimation {
                duration: root.animationDuration
                easing.type: Easing.OutCubic
            }
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.leftMargin: 10
            anchors.topMargin: 20

            Text {
                id: timeText
                text: {
                    if (Power.percentage > 0.999)
                        return "Fully charged  󰁹";
                    return `  ${root.formatTime(Power.timeToGoal)} ${Power.onBattery ? "remaining" : "to full"}`;
                }
                color: Colors.current.primary
                font.pointSize: Theme.font.size.regular
                font.family: Theme.font.style.inter
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
    }

    component PowerProfileButton: Rectangle {
        id: profile

        property string profile
        property string icon
        property bool isActive
        signal clicked

        implicitHeight: profileButton.implicitHeight
        implicitWidth: profileButton.implicitWidth

        color: "transparent"

        Rectangle {
            id: profileButton

            implicitHeight: profileIcon.implicitHeight
            implicitWidth: profileIcon.implicitWidth + 6
            color: profile.isActive ? Colors.current.primary_container : Colors.current.secondary_container
            radius: Theme.rounding.small

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onPressed: profile.clicked()
            }

            MaterialSymbol {
                id: profileIcon
                anchors.fill: parent
                anchors.leftMargin: 3
                anchors.rightMargin: 3
                icon: profile.icon
                fontColor: profile.isActive ? Colors.current.on_primary_container : Colors.current.secondary
            }
        }

        Text {
            text: profile.profile
            anchors.left: profileButton.right
            anchors.leftMargin: 8
            anchors.verticalCenter: profileButton.verticalCenter
            color: profile.isActive ? Colors.current.primary : Colors.current.secondary
            font.pointSize: Theme.font.size.regular
            font.family: Theme.font.style.inter
        }
    }

    function formatTime(seconds) {
        if (seconds <= 0)
            return "--:--";

        var hours = Math.floor(seconds / 3600);
        var minutes = Math.floor((seconds % 3600) / 60);

        if (hours > 0) {
            return hours + "h " + minutes + "m";
        } else {
            return minutes + "m";
        }
    }
}
