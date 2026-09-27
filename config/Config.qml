pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Persistent user settings, stored in ~/.local/state/quickshell/.../settings.json
Singleton {
    id: root

    property alias options: adapter
    readonly property string wallpaperDir: Quickshell.env("HOME") + "/Pictures/Wallpaper"

    FileView {
        path: Quickshell.statePath("settings.json")
        watchChanges: true
        onFileChanged: reload()
        onAdapterUpdated: writeAdapter()
        onLoadFailed: error => {
            if (error === FileViewError.FileNotFound)
                writeAdapter();
        }

        JsonAdapter {
            id: adapter

            property string wallpaper: root.wallpaperDir + "/星辰|兜住星星的少女|2560x1600.png"
            property bool doNotDisturb: false
            property bool use24h: true
            // Idle: lock after N seconds, turn monitors off after M seconds (0 = disabled)
            property int idleLockSeconds: 600
            property int idleDpmsSeconds: 720
            property bool lockBeforeSuspend: true
            // Launch counts for launcher ranking: { desktopId: count }
            property var appUsage: ({})
        }
    }
}
