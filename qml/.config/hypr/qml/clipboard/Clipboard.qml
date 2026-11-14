import QtQuick
import QtQuick.Controls

Rectangle {
    id: root

    width: Theme.windowWidth
    height: Theme.windowHeight
    radius: Theme.windowRadius
    color: Theme.base
    border.width: Theme.borderWidth
    border.color: Theme.surface1

    signal closeRequested()

    ClipboardModel {
        id: clipModel
        searchText: searchBar.text
        filterType: searchBar.activeFilter
    }

    Column {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 14

        // 1. Search Bar Header
        SearchBar {
            id: searchBar
            anchors.left: parent.left
            anchors.right: parent.right
            totalCount: ClipboardService.rawItems.length
            filteredCount: clipModel.count

            onEnterPressed: {
                clipGrid.activateCurrent();
            }

            onArrowUpPressed: {
                clipGrid.moveUp();
            }

            onArrowDownPressed: {
                clipGrid.moveDown();
            }

            onArrowLeftPressed: {
                clipGrid.moveLeft();
            }

            onArrowRightPressed: {
                clipGrid.moveRight();
            }

            onPageUpPressed: {
                clipGrid.movePageUp();
            }

            onPageDownPressed: {
                clipGrid.movePageDown();
            }

            onHomePressed: {
                clipGrid.selectFirst();
            }

            onEndPressed: {
                clipGrid.selectLast();
            }

            onDeletePressed: {
                clipGrid.deleteCurrent();
            }

            onEscapePressed: {
                root.closeRequested();
            }

            onFilterChanged: filter => {
                clipGrid.selectFirst();
            }
        }

        // 2. Main Grid / Content View
        Item {
            anchors.left: parent.left
            anchors.right: parent.right
            height: parent.height - searchBar.height - footerBar.height - (parent.spacing * 2)

            ClipboardGrid {
                id: clipGrid
                anchors.fill: parent
                model: clipModel.model
                visible: clipModel.count > 0 && !ClipboardService.loading

                onItemActivated: item => {
                    if (item && item.rawLine) {
                        ClipboardService.copyItem(item.rawLine, function(success) {
                            root.closeRequested();
                        });
                    }
                }
            }

            EmptyView {
                anchors.fill: parent
                isLoading: ClipboardService.loading
                errorMessage: ClipboardService.errorMessage
                isSearchEmpty: !ClipboardService.loading && clipModel.count === 0 && ClipboardService.rawItems.length > 0
                searchQuery: searchBar.text
                visible: clipModel.count === 0 || ClipboardService.loading || ClipboardService.errorMessage.length > 0
            }
        }

        // 3. Footer / Status Bar
        Item {
            id: footerBar
            anchors.left: parent.left
            anchors.right: parent.right
            height: 28

            // Left: Counts
            Row {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                spacing: 8

                Rectangle {
                    height: 20
                    width: countText.implicitWidth + 12
                    radius: 10
                    color: Theme.surface0
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        id: countText
                        anchors.centerIn: parent
                        text: {
                            if (ClipboardService.loading) return "Loading...";
                            if (searchBar.text.length > 0 || searchBar.activeFilter !== "all") {
                                return clipModel.count + " of " + ClipboardService.rawItems.length + " items";
                            }
                            return clipModel.count + " items";
                        }
                        font.family: Theme.fontFamilyMono
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.textMuted
                    }
                }
            }

            // Right: Keyboard Hints
            Row {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: 12

                Row {
                    spacing: 4
                    anchors.verticalCenter: parent.verticalCenter

                    Rectangle {
                        height: 18
                        width: k1.implicitWidth + 8
                        radius: 4
                        color: Theme.surface0
                        border.width: 1
                        border.color: Theme.surface1

                        Text {
                            id: k1
                            anchors.centerIn: parent
                            text: "↑↓←→"
                            font.family: Theme.fontFamilyMono
                            font.pixelSize: 10
                            color: Theme.subtext0
                        }
                    }
                    Text {
                        text: "Navigate"
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.textDim
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                Row {
                    spacing: 4
                    anchors.verticalCenter: parent.verticalCenter

                    Rectangle {
                        height: 18
                        width: ktab.implicitWidth + 8
                        radius: 4
                        color: Theme.surface0
                        border.width: 1
                        border.color: Theme.surface1

                        Text {
                            id: ktab
                            anchors.centerIn: parent
                            text: "Tab"
                            font.family: Theme.fontFamilyMono
                            font.pixelSize: 10
                            color: Theme.sapphire
                        }
                    }
                    Text {
                        text: "Filter"
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.textDim
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                Row {
                    spacing: 4
                    anchors.verticalCenter: parent.verticalCenter

                    Rectangle {
                        height: 18
                        width: k2.implicitWidth + 8
                        radius: 4
                        color: Theme.surface0
                        border.width: 1
                        border.color: Theme.surface1

                        Text {
                            id: k2
                            anchors.centerIn: parent
                            text: "Enter"
                            font.family: Theme.fontFamilyMono
                            font.pixelSize: 10
                            color: Theme.mauve
                        }
                    }
                    Text {
                        text: "Copy & Close"
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.textDim
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                Row {
                    spacing: 4
                    anchors.verticalCenter: parent.verticalCenter

                    Rectangle {
                        height: 18
                        width: k3.implicitWidth + 8
                        radius: 4
                        color: Theme.surface0
                        border.width: 1
                        border.color: Theme.surface1

                        Text {
                            id: k3
                            anchors.centerIn: parent
                            text: "Del"
                            font.family: Theme.fontFamilyMono
                            font.pixelSize: 10
                            color: Theme.peach
                        }
                    }
                    Text {
                        text: "Delete"
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.textDim
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                Row {
                    spacing: 4
                    anchors.verticalCenter: parent.verticalCenter

                    Rectangle {
                        height: 18
                        width: k4.implicitWidth + 8
                        radius: 4
                        color: Theme.surface0
                        border.width: 1
                        border.color: Theme.surface1

                        Text {
                            id: k4
                            anchors.centerIn: parent
                            text: "Esc"
                            font.family: Theme.fontFamilyMono
                            font.pixelSize: 10
                            color: Theme.subtext0
                        }
                    }
                    Text {
                        text: "Close"
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.textDim
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }
        }
    }

    Component.onCompleted: {
        searchBar.forceFocus();
    }
}
