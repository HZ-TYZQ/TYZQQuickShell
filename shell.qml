//@ pragma UseQApplication
//@ pragma Env QS_NO_RELOAD_POPUP=1
//@ pragma IconTheme candy-icons

import QtQuick
import Quickshell
import Quickshell.Io
import qs.config
import qs.services
import qs.modules.bar
import qs.modules.calendar
import qs.modules.controlcenter
import qs.modules.launcher
import qs.modules.lock
import qs.modules.notifications
import qs.modules.osd
import qs.modules.polkit
import qs.modules.session
import qs.modules.wallpaper

ShellRoot {
    Variants {
        model: Quickshell.screens
        Wallpaper {}
    }

    Variants {
        model: Quickshell.screens
        Bar {}
    }

    ControlCenter {}
    CalendarPanel {}
    Launcher {}
    SessionMenu {}
    Popups {}
    Osd {}
    PolkitDialog {}
    Lock {}
    Idle {}

    // ── IPC: `qs ipc call <target> <function> [args]` ─────────
    IpcHandler {
        target: "panel"
        function toggle(name: string): void {
            Ui.toggle(name);
        }
        function close(): void {
            Ui.close();
        }
    }

    IpcHandler {
        target: "launcher"
        function toggle(): void {
            Ui.toggle("launcher");
        }
    }

    IpcHandler {
        target: "control"
        function toggle(): void {
            Ui.toggle("control");
        }
        function page(name: string): void {
            Ui.open("control");
            Ui.controlPage = name;
        }
    }

    IpcHandler {
        target: "session"
        function toggle(): void {
            Ui.toggle("session");
        }
    }

    IpcHandler {
        target: "lock"
        function lock(): void {
            Ui.lock();
        }
        function isLocked(): bool {
            return Ui.locked;
        }
    }

    IpcHandler {
        target: "volume"
        function up(): void {
            Audio.changeVolume(0.05);
        }
        function down(): void {
            Audio.changeVolume(-0.05);
        }
        function mute(): void {
            Audio.toggleMute();
        }
        function micMute(): void {
            Audio.toggleMicMute();
        }
        function set(percent: int): void {
            Audio.setVolume(percent / 100);
        }
    }

    IpcHandler {
        target: "brightness"
        function up(): void {
            Brightness.change(0.05);
        }
        function down(): void {
            Brightness.change(-0.05);
        }
        function set(percent: int): void {
            Brightness.set(percent / 100);
        }
    }

    IpcHandler {
        target: "notifications"
        function clear(): void {
            Notifs.clearAll();
        }
        function toggleDnd(): void {
            Notifs.toggleDnd();
        }
    }

    IpcHandler {
        target: "media"
        function toggle(): void {
            Media.toggle();
        }
        function next(): void {
            Media.next();
        }
        function previous(): void {
            Media.previous();
        }
    }

    IpcHandler {
        target: "wallpaper"
        function set(path: string): void {
            Config.options.wallpaper = path;
        }
        function get(): string {
            return Config.options.wallpaper;
        }
    }

    IpcHandler {
        target: "caffeine"
        function toggle(): void {
            Ui.caffeine = !Ui.caffeine;
        }
    }
}
