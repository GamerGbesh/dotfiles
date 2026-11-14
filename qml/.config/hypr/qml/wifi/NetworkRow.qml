import QtQuick
import Quickshell.Networking

// One network in the list. Click to connect; saved networks get a gear
// button with Connect/Disconnect, Change password and Forget.
Rectangle {
    id: row

    required property string name
    required property int index
    property var panel

    readonly property var net: panel.networkByName(name)
    readonly property bool selected: ListView.view && ListView.view.currentIndex === index
    readonly property bool expanded: panel.expandedName === name
    readonly property bool secured: panel.isSecured(net)
    readonly property bool connected: net ? net.connected : false
    readonly property bool known: net ? net.known : false
    readonly property bool busy: net ? (net.stateChanging
        || net.state === ConnectionState.Connecting
        || net.state === ConnectionState.Disconnecting) : false
    readonly property real strength: net ? (net.signalStrength > 1 ? net.signalStrength / 100 : net.signalStrength) : 0
    readonly property string error: panel.errors[name] || ""

    width: ListView.view ? ListView.view.width : 0
    height: content.implicitHeight + 20
    radius: Theme.radius
    color: selected ? Theme.surface0 : hover.containsMouse ? Qt.lighter(Theme.mantle, 1.25) : Theme.mantle
    border.width: selected ? 2 : 1
    border.color: selected ? Theme.mauve : Theme.surface0
    Behavior on color { ColorAnimation { duration: Theme.animFast } }
    Behavior on height { NumberAnimation { duration: Theme.animFast } }

    MouseArea {
        id: hover
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            row.ListView.view.currentIndex = row.index;
            row.panel.activate(row.name);
        }
    }

    Connections {
        target: row.net
        function onConnectionFailed(reason) { row.panel.handleFailure(row.name, reason); }
    }

    Column {
        id: content
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 10
        anchors.leftMargin: 14
        anchors.rightMargin: 14
        spacing: 10

        // Main line: signal, name + status, lock, gear.
        Item {
            width: parent.width
            height: 36

            Text {
                id: signalIcon
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                width: 26
                text: row.strength > 0.8 ? "󰤨" : row.strength > 0.6 ? "󰤥" : row.strength > 0.4 ? "󰤢" : row.strength > 0.2 ? "󰤟" : "󰤯"
                font.family: Theme.font
                font.pixelSize: 20
                color: row.connected ? Theme.green : Theme.text
            }

            Column {
                anchors.left: signalIcon.right
                anchors.leftMargin: 10
                anchors.right: rightIcons.left
                anchors.rightMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                spacing: 1

                Text {
                    width: parent.width
                    text: row.name
                    elide: Text.ElideRight
                    font.family: Theme.font
                    font.pixelSize: Theme.fontMedium
                    font.bold: row.connected
                    color: Theme.text
                }
                Text {
                    width: parent.width
                    visible: text.length > 0
                    elide: Text.ElideRight
                    text: {
                        if (row.busy) return row.connected ? "Disconnecting…" : "Connecting…";
                        if (row.connected) return "󰄬 Connected";
                        if (row.known) return "Saved";
                        return row.secured ? "" : "Open network";
                    }
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSmall
                    color: row.busy ? Theme.yellow : row.connected ? Theme.green : Theme.subtext0
                }
            }

            Row {
                id: rightIcons
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: 12

                Text {
                    visible: row.secured
                    text: "󰌾"
                    font.family: Theme.font
                    font.pixelSize: 15
                    color: Theme.overlay1
                    anchors.verticalCenter: parent.verticalCenter
                }

                // Gear: actions for saved networks.
                Rectangle {
                    visible: row.known || row.connected
                    width: 30; height: 30; radius: 8
                    anchors.verticalCenter: parent.verticalCenter
                    color: gear.containsMouse || (row.expanded && row.panel.expandedMode === "actions") ? Theme.surface1 : "transparent"
                    Text {
                        anchors.centerIn: parent
                        text: "󰒓"
                        font.family: Theme.font
                        font.pixelSize: 16
                        color: gear.containsMouse ? Theme.text : Theme.overlay1
                    }
                    MouseArea {
                        id: gear
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            row.ListView.view.currentIndex = row.index;
                            if (row.expanded && row.panel.expandedMode === "actions") row.panel.collapse();
                            else row.panel.expand(row.name, "actions");
                        }
                    }
                }
            }
        }

        // Error message.
        Text {
            visible: row.error.length > 0
            width: parent.width
            wrapMode: Text.WordWrap
            text: row.error
            font.family: Theme.font
            font.pixelSize: Theme.fontSmall
            color: Theme.red
        }

        // Expanded: password entry.
        Row {
            visible: row.expanded && row.panel.expandedMode === "password"
            width: parent.width
            spacing: 8
            onVisibleChanged: if (visible) { psk.text = ""; psk.focusInput(); }

            Field {
                id: psk
                width: parent.width - connectBtn.width - parent.spacing
                password: true
                placeholder: row.known ? "New password" : "Password"
                onAccepted: row.panel.submitPassword(row.name, psk.text)
                onEscapePressed: row.panel.collapse()
            }
            ActionButton {
                id: connectBtn
                label: "Connect"
                accent: Theme.mauve
                onClicked: row.panel.submitPassword(row.name, psk.text)
            }
        }

        // Expanded: actions for saved networks.
        Row {
            visible: row.expanded && row.panel.expandedMode === "actions"
            spacing: 8

            ActionButton {
                icon: row.connected ? "󰖪" : "󰖩"
                label: row.connected ? "Disconnect" : "Connect"
                accent: row.connected ? Theme.peach : Theme.green
                onClicked: row.panel.toggleConnection(row.name)
            }
            ActionButton {
                visible: row.secured
                icon: "󰌆"
                label: "Change password"
                accent: Theme.blue
                onClicked: row.panel.expand(row.name, "password")
            }
            ActionButton {
                icon: "󰆴"
                label: "Forget"
                accent: Theme.red
                onClicked: row.panel.forget(row.name)
            }
        }
    }
}
