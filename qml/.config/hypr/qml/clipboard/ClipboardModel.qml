import QtQuick

Item {
    id: root

    property string searchText: ""
    property string filterType: "all" // "all", "text", "image"
    readonly property alias model: itemsModel
    readonly property alias count: itemsModel.count

    ListModel {
        id: itemsModel
    }

    Connections {
        target: ClipboardService

        function onItemsLoaded() {
            root.applyFilter();
        }

        function onThumbnailUpdated(id, thumbPath) {
            // Update in model if present
            for (var i = 0; i < itemsModel.count; i++) {
                if (itemsModel.get(i).itemId === id) {
                    itemsModel.setProperty(i, "thumb", thumbPath);
                    break;
                }
            }
            // Also update in raw items cache
            for (var j = 0; j < ClipboardService.rawItems.length; j++) {
                if (ClipboardService.rawItems[j].id === id) {
                    ClipboardService.rawItems[j].thumb = thumbPath;
                    break;
                }
            }
        }
    }

    onSearchTextChanged: {
        applyFilter();
    }

    onFilterTypeChanged: {
        applyFilter();
    }

    Component.onCompleted: {
        applyFilter();
    }

    function applyFilter() {
        itemsModel.clear();
        var raw = ClipboardService.rawItems;
        if (!raw || raw.length === 0) return;

        var query = root.searchText.trim().toLowerCase();
        var typeFilter = root.filterType;

        for (var i = 0; i < raw.length; i++) {
            var item = raw[i];

            // Type filter
            if (typeFilter !== "all" && item.type !== typeFilter) {
                continue;
            }

            // Search filter
            if (query.length > 0) {
                var match = false;
                if (item.preview && item.preview.toLowerCase().indexOf(query) !== -1) {
                    match = true;
                } else if (item.meta && item.meta.toLowerCase().indexOf(query) !== -1) {
                    match = true;
                } else if (item.format && item.format.toLowerCase().indexOf(query) !== -1) {
                    match = true;
                }
                if (!match) continue;
            }

            itemsModel.append({
                itemId: item.id || "",
                itemType: item.type || "text",
                format: item.format || "",
                dimensions: item.dimensions || "",
                size: item.size || "",
                meta: item.meta || "",
                preview: item.preview || "",
                rawLine: item.raw || "",
                thumb: item.thumb || ""
            });
        }
    }

    function getItem(index) {
        if (index >= 0 && index < itemsModel.count) {
            return itemsModel.get(index);
        }
        return null;
    }

    function removeAt(index) {
        if (index >= 0 && index < itemsModel.count) {
            var item = itemsModel.get(index);
            var rawLine = item.rawLine;
            itemsModel.remove(index);
            ClipboardService.deleteItem(rawLine, function(success) {
                // Done
            });
        }
    }
}
