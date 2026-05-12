import QtQuick
import QtQuick.Effects

Image {
    id: root
    required property color color

    sourceSize.width: width * 2
    sourceSize.height: height * 2
    fillMode: Image.PreserveAspectFit
    smooth: true
    mipmap: true
    asynchronous: true

    layer.enabled: true
    layer.effect: MultiEffect {
        colorization: 1.0
        colorizationColor: root.color
    }
}
