import QtQuick
import "../../common"

Text {
    id: root

    renderType: Text.NativeRendering
    verticalAlignment: Text.AlignVCenter
    font {
        hintingPreference: Font.PreferDefaultHinting
        family: Theme.font.style.departureMono
        pixelSize: Theme.font.size.regular
    }
    color: Colors.current.on_surface
    linkColor: Colors.current.primary
}
