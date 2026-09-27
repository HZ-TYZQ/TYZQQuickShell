import QtQuick
import qs.config
import qs.services
import qs.widgets

BarPill {
    active: Ui.panel === "launcher"
    hPadding: 9
    onClicked: Ui.toggle("launcher")

    // Fedora logo from the Nerd Font
    Text {
        text: ""
        font.family: Theme.fontMono
        font.pixelSize: 20
        color: parent.parent.active ? Theme.fgPrimary : Theme.primary
        anchors.verticalCenter: parent.verticalCenter
    }
}
