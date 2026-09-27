import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.UPower
import qs.config
import qs.services
import qs.widgets

ColumnLayout {
    id: root

    spacing: 14

    // ── Header ────────────────────────────────────────────
    RowLayout {
        Layout.fillWidth: true
        spacing: 12

        Rectangle {
            implicitWidth: 44
            implicitHeight: 44
            radius: 22
            color: Theme.primaryContainer

            StyledText {
                anchors.centerIn: parent
                text: SysInfo.user.charAt(0).toUpperCase()
                font.pixelSize: 20
                font.weight: Font.Bold
                color: Theme.fgPrimaryContainer
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0

            StyledText {
                Layout.fillWidth: true
                text: SysInfo.user + (SysInfo.hostname ? "@" + SysInfo.hostname : "")
                font.pixelSize: Theme.fontSize.large
                font.weight: Font.DemiBold
            }
            StyledText {
                Layout.fillWidth: true
                text: "已运行 " + SysInfo.uptime
                font.pixelSize: Theme.fontSize.small
                color: Theme.fgVariant
            }
        }

        IconButton {
            icon: "wallpaper"
            baseColor: Theme.layer1
            onClicked: Ui.controlPage = "wallpaper"
        }
        IconButton {
            icon: "lock"
            baseColor: Theme.layer1
            onClicked: Ui.lock()
        }
        IconButton {
            icon: "power_settings_new"
            baseColor: Theme.layer1
            iconColor: Theme.error
            onClicked: Ui.open("session")
        }
    }

    // ── System stats ──────────────────────────────────────
    RowLayout {
        Layout.fillWidth: true
        spacing: 8

        StatChip {
            icon: "memory"
            label: "CPU"
            value: SysInfo.cpu
            text: Math.round(SysInfo.cpu * 100) + "%"
        }
        StatChip {
            icon: "memory_alt"
            label: "内存"
            value: SysInfo.memory
            text: SysInfo.memUsedGb.toFixed(1) + " / " + SysInfo.memTotalGb.toFixed(0) + "G"
        }
        StatChip {
            visible: UPower.displayDevice?.isLaptopBattery ?? false
            icon: UPower.onBattery ? "battery_horiz_050" : "power"
            label: UPower.onBattery ? "剩余时间" : "充满还需"
            value: UPower.displayDevice?.percentage ?? 0
            text: {
                const d = UPower.displayDevice;
                if (!d)
                    return "";
                const t = UPower.onBattery ? d.timeToEmpty : d.timeToFull;
                if (t <= 0)
                    return Math.round(d.percentage * 100) + "%";
                return `${Math.floor(t / 3600)}:${String(Math.floor(t % 3600 / 60)).padStart(2, "0")}`;
            }
        }
    }

    // ── Quick toggles ─────────────────────────────────────
    GridLayout {
        Layout.fillWidth: true
        columns: 2
        rowSpacing: 8
        columnSpacing: 8

        QuickTile {
            icon: Net.icon
            title: "Wi-Fi"
            subtitle: Net.label
            active: Net.wifiEnabled
            hasMore: true
            onClicked: Net.toggleWifi()
            onMoreClicked: Ui.controlPage = "wifi"
        }
        QuickTile {
            icon: Bt.icon
            title: "蓝牙"
            subtitle: Bt.label
            active: Bt.enabled
            hasMore: Bt.available
            onClicked: Bt.toggle()
            onMoreClicked: Ui.controlPage = "bluetooth"
        }
        QuickTile {
            icon: Notifs.dnd ? "do_not_disturb_on" : "do_not_disturb_off"
            title: "勿扰模式"
            subtitle: Notifs.dnd ? "已开启" : "已关闭"
            active: Notifs.dnd
            onClicked: Notifs.toggleDnd()
        }
        QuickTile {
            icon: "coffee"
            title: "保持唤醒"
            subtitle: Ui.caffeine ? "不会自动锁屏" : "已关闭"
            active: Ui.caffeine
            onClicked: Ui.caffeine = !Ui.caffeine
        }
        QuickTile {
            readonly property var profile: PowerProfiles.profile
            icon: profile === PowerProfile.Performance ? "bolt" : profile === PowerProfile.PowerSaver ? "eco" : "balance"
            title: "电源模式"
            subtitle: profile === PowerProfile.Performance ? "性能" : profile === PowerProfile.PowerSaver ? "节能" : "平衡"
            active: profile !== PowerProfile.Balanced
            onClicked: {
                const order = PowerProfiles.hasPerformanceProfile ? [PowerProfile.PowerSaver, PowerProfile.Balanced, PowerProfile.Performance] : [PowerProfile.PowerSaver, PowerProfile.Balanced];
                PowerProfiles.profile = order[(order.indexOf(profile) + 1) % order.length];
            }
        }
        QuickTile {
            icon: Audio.micMuted ? "mic_off" : "mic"
            title: "麦克风"
            subtitle: Audio.micMuted ? "已静音" : Math.round(Audio.micVolume * 100) + "%"
            active: !Audio.micMuted
            hasMore: true
            onClicked: Audio.toggleMicMute()
            onMoreClicked: Ui.controlPage = "audio"
        }
    }

    // ── Sliders ───────────────────────────────────────────
    RowLayout {
        Layout.fillWidth: true
        spacing: 8

        StyledSlider {
            Layout.fillWidth: true
            icon: Audio.icon
            value: Audio.volume
            accent: Audio.muted ? Theme.outline : Theme.primary
            onMoved: Audio.setVolume(value)
            onIconClicked: Audio.toggleMute()
        }
        IconButton {
            icon: "tune"
            baseColor: Theme.layer1
            onClicked: Ui.controlPage = "audio"
        }
    }

    StyledSlider {
        Layout.fillWidth: true
        visible: Brightness.available
        icon: Brightness.value > 0.6 ? "brightness_high" : Brightness.value > 0.3 ? "brightness_medium" : "brightness_low"
        value: Brightness.value
        from: 0.01
        onMoved: Brightness.set(value)
    }

    // ── Media ─────────────────────────────────────────────
    MediaCard {
        Layout.fillWidth: true
        visible: Media.active
    }

    // ── Notifications ─────────────────────────────────────
    NotificationList {
        Layout.fillWidth: true
        Layout.fillHeight: true
    }
}
