import QtQuick

// Single-line text field with placeholder and optional show/hide password.
Rectangle {
    id: field

    property alias text: input.text
    property string placeholder: ""
    property bool password: false
    property bool revealed: false

    signal accepted()
    signal escapePressed()

    function focusInput() { input.forceActiveFocus(); }

    height: 36
    radius: 10
    color: Theme.base
    border.width: input.activeFocus ? 2 : 1
    border.color: input.activeFocus ? Theme.mauve : Theme.surface1

    TextInput {
        activeFocusOnTab: true
        id: input
        anchors.left: parent.left
        anchors.leftMargin: 12
        anchors.right: eye.visible ? eye.left : parent.right
        anchors.rightMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        font.family: Theme.font
        font.pixelSize: Theme.fontNormal
        color: Theme.text
        selectionColor: Theme.surface2
        clip: true
        echoMode: field.password && !field.revealed ? TextInput.Password : TextInput.Normal

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: field.placeholder
            font: parent.font
            color: Theme.overlay0
            visible: parent.text.length === 0
        }

        Keys.onReturnPressed: field.accepted()
        Keys.onEnterPressed: field.accepted()
        Keys.onEscapePressed: field.escapePressed()
    }

    Text {
        id: eye
        visible: field.password
        anchors.right: parent.right
        anchors.rightMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        text: field.revealed ? "󰈉" : "󰈈"
        font.family: Theme.font
        font.pixelSize: 16
        color: eyeMouse.containsMouse ? Theme.text : Theme.overlay1
        MouseArea {
            id: eyeMouse
            anchors.fill: parent
            anchors.margins: -4
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: field.revealed = !field.revealed
        }
    }
}
