# QML Clipboard

A fast, lightweight, Wayland-native graphical clipboard picker with **actual visual image thumbnails** built using **Quickshell + QML** and styled in **Catppuccin Mocha**.

---

## Why It Exists

Standard clipboard pickers like `wofi + cliphist` work well for text, but render images as opaque metadata strings:
```text
PNG image, 1024x1024
PNG image, 1920x1080
```
When multiple screenshots or copied pictures share similar dimensions, it becomes nearly impossible to tell them apart without guessing.

**QML Clipboard** solves this by providing:
* **True visual image previews** (PNG, JPEG, WebP, GIF, SVG, etc.) with aspect-ratio preservation and transparency support.
* **Readable multi-line text previews** with character count metadata.
* **Mixed text/image history browsing**.
* **Instant keyboard navigation and live search filtering**.
* **Zero persistent secondary databases** — integrates directly with your existing `cliphist` and `wl-clipboard` infrastructure.

---

## Features

* 🎨 **Catppuccin Mocha Theme**: Cohesive dark palette matching modern Hyprland / Wayland desktops.
* 🖼 **Instant Image Previews**: Decodes image bytes directly from `cliphist` on the fly into high-performance thumbnails without saving permanent files to disk.
* ⌨ **Full Keyboard Driving**: Complete navigation via Arrow Keys, Enter, Tab, PageUp/PageDown, Home/End, Backspace, Delete, and Escape.
* 🔍 **Instant Search & Filter**: Filter history in real-time or switch between *All*, *Images*, and *Text*.
* 🗑 **Item Management**: Delete unwanted or sensitive entries on the fly (`Del` key) directly removing them from cliphist.
* 🚀 **Instant Launch**: Loads in milliseconds with asynchronous background thumbnail caching.

---

## Dependencies

* **Quickshell** (0.3.1+)
* **cliphist**
* **wl-clipboard** (`wl-copy`, `wl-paste`)
* **Python 3** with `Pillow` (PIL) for image thumbnailing

On Arch Linux / CachyOS:
```bash
sudo pacman -S quickshell cliphist wl-clipboard python-pillow
```

---

## How to Launch

Run the picker directly via Quickshell:

```bash
quickshell --path /home/gbesh/coding/qml_clipboard/shell.qml
```

Or symlink into your Quickshell config directory:
```bash
mkdir -p ~/.config/quickshell
ln -s /home/gbesh/coding/qml_clipboard ~/.config/quickshell/qml_clipboard
quickshell -c qml_clipboard
```

---

## Hyprland Keybinding

Add the following binding to your `hyprland.conf`:

```conf
# Open QML Clipboard Picker
bind = SUPER, V, exec, quickshell --path /home/gbesh/coding/qml_clipboard/shell.qml
```

---

## Keyboard & Mouse Controls

| Action | Control |
|---|---|
| **Navigate items** | `↑` `↓` `←` `→` |
| **Switch category (All / Images / Text)** | `Tab` / `Shift+Tab` |
| **Page Up / Down** | `PageUp` / `PageDown` |
| **First / Last item** | `Home` / `End` |
| **Search query** | Start typing in the search box |
| **Copy & Close** | `Enter` or Double-Click item |
| **Select item** | Single-Click item |
| **Delete entry** | `Del` key |
| **Close picker** | `Escape` or Click outside modal |

---

## Architecture & How It Integrates with cliphist

```text
┌────────────────────────────────────────────────────────┐
│                        Hyprland                        │
│                           │ (SUPER + V)                │
│                           ▼                            │
│                 Quickshell (shell.qml)                 │
│               [LayerShell Overlay Modal]               │
├───────────────────────────┬────────────────────────────┤
│                           │                            │
│  UI Layer:                │  Backend Helper:           │
│  - SearchBar.qml          │  - cliphist_helper.py      │
│  - ClipboardGrid.qml      │    - cliphist list         │
│  - ClipboardItem.qml      │    - decode & thumbnail    │
│  - ImagePreview.qml       │    - restore (wl-copy)     │
│  - TextPreview.qml        │    - delete (cliphist del) │
│  - Theme.qml (Mocha)      │                            │
└───────────────────────────┴────────────────────────────┘
```

1. **History Retrieval**: `cliphist_helper.py list` enumerates entries from `cliphist list` without blocking the UI thread.
2. **Thumbnail Generation**: Background worker generates downscaled thumbnails into `$XDG_RUNTIME_DIR/qml_clipboard/thumbnails/` (stored in RAM `tmpfs`).
3. **Selection Restoration**: When an entry is chosen, `cliphist_helper.py copy` decodes the binary/text stream and pipes it to `wl-copy` with the correct MIME type (`image/png`, `image/jpeg`, etc.).
4. **Clean Exit**: Quickshell exits cleanly (`Qt.quit()`), returning focus to the previously active application.

---

## Configuration

Default settings in `Theme.qml`:
* `windowWidth`: 920px
* `windowHeight`: 640px
* `cardWidth`: 204px
* `cardHeight`: 172px
* `gridColumns`: 4
* Colors: Full **Catppuccin Mocha** palette tokens

---

## License

MIT License.
