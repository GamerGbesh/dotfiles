import QtQuick
import Quickshell
import Quickshell.Wayland

ShellRoot {
    id: root

    PanelWindow {
        id: window
        visible: true
        color: "transparent"

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
        WlrLayershell.namespace: "qml-clipboard"

        // Cover entire screen for backdrop and click-outside-to-dismiss
        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }

        // 1. Semi-transparent backdrop overlay
        Rectangle {
            id: backdrop
            anchors.fill: parent
            color: Theme.bgBackdrop

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    Qt.quit();
                }
            }
        }

        // 2. Centered Clipboard Picker Modal
        Clipboard {
            id: clipboardPopup
            anchors.centerIn: parent

            // Prevent clicks on the card container from closing via backdrop
            MouseArea {
                anchors.fill: parent
                z: -1
                onClicked: {}
            }

            onCloseRequested: {
                Qt.quit();
            }
        }
    }
}
