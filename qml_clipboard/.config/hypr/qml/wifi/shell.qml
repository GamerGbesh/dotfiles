import QtQuick
import Quickshell
import Quickshell.Wayland

// Live Wi-Fi picker. Launched from waybar via ~/.config/wofi/launch.sh,
// which keeps only one menu (wofi or this) open at a time.
ShellRoot {
    PanelWindow {
        visible: true
        color: "transparent"

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
        WlrLayershell.namespace: "qml-wifi"

        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }

        // Backdrop: click outside the panel to close.
        Rectangle {
            anchors.fill: parent
            color: Theme.backdrop

            MouseArea {
                anchors.fill: parent
                onClicked: Qt.quit()
            }
        }

        WifiPanel {
            anchors.centerIn: parent

            // Swallow clicks on the panel so they don't reach the backdrop.
            MouseArea {
                anchors.fill: parent
                z: -1
            }

            onCloseRequested: Qt.quit()
        }
    }
}
