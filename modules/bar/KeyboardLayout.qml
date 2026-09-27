import QtQuick
import qs.config
import qs.services
import qs.widgets

BarPill {
    visible: Niri.keyboardLayouts.length > 1
    onClicked: Niri.action("switch-layout", "next")

    StyledText {
        anchors.verticalCenter: parent.verticalCenter
        text: Niri.keyboardLayout.slice(0, 2).toUpperCase()
        font.weight: Font.Bold
        font.pixelSize: Theme.fontSize.small
    }
}
