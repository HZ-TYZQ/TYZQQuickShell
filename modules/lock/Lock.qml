import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Pam
import qs.services

// Session lock (ext-session-lock) with password auth through PAM.
Scope {
    id: root

    property string buffer: ""
    property string status: ""
    property bool busy: false
    property int failures: 0

    signal failed

    function submit() {
        if (busy || buffer.length === 0)
            return;
        busy = true;
        status = "正在验证…";
        pam.active = true;
    }

    Connections {
        target: Ui
        function onLockedChanged() {
            if (Ui.locked) {
                root.buffer = "";
                root.status = "";
                root.failures = 0;
            }
        }
    }

    PamContext {
        id: pam

        configDirectory: Quickshell.shellDir + "/assets/pam"
        config: "password.conf"

        onResponseRequiredChanged: {
            if (responseRequired)
                respond(root.buffer);
        }

        onCompleted: result => {
            root.busy = false;
            if (result === PamResult.Success) {
                root.status = "";
                root.buffer = "";
                Ui.locked = false;
            } else {
                root.failures++;
                root.status = result === PamResult.MaxTries ? "尝试次数过多，请稍后再试" : "密码错误";
                root.buffer = "";
                root.failed();
            }
        }

        onError: err => {
            root.busy = false;
            root.status = "认证出错：" + PamError.toString(err);
            root.buffer = "";
            root.failed();
        }
    }

    WlSessionLock {
        locked: Ui.locked

        WlSessionLockSurface {
            color: "black"

            LockSurface {
                anchors.fill: parent
                lock: root
            }
        }
    }
}
