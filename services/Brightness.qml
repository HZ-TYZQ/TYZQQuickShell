pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Backlight control through logind (no root / brightnessctl needed).
Singleton {
    id: root

    property string device: ""
    property int max: 1
    property int raw: 0
    readonly property bool available: device !== ""
    readonly property real value: max > 0 ? raw / max : 0

    property int _pending: -1

    function set(v) {
        if (!available)
            return;
        raw = Math.round(Math.max(0.01, Math.min(1, v)) * max);
        _pending = raw;
        if (!throttle.running)
            throttle.start();
    }

    function change(delta) {
        set(value + delta);
    }

    Process {
        running: true
        command: ["sh", "-c", "for d in /sys/class/backlight/*; do [ -e \"$d\" ] && echo \"$(basename $d) $(cat $d/max_brightness)\"; done | head -n1"]
        stdout: StdioCollector {
            onStreamFinished: {
                const parts = text.trim().split(" ");
                if (parts.length === 2) {
                    root.max = parseInt(parts[1]) || 1;
                    root.device = parts[0];
                }
            }
        }
    }

    FileView {
        id: current
        path: root.available ? `/sys/class/backlight/${root.device}/brightness` : ""
        onLoaded: {
            if (root._pending < 0 && !throttle.running)
                root.raw = parseInt(text()) || 0;
        }
    }

    // sysfs does not emit inotify events, so poll for external changes.
    Timer {
        running: root.available
        repeat: true
        interval: 2500
        onTriggered: current.reload()
    }

    Timer {
        id: throttle
        interval: 40
        onTriggered: {
            if (root._pending < 0)
                return;
            Quickshell.execDetached(["busctl", "call", "org.freedesktop.login1", "/org/freedesktop/login1/session/auto", "org.freedesktop.login1.Session", "SetBrightness", "ssu", "backlight", root.device, String(root._pending)]);
            root._pending = -1;
        }
    }
}
