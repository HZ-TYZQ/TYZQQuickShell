pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Tracks niri state through `niri msg --json event-stream`.
Singleton {
    id: root

    property var workspaces: []          // sorted by output, then idx
    property var windows: ({})           // id -> window object
    property var focusedWindowId: null
    property bool overviewOpen: false
    property var keyboardLayouts: []
    property int keyboardLayoutIdx: 0

    readonly property var focusedWindow: focusedWindowId !== null ? (windows[focusedWindowId] ?? null) : null
    readonly property var focusedWorkspace: workspaces.find(w => w.is_focused) ?? null
    readonly property string focusedOutput: focusedWorkspace?.output ?? ""
    readonly property string keyboardLayout: keyboardLayouts[keyboardLayoutIdx] ?? ""

    function workspacesFor(output) {
        return workspaces.filter(w => w.output === output);
    }

    function windowsOn(workspaceId) {
        return Object.values(windows).filter(w => w.workspace_id === workspaceId);
    }

    function action(...args) {
        Quickshell.execDetached(["niri", "msg", "action", ...args.map(String)]);
    }

    function focusWorkspace(ws) {
        if (ws.output !== focusedOutput)
            Quickshell.execDetached(["sh", "-c", `niri msg action focus-monitor '${ws.output}' && niri msg action focus-workspace ${ws.idx}`]);
        else
            action("focus-workspace", ws.idx);
    }

    function focusWindow(id) {
        action("focus-window", "--id", id);
    }

    function _setWorkspaces(list) {
        workspaces = list.slice().sort((a, b) => a.output === b.output ? a.idx - b.idx : a.output.localeCompare(b.output));
    }

    function _updateWorkspaces(fn) {
        _setWorkspaces(workspaces.map(w => fn(Object.assign({}, w))));
    }

    function _handle(ev) {
        const [type, d] = Object.entries(ev)[0];
        switch (type) {
        case "WorkspacesChanged":
            _setWorkspaces(d.workspaces);
            break;
        case "WorkspaceActivated":
        {
            const target = workspaces.find(w => w.id === d.id);
            if (!target)
                break;
            _updateWorkspaces(w => {
                if (w.output === target.output)
                    w.is_active = w.id === d.id;
                if (d.focused)
                    w.is_focused = w.id === d.id;
                return w;
            });
            break;
        }
        case "WorkspaceActiveWindowChanged":
            _updateWorkspaces(w => {
                if (w.id === d.workspace_id)
                    w.active_window_id = d.active_window_id;
                return w;
            });
            break;
        case "WorkspaceUrgencyChanged":
            _updateWorkspaces(w => {
                if (w.id === d.id)
                    w.is_urgent = d.urgent;
                return w;
            });
            break;
        case "WindowsChanged":
        {
            const map = {};
            for (const w of d.windows) {
                map[w.id] = w;
                if (w.is_focused)
                    focusedWindowId = w.id;
            }
            windows = map;
            break;
        }
        case "WindowOpenedOrChanged":
        {
            const map = Object.assign({}, windows);
            const win = d.window;
            if (win.is_focused) {
                for (const id in map)
                    if (map[id].is_focused)
                        map[id] = Object.assign({}, map[id], { is_focused: false });
                focusedWindowId = win.id;
            }
            map[win.id] = win;
            windows = map;
            break;
        }
        case "WindowClosed":
        {
            const map = Object.assign({}, windows);
            delete map[d.id];
            windows = map;
            if (focusedWindowId === d.id)
                focusedWindowId = null;
            break;
        }
        case "WindowFocusChanged":
        {
            const map = {};
            for (const id in windows)
                map[id] = Object.assign({}, windows[id], { is_focused: Number(id) === d.id });
            windows = map;
            focusedWindowId = d.id;
            break;
        }
        case "WindowUrgencyChanged":
            if (windows[d.id]) {
                const map = Object.assign({}, windows);
                map[d.id] = Object.assign({}, map[d.id], { is_urgent: d.urgent });
                windows = map;
            }
            break;
        case "KeyboardLayoutsChanged":
            keyboardLayouts = d.keyboard_layouts.names;
            keyboardLayoutIdx = d.keyboard_layouts.current_idx;
            break;
        case "KeyboardLayoutSwitched":
            keyboardLayoutIdx = d.idx;
            break;
        case "OverviewOpenedOrClosed":
            overviewOpen = d.is_open;
            break;
        }
    }

    Process {
        id: stream
        running: true
        command: ["niri", "msg", "--json", "event-stream"]
        stdout: SplitParser {
            onRead: line => {
                try {
                    root._handle(JSON.parse(line));
                } catch (e) {
                    console.warn("niri: bad event", e);
                }
            }
        }
        onExited: restart.start()
    }

    Timer {
        id: restart
        interval: 1000
        onTriggered: stream.running = true
    }
}
