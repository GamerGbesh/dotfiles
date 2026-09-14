import QtQuick
import Quickshell
import Quickshell.Io

pragma Singleton

Singleton {
    id: root

    property var rawItems: []
    property bool loading: true
    property string errorMessage: ""
    property string helperScript: Quickshell.shellDir + "/cliphist_helper.py"

    signal itemsLoaded()
    signal thumbnailUpdated(string id, string thumbPath)
    signal itemCopied()

    // 1. Initial List Fetcher Process
    Process {
        id: listProcess
        command: ["python3", root.helperScript, "list"]
        running: false

        stdout: StdioCollector {
            waitForEnd: true
            onDataChanged: {
                if (text && text.trim().length > 0) {
                    try {
                        var parsed = JSON.parse(text);
                        if (parsed.error) {
                            root.errorMessage = parsed.error;
                        } else if (parsed.items) {
                            root.rawItems = parsed.items;
                            root.loading = false;
                            root.errorMessage = "";
                            root.itemsLoaded();
                            // Once list is loaded, start generating remaining thumbnails in background
                            thumbWorkerProcess.running = true;
                        }
                    } catch (err) {
                        root.errorMessage = "Failed to parse clipboard data: " + err;
                        root.loading = false;
                    }
                }
            }
        }

        onExited: (code, status) => {
            root.loading = false;
            if (code !== 0 && root.rawItems.length === 0) {
                root.errorMessage = "cliphist exited with code " + code;
            }
        }
    }

    // 2. Background Thumbnail Generator Process
    Process {
        id: thumbWorkerProcess
        command: ["python3", root.helperScript, "generate_all"]
        running: false

        stdout: SplitParser {
            splitMarker: "\n"
            onRead: data => {
                var line = data.trim();
                if (line.length === 0) return;
                try {
                    var obj = JSON.parse(line);
                    if (obj.id && obj.thumb) {
                        root.thumbnailUpdated(obj.id, obj.thumb);
                    }
                } catch (err) {
                    // Ignore malformed line
                }
            }
        }
    }

    // 3. Single Action Process (copy, delete, wipe)
    Process {
        id: actionProcess
        running: false
        property var onCompleteCallback: null

        onExited: (code, status) => {
            if (onCompleteCallback) {
                onCompleteCallback(code === 0);
                onCompleteCallback = null;
            }
        }
    }

    function refresh() {
        root.loading = true;
        root.errorMessage = "";
        thumbWorkerProcess.running = false;
        listProcess.running = false;
        listProcess.running = true;
    }

    function copyItem(rawLine, callback) {
        if (!rawLine) return;
        actionProcess.running = false;
        actionProcess.command = ["python3", root.helperScript, "copy", rawLine];
        actionProcess.onCompleteCallback = function(success) {
            root.itemCopied();
            if (callback) callback(success);
        };
        actionProcess.running = true;
    }

    function deleteItem(rawLine, callback) {
        if (!rawLine) return;
        actionProcess.running = false;
        actionProcess.command = ["python3", root.helperScript, "delete", rawLine];
        actionProcess.onCompleteCallback = function(success) {
            if (callback) callback(success);
        };
        actionProcess.running = true;
    }

    function wipeAll(callback) {
        actionProcess.running = false;
        actionProcess.command = ["python3", root.helperScript, "wipe"];
        actionProcess.onCompleteCallback = function(success) {
            root.rawItems = [];
            if (callback) callback(success);
        };
        actionProcess.running = true;
    }

    Component.onCompleted: {
        refresh();
    }
}
