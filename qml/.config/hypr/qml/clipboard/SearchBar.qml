import QtQuick
import QtQuick.Controls

Item {
    id: root

    property alias text: searchInput.text
    property string activeFilter: "all" // "all", "text", "image"
    property int totalCount: 0
    property int filteredCount: 0

    readonly property var filterOptions: ["all", "image", "text"]

    signal filterChanged(string filter)
    signal enterPressed()
    signal arrowDownPressed()
    signal arrowUpPressed()
    signal arrowLeftPressed()
    signal arrowRightPressed()
    signal pageUpPressed()
    signal pageDownPressed()
    signal homePressed()
    signal endPressed()
    signal escapePressed()
    signal deletePressed()

    height: 52

    function nextFilter() {
        var idx = filterOptions.indexOf(root.activeFilter);
        if (idx === -1) idx = 0;
        var nextIdx = (idx + 1) % filterOptions.length;
        root.activeFilter = filterOptions[nextIdx];
        root.filterChanged(root.activeFilter);
    }

    function prevFilter() {
        var idx = filterOptions.indexOf(root.activeFilter);
        if (idx === -1) idx = 0;
        var prevIdx = (idx - 1 + filterOptions.length) % filterOptions.length;
        root.activeFilter = filterOptions[prevIdx];
        root.filterChanged(root.activeFilter);
    }

    Rectangle {
        id: searchContainer
        anchors.fill: parent
        radius: Theme.cardRadius
        color: Theme.mantle
        border.width: searchInput.activeFocus ? 2 : 1
        border.color: searchInput.activeFocus ? Theme.mauve : Theme.surface1

        Behavior on border.color {
            ColorAnimation { duration: Theme.animFast }
        }

        Row {
            anchors.fill: parent
            anchors.leftMargin: 14
            anchors.rightMargin: 14
            spacing: 10
            anchors.verticalCenter: parent.verticalCenter

            // Search Icon
            Text {
                text: "🔍"
                font.pixelSize: 14
                anchors.verticalCenter: parent.verticalCenter
                color: Theme.overlay1
            }

            // Text Input Field
            TextInput {
                id: searchInput
                width: parent.width - 240
                height: parent.height
                verticalAlignment: TextInput.AlignVCenter
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeMedium
                color: Theme.text
                selectionColor: Theme.surface2
                selectedTextColor: Theme.text
                selectByMouse: true
                clip: true

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Search clipboard history..."
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeMedium
                    color: Theme.overlay0
                    visible: !searchInput.text && !searchInput.inputMethodComposing
                }

                Keys.onPressed: event => {
                    if (event.key === Qt.Key_Down) {
                        root.arrowDownPressed();
                        event.accepted = true;
                    } else if (event.key === Qt.Key_Up) {
                        root.arrowUpPressed();
                        event.accepted = true;
                    } else if (event.key === Qt.Key_Left) {
                        if (searchInput.cursorPosition === 0) {
                            root.arrowLeftPressed();
                            event.accepted = true;
                        }
                    } else if (event.key === Qt.Key_Right) {
                        if (searchInput.cursorPosition === searchInput.text.length) {
                            root.arrowRightPressed();
                            event.accepted = true;
                        }
                    } else if (event.key === Qt.Key_Backtab || (event.key === Qt.Key_Tab && (event.modifiers & Qt.ShiftModifier))) {
                        root.prevFilter();
                        event.accepted = true;
                    } else if (event.key === Qt.Key_Tab) {
                        root.nextFilter();
                        event.accepted = true;
                    } else if (event.key === Qt.Key_PageDown) {
                        root.pageDownPressed();
                        event.accepted = true;
                    } else if (event.key === Qt.Key_PageUp) {
                        root.pageUpPressed();
                        event.accepted = true;
                    } else if (event.key === Qt.Key_Home && searchInput.cursorPosition === 0) {
                        root.homePressed();
                        event.accepted = true;
                    } else if (event.key === Qt.Key_End && searchInput.cursorPosition === searchInput.text.length) {
                        root.endPressed();
                        event.accepted = true;
                    } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        root.enterPressed();
                        event.accepted = true;
                    } else if (event.key === Qt.Key_Escape) {
                        if (searchInput.text.length > 0) {
                            searchInput.text = "";
                        } else {
                            root.escapePressed();
                        }
                        event.accepted = true;
                    } else if (event.key === Qt.Key_Delete) {
                        if (searchInput.text.length === 0) {
                            root.deletePressed();
                            event.accepted = true;
                        }
                    }
                }
            }

            // Clear Button
            Rectangle {
                width: 20
                height: 20
                radius: 10
                color: clearMouse.containsMouse ? Theme.surface1 : "transparent"
                anchors.verticalCenter: parent.verticalCenter
                visible: searchInput.text.length > 0

                Text {
                    anchors.centerIn: parent
                    text: "✕"
                    font.pixelSize: 11
                    color: Theme.overlay2
                }

                MouseArea {
                    id: clearMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        searchInput.text = "";
                        searchInput.forceActiveFocus();
                    }
                }
            }

            Item {
                width: 1
                height: 1
                // Spacer
            }

            // Filter Pills (All / Images / Text)
            Row {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 6

                Repeater {
                    model: [
                        { label: "All", value: "all" },
                        { label: "Images", value: "image" },
                        { label: "Text", value: "text" }
                    ]

                    Rectangle {
                        id: filterBtn
                        width: pillText.implicitWidth + 16
                        height: 28
                        radius: 14
                        color: root.activeFilter === modelData.value ? Theme.mauve : (pillMouse.containsMouse ? Theme.surface1 : Theme.surface0)

                        Text {
                            id: pillText
                            anchors.centerIn: parent
                            text: modelData.label
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeSmall
                            font.weight: root.activeFilter === modelData.value ? Font.Bold : Font.Normal
                            color: root.activeFilter === modelData.value ? Theme.crust : Theme.text
                        }

                        MouseArea {
                            id: pillMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                root.activeFilter = modelData.value;
                                root.filterChanged(modelData.value);
                            }
                        }
                    }
                }
            }
        }
    }

    function forceFocus() {
        searchInput.forceActiveFocus();
    }
}
