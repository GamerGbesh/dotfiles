import QtQuick
import Quickshell
import Quickshell.Wayland

// Weekly timetable editor. Launch with `timetable edit` or
// `quickshell --path ~/.config/hypr/qml/timetable`.
// Data lives in ~/.local/share/timetable/timetable.json (shared with the CLI).
ShellRoot {
    Store { id: timetableStore }

    PanelWindow {
        visible: true
        color: "transparent"

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
        WlrLayershell.namespace: "qml-timetable"

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

        TimetablePanel {
            anchors.centerIn: parent
            store: timetableStore

            // Swallow clicks on the panel so they don't reach the backdrop.
            // Clicking empty panel space also ends title editing.
            MouseArea {
                anchors.fill: parent
                z: -1
                onPressed: parent.forceActiveFocus()
            }

            onCloseRequested: Qt.quit()
        }
    }
}
