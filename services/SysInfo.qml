pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property real cpu: 0
    property real memory: 0
    property real memUsedGb: 0
    property real memTotalGb: 0
    property int uptimeSec: 0
    property string user: Quickshell.env("USER")
    property string hostname: ""

    property var _lastCpu: null

    readonly property string uptime: {
        const d = Math.floor(uptimeSec / 86400), h = Math.floor(uptimeSec % 86400 / 3600), m = Math.floor(uptimeSec % 3600 / 60);
        return (d > 0 ? `${d} 天 ` : "") + (h > 0 ? `${h} 小时 ` : "") + `${m} 分钟`;
    }

    Timer {
        running: true
        repeat: true
        triggeredOnStart: true
        interval: 3000
        onTriggered: {
            stat.reload();
            meminfo.reload();
            uptimeFile.reload();
        }
    }

    FileView {
        id: stat
        path: "/proc/stat"
        onLoaded: {
            const f = text().split("\n")[0].trim().split(/\s+/).slice(1).map(Number);
            const idle = f[3] + f[4], total = f.reduce((a, b) => a + b, 0);
            if (root._lastCpu) {
                const dt = total - root._lastCpu.total, di = idle - root._lastCpu.idle;
                root.cpu = dt > 0 ? 1 - di / dt : 0;
            }
            root._lastCpu = { total, idle };
        }
    }

    FileView {
        id: meminfo
        path: "/proc/meminfo"
        onLoaded: {
            const t = text();
            const get = k => parseInt(t.match(new RegExp(k + ":\\s+(\\d+)"))?.[1] ?? "0");
            const total = get("MemTotal"), avail = get("MemAvailable");
            root.memTotalGb = total / 1048576;
            root.memUsedGb = (total - avail) / 1048576;
            root.memory = total > 0 ? (total - avail) / total : 0;
        }
    }

    FileView {
        id: uptimeFile
        path: "/proc/uptime"
        onLoaded: root.uptimeSec = Math.floor(parseFloat(text()))
    }

    FileView {
        path: "/etc/hostname"
        onLoaded: root.hostname = text().trim()
    }
}
