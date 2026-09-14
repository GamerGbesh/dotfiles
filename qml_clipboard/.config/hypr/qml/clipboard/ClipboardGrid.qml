import QtQuick
import QtQuick.Controls

Item {
    id: root

    property alias model: gridView.model
    property alias count: gridView.count
    property int currentIndex: 0

    signal itemActivated(var item)
    signal itemSelected(int index)
    signal itemDeleted(int index)

    onCountChanged: {
        if (currentIndex >= count) {
            currentIndex = Math.max(0, count - 1);
        }
    }

    GridView {
        id: gridView
        anchors.fill: parent
        anchors.rightMargin: 8
        clip: true

        readonly property int columns: Math.max(1, Math.floor((width + Theme.cardSpacing) / (Theme.cardWidth + Theme.cardSpacing)))
        cellWidth: Math.floor(width / columns)
        cellHeight: Theme.cardHeight + Theme.cardSpacing

        currentIndex: root.currentIndex
        highlightFollowsCurrentItem: true
        highlightMoveDuration: Theme.animFast

        delegate: Item {
            width: gridView.cellWidth
            height: gridView.cellHeight

            ClipboardItem {
                anchors.centerIn: parent
                itemIndex: index
                itemId: model.itemId || ""
                itemType: model.itemType || "text"
                format: model.format || "TEXT"
                dimensions: model.dimensions || ""
                size: model.size || ""
                meta: model.meta || ""
                preview: model.preview || ""
                rawLine: model.rawLine || ""
                thumb: model.thumb || ""
                isSelected: (index === root.currentIndex)

                onClicked: {
                    root.currentIndex = index;
                    root.itemSelected(index);
                }

                onActivated: {
                    root.currentIndex = index;
                    var it = (root.model && typeof root.model.get === "function") ? root.model.get(index) : null;
                    if (it) {
                        root.itemActivated(it);
                    }
                }
            }
        }

        ScrollBar.vertical: ScrollBar {
            id: vbar
            active: true
            width: 6

            contentItem: Rectangle {
                implicitWidth: 6
                radius: 3
                color: vbar.pressed ? Theme.mauve : (vbar.hovered ? Theme.surface2 : Theme.surface1)
            }
            background: Rectangle {
                color: "transparent"
            }
        }
    }

    function moveUp() {
        if (count === 0) return;
        var cols = gridView.columns;
        if (root.currentIndex - cols >= 0) {
            root.currentIndex -= cols;
            gridView.positionViewAtIndex(root.currentIndex, GridView.Contain);
        }
    }

    function moveDown() {
        if (count === 0) return;
        var cols = gridView.columns;
        if (root.currentIndex + cols < count) {
            root.currentIndex += cols;
            gridView.positionViewAtIndex(root.currentIndex, GridView.Contain);
        }
    }

    function moveLeft() {
        if (count === 0) return;
        if (root.currentIndex > 0) {
            root.currentIndex -= 1;
            gridView.positionViewAtIndex(root.currentIndex, GridView.Contain);
        }
    }

    function moveRight() {
        if (count === 0) return;
        if (root.currentIndex < count - 1) {
            root.currentIndex += 1;
            gridView.positionViewAtIndex(root.currentIndex, GridView.Contain);
        }
    }

    function activateCurrent() {
        if (count === 0) return;
        var item = null;
        if (root.model && typeof root.model.getItem === "function") {
            item = root.model.getItem(root.currentIndex);
        } else if (root.model && typeof root.model.get === "function") {
            item = root.model.get(root.currentIndex);
        }
        if (item) {
            root.itemActivated(item);
        }
    }

    function deleteCurrent() {
        if (count === 0) return;
        var oldIdx = root.currentIndex;
        var it = (root.model && typeof root.model.get === "function") ? root.model.get(oldIdx) : null;
        if (it && it.rawLine) {
            ClipboardService.deleteItem(it.rawLine, function(success) {});
        }
        if (root.model && typeof root.model.remove === "function") {
            root.model.remove(oldIdx);
        }
        if (root.currentIndex >= count) {
            root.currentIndex = Math.max(0, count - 1);
        }
    }

    function movePageUp() {
        if (count === 0) return;
        var step = gridView.columns * 2;
        root.currentIndex = Math.max(0, root.currentIndex - step);
        gridView.positionViewAtIndex(root.currentIndex, GridView.Contain);
    }

    function movePageDown() {
        if (count === 0) return;
        var step = gridView.columns * 2;
        root.currentIndex = Math.min(count - 1, root.currentIndex + step);
        gridView.positionViewAtIndex(root.currentIndex, GridView.Contain);
    }

    function selectFirst() {
        if (count > 0) {
            root.currentIndex = 0;
            gridView.positionViewAtIndex(0, GridView.Beginning);
        }
    }

    function selectLast() {
        if (count > 0) {
            root.currentIndex = count - 1;
            gridView.positionViewAtIndex(count - 1, GridView.End);
        }
    }
}
