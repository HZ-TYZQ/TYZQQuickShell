import QtQuick
import Quickshell.Services.UPower
import qs.config
import qs.services
import qs.widgets

BarPill {
    id: root

    readonly property var battery: UPower.displayDevice
    readonly property bool hasBattery: battery?.isLaptopBattery ?? false
    readonly property real pct: battery?.percentage ?? 0
    readonly property bool charging: battery?.state === UPowerDeviceState.Charging || battery?.state === UPowerDeviceState.FullyCharged || battery?.state === UPowerDeviceState.PendingCharge
    readonly property color fg: active ? Theme.fgPrimary : Theme.fg

    active: Ui.panel === "control"
    spacing: 8
    hPadding: 12
    onClicked: Ui.toggle("control")
    onWheel: wheel => Audio.changeVolume(wheel.angleDelta.y > 0 ? 0.05 : -0.05)

    MaterialIcon {
        anchors.verticalCenter: parent.verticalCenter
        icon: Net.icon
        size: 17
        fill: 1
        color: root.fg
    }

    MaterialIcon {
        anchors.verticalCenter: parent.verticalCenter
        visible: Bt.enabled
        icon: Bt.icon
        size: 17
        color: root.fg
    }

    MaterialIcon {
        anchors.verticalCenter: parent.verticalCenter
        visible: Audio.micMuted
        icon: "mic_off"
        size: 17
        color: root.active ? root.fg : Theme.error
    }

    MaterialIcon {
        anchors.verticalCenter: parent.verticalCenter
        icon: Audio.icon
        size: 17
        fill: 1
        color: root.fg
    }

    MaterialIcon {
        anchors.verticalCenter: parent.verticalCenter
        visible: Ui.caffeine
        icon: "coffee"
        size: 17
        fill: 1
        color: root.active ? root.fg : Theme.tertiary
    }

    Row {
        visible: root.hasBattery
        spacing: 2
        anchors.verticalCenter: parent.verticalCenter

        MaterialIcon {
            anchors.verticalCenter: parent.verticalCenter
            rotation: 90
            icon: root.charging ? "battery_charging_full" : root.pct > 0.95 ? "battery_full" : `battery_${Math.floor(root.pct * 7)}_bar`
            size: 18
            fill: 1
            color: root.active ? root.fg : (!root.charging && root.pct < 0.15) ? Theme.error : root.charging ? Theme.success : root.fg
        }

        StyledText {
            anchors.verticalCenter: parent.verticalCenter
            text: Math.round(root.pct * 100) + "%"
            font.pixelSize: Theme.fontSize.small
            font.weight: Font.DemiBold
            color: root.fg
        }
    }
}
