pragma Singleton

import QtQuick
import Quickshell

// Global UI state: which panel is open, caffeine, session lock.
Singleton {
    id: root

    // "", "launcher", "control", "calendar", "session"
    property string panel: ""
    property string controlPage: "main"
    property bool caffeine: false
    property bool locked: false

    readonly property var activeScreen: Quickshell.screens.find(s => s.name === Niri.focusedOutput) ?? Quickshell.screens[0]

    function toggle(name) {
        if (panel === name) {
            panel = "";
        } else {
            if (name === "control")
                controlPage = "main";
            panel = name;
        }
    }

    function open(name) {
        panel = name;
    }

    function close() {
        panel = "";
    }

    function lock() {
        panel = "";
        locked = true;
    }
}
