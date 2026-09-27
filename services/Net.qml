pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Networking

Singleton {
    id: root

    readonly property var devices: Networking.devices.values
    readonly property var wifiDevice: devices.find(d => d.type === DeviceType.Wifi) ?? null
    readonly property var wiredDevice: devices.find(d => d.type === DeviceType.Wired) ?? null
    readonly property bool wifiEnabled: Networking.wifiEnabled
    readonly property bool wiredConnected: wiredDevice?.connected ?? false
    readonly property var networks: (wifiDevice?.networks.values ?? []).slice().sort((a, b) => (b.connected - a.connected) || (b.known - a.known) || (strength(b) - strength(a)))
    readonly property var activeWifi: networks.find(n => n.connected) ?? null
    readonly property bool connected: wiredConnected || activeWifi !== null

    readonly property string icon: wiredConnected ? "lan" : !wifiEnabled ? "wifi_off" : activeWifi ? wifiIcon(strength(activeWifi)) : "signal_wifi_bad"
    readonly property string label: wiredConnected ? "有线网络" : !wifiEnabled ? "已关闭" : activeWifi?.name ?? "未连接"

    function strength(n) {
        const s = n?.signalStrength ?? 0;
        return s > 1 ? s / 100 : s;
    }

    function wifiIcon(s) {
        return s > 0.75 ? "signal_wifi_4_bar" : s > 0.5 ? "network_wifi_3_bar" : s > 0.25 ? "network_wifi_2_bar" : "network_wifi_1_bar";
    }

    function isSecure(n) {
        return n?.security !== undefined && n.security !== WifiSecurityType.Open && n.security !== WifiSecurityType.Owe;
    }

    function toggleWifi() {
        Networking.wifiEnabled = !Networking.wifiEnabled;
    }

    function setScanning(on) {
        if (wifiDevice)
            wifiDevice.scannerEnabled = on;
    }
}
