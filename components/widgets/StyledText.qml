import QtQuick
import qs.common

Text {
    id: root

    property var fontSize: Theme.font.size.regular

    renderType: Text.NativeRendering
    verticalAlignment: Text.AlignVCenter
    font {
        hintingPreference: Font.PreferDefaultHinting
        family: Theme.font.style.departureMono
        pixelSize: fontSize
    }
    color: Colors.current.on_surface
    linkColor: Colors.current.primary
}
