import "../common/"
import "../components"
import "../components/widgets"
import "../services/"
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

Scope {
    id: root

    property real currentBrightness: 0
    property bool visible: false
    property int animationDuration: 100
    property bool brightnessDisabled: false

    function getBrightnessIcon(val) {
        const numString = (val * 0.05 >= 1 ? val * 0.05 : 1).toFixed(0);
        return "brightness_" + numString;
    }

    Connections {
        function onVolumeChanged() {
            root.visible = true;
            hideTimer.restart();
            fadeTimer.restart();
        }

        function onMutedChanged() {
            root.visible = true;
            hideTimer.restart();
            fadeTimer.restart();
        }

        target: Audio.defaultSinkAudio
    }

    Connections {
        function onBrightnessChanged(val) {
            root.visible = true;
            root.currentBrightness = val;
            hideTimer.restart();
            fadeTimer.restart();
        }

        function onBrightnessCtlOff(disabled) {
            root.brightnessDisabled = disabled;
        }

        target: Brightness
    }

    Timer {
        id: hideTimer

        interval: 1500
        onTriggered: {
            root.visible = false;
        }
    }

    Timer {
        id: fadeTimer

        property bool shouldFade: false

        interval: hideTimer.interval - root.animationDuration
        onTriggered: {
            shouldFade = true;
        }
    }

    LazyLoader {
        active: root.visible

        PanelWindow {
            id: osd

            anchors.right: true
            margins.right: 10
            implicitWidth: root.brightnessDisabled ? 80 : 140
            implicitHeight: 400
            color: "transparent"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.exclusiveZone: 0

            Rectangle {
                id: rect

                anchors.fill: parent
                radius: Theme.rounding.xs
                color: Colors.current.secondary_container
                opacity: 0
                Component.onCompleted: function() {
                    Qt.callLater(() => {
                        this.opacity = 1;
                    });
                }

                Connections {
                    function onVisibleChanged() {
                        if (root.visible) {
                            rect.opacity = 1;
                            fadeTimer.shouldFade = false;
                        }
                    }

                    target: root
                }

                Connections {
                    function onShouldFadeChanged() {
                        if (fadeTimer.shouldFade)
                            rect.opacity = 0;

                    }

                    target: fadeTimer
                }

                RowLayout {
                    spacing: 10

                    anchors {
                        top: parent.top
                        left: parent.left
                        right: parent.right
                        bottom: parent.bottom
                        leftMargin: 10
                        rightMargin: 10
                    }

                    Rectangle {
                        id: volume

                        property real barHeight: volume.height * (Audio.volume > 1 ? 1 : Audio.volume) || 0.1

                        implicitHeight: 380
                        implicitWidth: root.brightnessDisabled ? (osd.width - 20) : (osd.width - 30) / 2
                        radius: Theme.rounding.xs
                        color: Colors.current.primary_container

                        Rectangle {
                            height: volume.barHeight
                            radius: Theme.rounding.xs
                            color: Audio.muted ? Colors.current.primary_container : (Audio.isOverdrive ? Colors.current.on_error_container : Colors.current.on_primary_container)

                            anchors {
                                left: parent.left
                                right: parent.right
                                bottom: parent.bottom
                            }

                            Text {
                                visible: Audio.isOverdrive
                                text: {
                                    (Audio.volume * 100).toFixed(0) + "%";
                                }
                                anchors.centerIn: parent
                                color: Colors.current.error_container
                                font.family: Theme.font.style.departureMono
                                font.styleName: "Bold"
                                font.pointSize: 15
                            }

                            MaterialSymbol {
                                colorAnimated: true
                                icon: Audio.volume == 0 || Audio.muted ? "volume_off" : (Audio.volume >= 0.5 ? "volume_up" : "volume_down")
                                fontColor: Audio.isOverdrive ? Colors.current.error_container : (Audio.volume <= 0.1 || Audio.muted ? Colors.current.on_primary_container : Colors.current.primary_container)

                                anchors {
                                    bottomMargin: 2
                                    bottom: parent.bottom
                                    horizontalCenter: parent.horizontalCenter
                                }

                            }

                            Behavior on height {
                                NumberAnimation {
                                    duration: root.animationDuration
                                    easing.type: Easing.BezierSpline
                                    easing.bezierCurve: Theme.anim.curves.expressiveFastSpatial
                                }

                            }

                            Behavior on color {
                                ColorAnimation {
                                    duration: root.animationDuration
                                    easing.type: Easing.BezierSpline
                                    easing.bezierCurve: Theme.anim.curves.standard
                                }

                            }

                        }

                    }

                    Rectangle {
                        id: brightness

                        property real barHeight: height * (root.currentBrightness / 100) || 0.1

                        visible: !root.brightnessDisabled
                        implicitWidth: (osd.width - 30) / 2
                        implicitHeight: 380
                        radius: Theme.rounding.xs
                        color: Colors.current.primary_container

                        Rectangle {
                            height: brightness.barHeight
                            radius: Theme.rounding.xs
                            color: Colors.current.on_primary_container

                            anchors {
                                left: parent.left
                                right: parent.right
                                bottom: parent.bottom
                            }

                            MaterialSymbol {
                                colorAnimated: true
                                icon: getBrightnessIcon(root.currentBrightness)
                                fontColor: root.currentBrightness <= 5 ? parent.color : Colors.current.primary_container

                                anchors {
                                    bottomMargin: 2
                                    bottom: parent.bottom
                                    horizontalCenter: parent.horizontalCenter
                                }

                            }

                            Behavior on height {
                                NumberAnimation {
                                    duration: root.animationDuration
                                    easing.type: Easing.BezierSpline
                                    easing.bezierCurve: Theme.anim.curves.expressiveFastSpatial
                                }

                            }

                        }

                    }

                }

                Behavior on opacity {
                    NumberAnimation {
                        duration: root.animationDuration
                    }

                }

            }

            mask: Region {
            }

            Behavior on implicitWidth {
                NumberAnimation {
                    duration: root.animationDuration
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: Theme.anim.curves.standard
                }

            }

        }

    }

}
