import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.config
import qs.services

// Idle handling: lock, then power off monitors. Also locks before sleep
// and when `loginctl lock-session` is called.
Scope {
    IdleMonitor {
        enabled: Config.options.idleLockSeconds > 0
        timeout: Config.options.idleLockSeconds
        respectInhibitors: true
        onIsIdleChanged: if (isIdle) Ui.lock()
    }

    IdleMonitor {
        enabled: Config.options.idleDpmsSeconds > 0
        timeout: Config.options.idleDpmsSeconds
        respectInhibitors: true
        onIsIdleChanged: if (isIdle) Niri.action("power-off-monitors")
    }

    Process {
        id: logind

        // logind escapes each character of the session id as _XX (hex)
        readonly property string sessionPath: "/org/freedesktop/login1/session/" + String(Quickshell.env("XDG_SESSION_ID") ?? "").split("").map(c => "_" + c.charCodeAt(0).toString(16)).join("")

        running: true
        command: ["gdbus", "monitor", "--system", "--dest", "org.freedesktop.login1"]
        stdout: SplitParser {
            onRead: line => {
                if (line.includes("PrepareForSleep (true") && Config.options.lockBeforeSuspend)
                    Ui.lock();
                else if (line.includes("org.freedesktop.login1.Session.Lock") && line.startsWith(logind.sessionPath + ":"))
                    Ui.lock();
                else if (line.includes("org.freedesktop.login1.Session.Unlock") && line.startsWith(logind.sessionPath + ":"))
                    Ui.locked = false;
            }
        }
        onExited: restart.start()
    }

    Timer {
        id: restart
        interval: 2000
        onTriggered: logind.running = true
    }
}
