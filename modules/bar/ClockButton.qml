import QtQuick
import Quickshell
import qs.config
import qs.services
import qs.widgets

BarPill {
    id: root

    active: Ui.panel === "calendar"
    hPadding: 14
    spacing: 8
    onClicked: Ui.toggle("calendar")

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    StyledText {
        anchors.verticalCenter: parent.verticalCenter
        text: Qt.formatDateTime(clock.date, Config.options.use24h ? "HH:mm" : "h:mm AP")
        font.pixelSize: Theme.fontSize.large
        font.weight: Font.Bold
        font.features: ({ "tnum": 1 })
        color: root.active ? Theme.fgPrimary : Theme.fg
    }

    StyledText {
        anchors.verticalCenter: parent.verticalCenter
        text: Qt.locale("zh_CN").toString(clock.date, "M月d日 ddd")
        color: root.active ? Theme.fgPrimary : Theme.fgVariant
    }
}
