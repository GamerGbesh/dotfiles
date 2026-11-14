import QtQuick
import Quickshell.Io
import Quickshell.Networking

Rectangle {
    id: panel

    signal closeRequested()

    width: Theme.windowWidth
    height: Theme.windowHeight
    radius: Theme.windowRadius
    color: Theme.base
    border.width: 1
    border.color: Theme.surface1

    // ---- State ---------------------------------------------------------

    readonly property var wifiDevice: {
        const devs = Networking.devices.values;
        for (let i = 0; i < devs.length; i++)
            if (devs[i].type === DeviceType.Wifi) return devs[i];
        return null;
    }
    readonly property var connectedNetwork: {
        if (!wifiDevice) return null;
        const vs = wifiDevice.networks.values;
        for (let i = 0; i < vs.length; i++)
            if (vs[i].connected) return vs[i];
        return null;
    }

    // Which row is expanded, and how: "password" or "actions".
    property string expandedName: ""
    property string expandedMode: ""
    // Per-network error messages, keyed by SSID.
    property var errors: ({})
    property bool hiddenFormOpen: false

    // Keep scanning while the panel is open, so the list stays live.
    Binding {
        target: panel.wifiDevice
        property: "scannerEnabled"
        value: true
        when: panel.wifiDevice !== null && Networking.wifiEnabled
    }

    // ---- Helpers -------------------------------------------------------

    function networkByName(name) {
        if (!wifiDevice) return null;
        const vs = wifiDevice.networks.values;
        for (let i = 0; i < vs.length; i++)
            if (vs[i].name === name) return vs[i];
        return null;
    }

    function isSecured(net) {
        return net && net.security !== WifiSecurityType.Open && net.security !== WifiSecurityType.Owe;
    }

    function setError(name, msg) {
        const e = Object.assign({}, errors);
        if (msg) e[name] = msg; else delete e[name];
        errors = e;
    }

    function expand(name, mode) {
        expandedName = name;
        expandedMode = mode;
        const i = indexOfName(name);
        if (i >= 0) list.currentIndex = i;
    }

    function collapse() {
        expandedName = "";
        expandedMode = "";
        search.forceActiveFocus();
    }

    function indexOfName(name) {
        for (let i = 0; i < netModel.count; i++)
            if (netModel.get(i).name === name) return i;
        return -1;
    }

    // Row clicked / Enter pressed.
    function activate(name) {
        const net = networkByName(name);
        if (!net) return;
        if (expandedName === name) { collapse(); return; }
        if (net.connected) {
            expand(name, "actions");
        } else if (net.known || !isSecured(net)) {
            setError(name, "");
            net.connect();
            collapse();
        } else {
            expand(name, "password");
        }
    }

    // Saved networks get forgotten first so the new password replaces the old one.
    function submitPassword(name, psk) {
        const net = networkByName(name);
        if (!net || psk.length === 0) return;
        setError(name, "");
        if (net.known) {
            net.forget();
            pendingConnect.name = name;
            pendingConnect.psk = psk;
            pendingConnect.restart();
        } else {
            net.connectWithPsk(psk);
        }
        collapse();
    }

    function forget(name) {
        const net = networkByName(name);
        if (net) net.forget();
        setError(name, "");
        collapse();
    }

    function toggleConnection(name) {
        const net = networkByName(name);
        if (!net) return;
        if (net.connected) net.disconnect(); else net.connect();
        collapse();
    }

    function handleFailure(name, reason) {
        const net = networkByName(name);
        const authProblem = reason === ConnectionFailReason.NoSecrets
            || reason === ConnectionFailReason.WifiClientFailed
            || reason === ConnectionFailReason.WifiAuthTimeout;
        if (authProblem && isSecured(net)) {
            setError(name, "Couldn't connect. Wrong password?");
            expand(name, "password");
        } else {
            setError(name, "Couldn't connect (" + ConnectionFailReason.toString(reason) + ")");
        }
    }

    // Sync the list model in place (insert/move/remove) instead of replacing
    // it, so rows (and anything typed in them) survive live updates.
    function syncModel() {
        if (!wifiDevice) { netModel.clear(); return; }
        const q = search.text.trim().toLowerCase();
        const seen = {};
        let nets = wifiDevice.networks.values.filter(n => {
            if (!n || !n.name || seen[n.name]) return false;
            seen[n.name] = true;
            return n.name.toLowerCase().includes(q);
        });
        nets.sort((a, b) => (b.connected - a.connected)
            || (b.known - a.known)
            || (b.signalStrength - a.signalStrength)
            || a.name.localeCompare(b.name));
        let names = nets.map(n => n.name);

        // While a row is open, freeze the order so it doesn't jump around.
        if (expandedName !== "") {
            const cur = [];
            for (let i = 0; i < netModel.count; i++) cur.push(netModel.get(i).name);
            const keep = cur.filter(n => n === expandedName || names.includes(n));
            names = keep.concat(names.filter(n => !keep.includes(n)));
        }

        for (let i = 0; i < names.length; i++) {
            let j = -1;
            for (let k = i; k < netModel.count; k++)
                if (netModel.get(k).name === names[i]) { j = k; break; }
            if (j === -1) netModel.insert(i, { name: names[i] });
            else if (j !== i) netModel.move(j, i, 1);
        }
        if (netModel.count > names.length)
            netModel.remove(names.length, netModel.count - names.length);

        if (list.currentIndex >= netModel.count) list.currentIndex = netModel.count - 1;
        if (list.currentIndex < 0 && netModel.count > 0) list.currentIndex = 0;
    }

    ListModel { id: netModel }

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: panel.syncModel()
    }

    Timer {
        id: pendingConnect
        property string name
        property string psk
        interval: 700
        onTriggered: {
            const net = panel.networkByName(name);
            if (net) net.connectWithPsk(psk);
            psk = "";
        }
    }

    Process {
        id: hiddenProc
        property string ssid
        stderr: StdioCollector { id: hiddenErr }
        onExited: code => {
            hiddenStatus.text = code === 0 ? "Connected to " + ssid
                : "Failed: " + hiddenErr.text.trim().replace(/^Error: /, "");
            hiddenStatus.color = code === 0 ? Theme.green : Theme.red;
        }
    }

    // ---- Layout --------------------------------------------------------

    Column {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

        // Header: title, status, scan indicator, Wi-Fi toggle.
        Item {
            width: parent.width
            height: 44

            Text {
                id: wifiIcon
                anchors.verticalCenter: parent.verticalCenter
                text: Networking.wifiEnabled ? "󰤨" : "󰤭"
                font.family: Theme.font
                font.pixelSize: 26
                color: Networking.wifiEnabled ? Theme.mauve : Theme.overlay0
            }

            Column {
                anchors.left: wifiIcon.right
                anchors.leftMargin: 12
                anchors.verticalCenter: parent.verticalCenter
                spacing: 2

                Text {
                    text: "Wi-Fi"
                    font.family: Theme.font
                    font.pixelSize: Theme.fontLarge
                    font.bold: true
                    color: Theme.text
                }
                Text {
                    text: {
                        if (!Networking.wifiHardwareEnabled) return "Turned off by hardware switch";
                        if (!Networking.wifiEnabled) return "Off";
                        if (!panel.wifiDevice) return "No Wi-Fi adapter found";
                        if (!panel.connectedNetwork) return "Not connected";
                        let s = "Connected to " + panel.connectedNetwork.name;
                        if (Networking.connectivity === NetworkConnectivity.Portal) s += " · sign-in required";
                        else if (Networking.connectivity === NetworkConnectivity.Limited) s += " · no internet";
                        return s;
                    }
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSmall
                    color: panel.connectedNetwork ? Theme.green : Theme.subtext0
                }
            }

            // Spinning scan indicator.
            Text {
                anchors.right: toggle.left
                anchors.rightMargin: 14
                anchors.verticalCenter: parent.verticalCenter
                visible: Networking.wifiEnabled && panel.wifiDevice !== null
                text: "󰑐"
                font.family: Theme.font
                font.pixelSize: 16
                color: Theme.overlay1
                RotationAnimation on rotation {
                    from: 0; to: 360; duration: 1600
                    loops: Animation.Infinite
                    running: parent.visible
                }
            }

            // Wi-Fi on/off switch.
            Rectangle {
                id: toggle
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                width: 46; height: 26; radius: 13
                opacity: Networking.wifiHardwareEnabled ? 1 : 0.4
                color: Networking.wifiEnabled ? Theme.mauve : Theme.surface1
                Behavior on color { ColorAnimation { duration: Theme.animFast } }

                Rectangle {
                    width: 20; height: 20; radius: 10
                    anchors.verticalCenter: parent.verticalCenter
                    x: Networking.wifiEnabled ? parent.width - width - 3 : 3
                    color: Networking.wifiEnabled ? Theme.base : Theme.overlay1
                    Behavior on x { NumberAnimation { duration: Theme.animFast } }
                }
                MouseArea {
                    anchors.fill: parent
                    enabled: Networking.wifiHardwareEnabled
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Networking.wifiEnabled = !Networking.wifiEnabled
                }
            }
        }

        // Search box (also owns keyboard navigation).
        Rectangle {
            width: parent.width
            height: 42
            radius: Theme.radius
            color: Theme.mantle
            border.width: search.activeFocus ? 2 : 1
            border.color: search.activeFocus ? Theme.mauve : Theme.surface1

            Text {
                id: searchIcon
                anchors.left: parent.left
                anchors.leftMargin: 14
                anchors.verticalCenter: parent.verticalCenter
                text: "󰍉"
                font.family: Theme.font
                font.pixelSize: 16
                color: Theme.overlay1
            }

            TextInput {
                id: search
                anchors.left: searchIcon.right
                anchors.leftMargin: 10
                anchors.right: parent.right
                anchors.rightMargin: 14
                anchors.verticalCenter: parent.verticalCenter
                focus: true
                font.family: Theme.font
                font.pixelSize: Theme.fontMedium
                color: Theme.text
                selectionColor: Theme.surface2
                clip: true
                onTextChanged: { list.currentIndex = 0; panel.syncModel(); }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Search networks..."
                    font: parent.font
                    color: Theme.overlay0
                    visible: parent.text.length === 0
                }

                Keys.onPressed: event => {
                    if (event.key === Qt.Key_Down) { list.incrementCurrentIndex(); event.accepted = true; }
                    else if (event.key === Qt.Key_Up) { list.decrementCurrentIndex(); event.accepted = true; }
                    else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        if (list.currentIndex >= 0) panel.activate(netModel.get(list.currentIndex).name);
                        event.accepted = true;
                    } else if (event.key === Qt.Key_Escape) {
                        if (panel.expandedName !== "") panel.collapse(); else panel.closeRequested();
                        event.accepted = true;
                    }
                }
            }
        }

        // Network list.
        Item {
            width: parent.width
            height: parent.height - 44 - 42 - footer.height - hiddenForm.height - parent.spacing * (hiddenForm.visible ? 4 : 3)

            ListView {
                id: list
                anchors.fill: parent
                clip: true
                spacing: 8
                model: netModel
                boundsBehavior: Flickable.StopAtBounds
                highlightMoveDuration: 0

                move: Transition { NumberAnimation { properties: "y"; duration: 180; easing.type: Easing.OutQuad } }
                displaced: Transition { NumberAnimation { properties: "y"; duration: 180; easing.type: Easing.OutQuad } }

                readonly property var panelRef: panel
                delegate: NetworkRow { panel: list.panelRef }
            }

            Text {
                anchors.centerIn: parent
                visible: netModel.count === 0
                horizontalAlignment: Text.AlignHCenter
                text: {
                    if (!Networking.wifiEnabled) return "󰤭\nWi-Fi is off";
                    if (!panel.wifiDevice) return "No Wi-Fi adapter found";
                    if (search.text.length > 0) return "No networks match \"" + search.text + "\"";
                    return "󰑐\nScanning for networks...";
                }
                font.family: Theme.font
                font.pixelSize: Theme.fontMedium
                lineHeight: 1.4
                color: Theme.overlay1
            }
        }

        // Hidden network form.
        Rectangle {
            id: hiddenForm
            visible: panel.hiddenFormOpen
            width: parent.width
            height: visible ? 96 : 0
            radius: Theme.radius
            color: Theme.mantle
            border.width: 1
            border.color: Theme.surface1

            Column {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 8

                Row {
                    width: parent.width
                    spacing: 8

                    Field { id: hiddenSsid; width: (parent.width - 100) / 2; placeholder: "Network name (SSID)" }
                    Field { id: hiddenPsk; width: (parent.width - 100) / 2; placeholder: "Password (blank if open)"; password: true
                        onAccepted: hiddenConnect.clicked() }
                    ActionButton {
                        id: hiddenConnect
                        width: 84
                        label: "Connect"
                        accent: Theme.mauve
                        onClicked: {
                            if (hiddenSsid.text.length === 0 || hiddenProc.running) return;
                            const cmd = ["nmcli", "dev", "wifi", "connect", hiddenSsid.text];
                            if (hiddenPsk.text.length > 0) cmd.push("password", hiddenPsk.text);
                            cmd.push("hidden", "yes");
                            hiddenProc.ssid = hiddenSsid.text;
                            hiddenProc.command = cmd;
                            hiddenStatus.text = "Connecting to " + hiddenSsid.text + "...";
                            hiddenStatus.color = Theme.subtext0;
                            hiddenProc.running = true;
                        }
                    }
                }
                Text {
                    id: hiddenStatus
                    text: "Connect to a network that doesn't broadcast its name."
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSmall
                    color: Theme.subtext0
                }
            }
        }

        // Footer: key hints + hidden network toggle.
        Item {
            id: footer
            width: parent.width
            height: 24

            Text {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                text: "↑↓ select   Enter connect   Esc close"
                font.family: Theme.font
                font.pixelSize: Theme.fontSmall
                color: Theme.overlay0
            }
            Text {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                text: panel.hiddenFormOpen ? "Hide" : "Hidden network…"
                font.family: Theme.font
                font.pixelSize: Theme.fontSmall
                color: hiddenMouse.containsMouse ? Theme.mauve : Theme.subtext0
                MouseArea {
                    id: hiddenMouse
                    anchors.fill: parent
                    anchors.margins: -4
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        panel.hiddenFormOpen = !panel.hiddenFormOpen;
                        if (panel.hiddenFormOpen) hiddenSsid.focusInput(); else search.forceActiveFocus();
                    }
                }
            }
        }
    }
}
