import QtQuick
import qs.config
import qs.services
import qs.widgets

BarPill {
    id: root

    visible: Media.active
    hPadding: 10
    spacing: 6
    onClicked: mouse => {
        if (mouse.button === Qt.MiddleButton)
            Media.next();
        else if (mouse.button === Qt.RightButton)
            Ui.toggle("control");
        else
            Media.toggle();
    }
    onWheel: wheel => wheel.angleDelta.y > 0 ? Media.previous() : Media.next()

    MaterialIcon {
        anchors.verticalCenter: parent.verticalCenter
        icon: Media.playing ? "graphic_eq" : "pause_circle"
        color: Theme.primary
        size: 18
        fill: 1
    }

    StyledText {
        anchors.verticalCenter: parent.verticalCenter
        width: Math.min(implicitWidth, 240)
        text: Media.artist ? `${Media.title} · ${Media.artist}` : Media.title
        color: Theme.fgVariant
    }
}
