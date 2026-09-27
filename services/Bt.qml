pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Bluetooth

Singleton {
    id: root

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property bool available: adapter !== null
    readonly property bool enabled: adapter?.enabled ?? false
    readonly property var devices: (adapter?.devices.values ?? []).slice().sort((a, b) => (b.connected - a.connected) || (b.paired - a.paired) || a.name.localeCompare(b.name))
    readonly property var connectedDevices: devices.filter(d => d.connected)

    readonly property string icon: !enabled ? "bluetooth_disabled" : connectedDevices.length > 0 ? "bluetooth_connected" : "bluetooth"
    readonly property string label: !available ? "不可用" : !enabled ? "已关闭" : connectedDevices.length === 1 ? connectedDevices[0].name : connectedDevices.length > 1 ? `${connectedDevices.length} 台设备` : "未连接"

    function toggle() {
        if (adapter)
            adapter.enabled = !adapter.enabled;
    }

    function setDiscovering(on) {
        if (adapter && adapter.enabled)
            adapter.discovering = on;
    }

    function deviceIcon(d) {
        const i = d?.icon ?? "";
        if (i.includes("headset") || i.includes("headphone"))
            return "headphones";
        if (i.includes("audio"))
            return "speaker";
        if (i.includes("mouse"))
            return "mouse";
        if (i.includes("keyboard"))
            return "keyboard";
        if (i.includes("phone"))
            return "smartphone";
        if (i.includes("gaming") || i.includes("joystick"))
            return "stadia_controller";
        if (i.includes("computer"))
            return "computer";
        return "bluetooth";
    }

    function activate(d) {
        if (d.connected) {
            d.disconnect();
        } else if (d.paired) {
            d.connect();
        } else {
            d.trusted = true;
            d.pair();
        }
    }
}
