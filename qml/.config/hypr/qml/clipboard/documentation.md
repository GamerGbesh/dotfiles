# QML Clipboard

## 1. Project Overview

Build a lightweight, Wayland-native graphical clipboard manager/picker using **QML + Quickshell**.

The application exists for one specific purpose:

> Provide a visually useful interface for browsing and selecting clipboard history, especially image clipboard entries that are difficult to distinguish when using `cliphist` + `wofi`.

The current workflow uses `cliphist` as the clipboard history backend and `wofi` as the picker. For text, this works reasonably well. For images, however, `cliphist`/`wofi` commonly displays metadata such as:

```text
PNG image, 1024x1024
PNG image, 1920x1080
```

When several images have similar metadata, it becomes difficult to identify the desired item.

The new application should therefore provide **actual visual previews for image clipboard entries** while retaining useful text previews for textual entries.

This project should remain intentionally small and focused.

---

# 2. Core Principle

The application is a **clipboard picker, and nothing else**.

Do NOT turn it into:

* an application launcher
* a file manager
* a notification center
* a system dashboard
* a calculator
* a general-purpose search interface
* a settings application
* a clipboard editor
* a clipboard synchronization service
* a screenshot manager
* a wallpaper manager

Every feature should be evaluated against one question:

> Does this directly improve browsing or selecting clipboard history?

If not, it does not belong in the application.

---

# 3. Target Environment

The initial target environment is:

* Linux
* Wayland
* Hyprland
* Quickshell
* QML
* `cliphist`
* `wl-clipboard`
* `cliphist` history database/backend

The application is expected to integrate with the user's existing clipboard infrastructure rather than replacing it.

The clipboard backend should remain responsible for:

* capturing clipboard history
* storing clipboard entries
* deduplicating/history management
* decoding clipboard data

The QML application should primarily be the **visual frontend/picker**.

---

# 4. Primary User Workflow

The intended workflow is:

```text
User copies something
        │
        ▼
Existing clipboard infrastructure
        │
        ▼
Clipboard history
        │
        ▼
QML Clipboard Picker
        │
        ├── Text entry → readable text preview
        │
        ├── Image entry → actual image thumbnail
        │
        └── Other entry → useful representation where possible
        │
        ▼
User selects an entry
        │
        ▼
Selected clipboard item becomes the current clipboard
        │
        ▼
Picker closes
```

The application should feel like a replacement for the current `wofi + cliphist` picker, not like a permanently running clipboard application.

---

# 5. Invocation Model

The application should be designed primarily as a **popup/picker**.

Typical invocation:

```bash
quickshell -c ~/.config/quickshell/qml_clipboard
```

or an equivalent configured Quickshell invocation.

It should support being launched from a Hyprland keybind.

Example conceptual workflow:

```text
SUPER + V
    ↓
Open clipboard picker
    ↓
Select item
    ↓
Copy selected item
    ↓
Close picker
```

The exact Hyprland binding is outside the core application.

---

# 6. UI Requirements

## 6.1 General Appearance

The UI should be compact and suitable for a desktop clipboard popup.

It should:

* appear centered or in another deliberate popup position
* have rounded corners
* use a dark theme
* visually fit a Catppuccin Mocha desktop
* use subtle borders
* use appropriate spacing
* have a clear selected/focused state
* avoid excessive decoration

The UI should prioritize **content visibility** over ornamentation.

---

# 7. Clipboard Entry Presentation

The most important part of the application is how clipboard entries are displayed.

## 7.1 Image Entries

Images MUST be displayed as actual thumbnails.

For example:

```text
┌──────────────────────────────────────────┐
│                                          │
│              IMAGE PREVIEW               │
│                                          │
│                                          │
└──────────────────────────────────────────┘
```

The user should not have to infer what an image is from:

```text
PNG 1024x1024
```

Instead, the image itself should be visible.

### Image requirements

* Render an actual image preview.
* Preserve aspect ratio.
* Use a reasonable maximum thumbnail size.
* Avoid stretching.
* Crop only if necessary for the visual grid.
* Prefer fitting the complete image inside its preview area.
* Clearly indicate which image is selected.
* Support common image formats exposed by the clipboard backend.
* Do not write permanent image files to disk merely to display thumbnails unless required by the backend architecture.

The UI should handle:

* screenshots
* photographs
* transparent PNGs
* large images
* small images
* square images
* portrait images
* landscape images

---

# 8. Text Entries

Text clipboard entries should display a useful preview.

For example:

```text
┌────────────────────────────────────┐
│ sudo pacman -Syu                   │
│                                    │
│ Update the system packages...      │
└────────────────────────────────────┘
```

Long clipboard contents should be truncated visually.

Do not allow a huge pasted document to make the picker enormous.

The UI should show enough content to distinguish entries.

For example, these should be distinguishable:

```text
git commit -m "Fix authentication..."
```

and

```text
git commit -m "Add websocket reconnect..."
```

---

# 9. Mixed Clipboard History

The picker should support a history containing both text and images.

For example:

```text
┌──────────────┬──────────────┬──────────────┐
│              │              │              │
│    IMAGE     │    IMAGE     │    IMAGE     │
│              │              │              │
├──────────────┼──────────────┼──────────────┤
│ sudo pacman  │ https://...  │ Python code  │
│ -Syu         │              │              │
├──────────────┼──────────────┼──────────────┤
│              │              │              │
│    IMAGE     │    IMAGE     │    IMAGE     │
│              │              │              │
└──────────────┴──────────────┴──────────────┘
```

The exact layout is an implementation decision, but the design must make image entries immediately recognizable.

---

# 10. Recommended Layout

A grid is preferred for image-heavy clipboard history.

Possible structure:

```text
┌─────────────────────────────────────────────┐
│ Search clipboard...                         │
├─────────────────────────────────────────────┤
│                                             │
│  ┌────────┐  ┌────────┐  ┌────────┐        │
│  │ IMAGE  │  │ IMAGE  │  │ IMAGE  │        │
│  └────────┘  └────────┘  └────────┘        │
│                                             │
│  ┌────────┐  ┌────────┐  ┌────────┐        │
│  │ TEXT   │  │ IMAGE  │  │ TEXT   │        │
│  └────────┘  └────────┘  └────────┘        │
│                                             │
└─────────────────────────────────────────────┘
```

However, the implementation should not rigidly assume that every entry is an image.

A mixed grid/list presentation is acceptable if it produces a better UX.

---

# 11. Search

A small search field may be included because it directly improves clipboard selection.

Search should operate on the clipboard entries already available.

For text:

```text
Search: docker
```

could produce:

```text
docker compose up -d
docker ps -a
docker exec -it container bash
```

For images, search may use whatever metadata is available, but **image visual recognition is the primary mechanism**.

Do not build an advanced fuzzy-search framework unless it is genuinely necessary.

---

# 12. Keyboard Navigation

The application must be keyboard-friendly.

Minimum requirements:

* `↑` / `↓`
* `←` / `→`
* `Tab` where appropriate
* `Enter` → select/copy item
* `Escape` → close picker
* typing → search
* `Backspace` → edit search

The user should be able to select clipboard entries without using the mouse.

---

# 13. Mouse Interaction

Mouse interaction should also work.

Minimum requirements:

* clicking an item selects it
* clicking an already-selected item may activate it
* hovering should provide a subtle visual indication
* scrolling should navigate the clipboard history

Do not add unnecessary mouse gestures.

---

# 14. Clipboard Selection Behaviour

When the user activates an entry:

1. The selected clipboard entry should become the current clipboard.
2. The picker should close.
3. The previously focused application should receive the clipboard contents normally.
4. The application should not leave unnecessary temporary files/processes behind.

The goal is to reproduce the useful behavior of:

```bash
cliphist decode | wl-copy
```

for the selected item, or the equivalent appropriate mechanism.

The exact implementation should follow the actual capabilities of `cliphist`.

---

# 15. Backend Integration

The application should reuse the existing `cliphist` history rather than implementing a second clipboard database.

Conceptually:

```text
               ┌─────────────────┐
               │ Clipboard       │
               │ history backend │
               └────────┬────────┘
                        │
                        ▼
               ┌─────────────────┐
               │ QML Clipboard   │
               │ frontend        │
               └────────┬────────┘
                        │
              ┌─────────┴─────────┐
              ▼                   ▼
           Text item           Image item
              │                   │
              ▼                   ▼
        Text preview        Image preview
```

The implementation should investigate how `cliphist` exposes image data and metadata.

Do not assume that the textual output of:

```bash
cliphist list
```

contains enough information to render images.

The implementation should determine the appropriate way to:

1. enumerate clipboard history
2. identify image entries
3. obtain/decode the actual image data
4. display it in QML
5. restore the selected entry to the clipboard

---

# 16. Image Handling

This is the most technically important requirement.

The implementation must distinguish between:

```text
clipboard metadata
```

and:

```text
actual clipboard content
```

For example:

```text
PNG image, 1024x1024
```

is metadata.

The UI needs access to the underlying image.

The agent should investigate the available `cliphist`/Wayland mechanisms and implement the cleanest approach.

Potential approaches may involve:

* `cliphist decode`
* temporary decoded data
* QML image loading
* `wl-copy`
* image MIME types
* pipes/processes
* Quickshell's process APIs
* temporary files when unavoidable

Do not commit to one approach before verifying it works with the installed versions.

---

# 17. Temporary Files

Avoid unnecessary permanent storage.

If QML cannot directly consume image data from the clipboard/history pipeline, temporary files are acceptable.

If temporary files are required:

* use an application-specific temporary directory
* use unique filenames
* clean them up
* do not pollute the user's home directory
* do not permanently duplicate the clipboard database

The clipboard history itself should remain managed by `cliphist`.

---

# 18. Performance Requirements

The picker should feel instantaneous.

Important considerations:

* Do not decode every historical image at full resolution simultaneously.
* Do not load hundreds of full-size images into memory.
* Use thumbnails where possible.
* Lazy-load images as they become visible.
* Avoid blocking the QML UI thread with expensive processes.
* Avoid spawning an excessive number of processes.
* Cache decoded thumbnails during the lifetime of the picker when useful.
* The application should remain responsive while images are being loaded.

The target is a smooth experience even with a reasonably large clipboard history.

---

# 19. History Size

The UI should not assume that only 5–10 clipboard entries exist.

It should work with larger histories.

However, virtualization/lazy rendering should be used so that a history containing hundreds of entries does not cause the entire UI to render simultaneously.

---

# 20. Selection Model

There should always be a clearly identifiable current selection.

Example:

```text
┌──────────┐
│          │
│  IMAGE   │  ← selected
│          │
└──────────┘
```

The selected item should have a visually obvious border/background.

The selected state should work consistently for:

* text
* images
* other clipboard formats

---

# 21. Empty State

If the clipboard history is empty:

```text
┌──────────────────────────────┐
│                              │
│      Clipboard is empty      │
│                              │
└──────────────────────────────┘
```

Do not turn this into a complicated onboarding screen.

---

# 22. Error Handling

The UI should gracefully handle:

* failed image decoding
* missing clipboard data
* malformed history entries
* history changing while the picker is open
* clipboard backend unavailable
* selected entry disappearing
* image loading failure

An image that cannot be loaded should display a simple fallback rather than breaking the entire picker.

For example:

```text
┌──────────────┐
│              │
│ Image        │
│ unavailable  │
│              │
└──────────────┘
```

---

# 23. Refresh Behaviour

The picker should retrieve the current clipboard history when opened.

If practical, it may refresh while open.

However, real-time clipboard monitoring is **not required** for the first version.

Do not build a persistent daemon unless it is necessary.

The preferred architecture is:

```text
Open picker
    ↓
Load current history
    ↓
Display
    ↓
Select
    ↓
Exit
```

This keeps the application simple.

---

# 24. Application Lifecycle

The application should behave like a popup utility.

When opened:

```text
create UI
load clipboard history
focus search/selection
```

When an item is selected:

```text
write item to clipboard
close
```

When Escape is pressed:

```text
close
```

It should not remain running unnecessarily after the picker closes.

---

# 25. Quickshell Architecture

Use Quickshell idiomatically.

Prefer a clean separation between:

```text
UI
│
├── Clipboard model
├── Clipboard/history service
├── Image decoding/loading
└── Selection/copy logic
```

Avoid putting shell commands throughout QML components.

For example, avoid scattering:

```qml
Process {
    command: ["bash", "-c", "..."]
}
```

across every delegate.

Centralize backend/process interaction.

---

# 26. Suggested Project Structure

The exact structure may change based on Quickshell best practices, but a reasonable starting point is:

```text
qml_clipboard/
├── shell.qml
├── Clipboard.qml
├── ClipboardModel.qml
├── ClipboardService.qml
├── ClipboardItem.qml
├── ImagePreview.qml
├── TextPreview.qml
├── ClipboardGrid.qml
├── SearchBar.qml
├── Theme.qml
├── utils/
│   └── ...
└── README.md
```

Do not create files simply to satisfy this structure.

Keep the project small where possible.

---

# 27. Configuration

The application should avoid requiring extensive configuration.

Reasonable configurable values include:

* maximum number of visible history entries
* thumbnail dimensions
* popup width/height
* number of grid columns
* keyboard shortcut behavior
* theme values

But these should have sensible defaults.

Do not build a settings UI.

Configuration should be code/config-file based.

---

# 28. Theme

The UI should be compatible with Catppuccin Mocha.

Use a restrained palette based around:

* base
* mantle
* crust
* surface0
* surface1
* text
* subtext
* blue
* lavender
* mauve

The design should be visually consistent with a Hyprland desktop using Catppuccin Mocha.

Do not hard-code excessive styling into individual components if a centralized theme object can handle it.

---

# 29. Accessibility / Usability

Even though this is a personal desktop utility, basic usability matters.

Requirements:

* selected item must be visually obvious
* text must remain readable
* image thumbnails must be large enough to distinguish
* keyboard navigation must be reliable
* focus must be obvious
* search field must be easy to identify
* UI must not depend exclusively on color

---

# 30. Security / Privacy

Clipboard contents can contain sensitive information.

The application must not:

* upload clipboard contents anywhere
* log clipboard contents
* send clipboard contents to external services
* persist additional clipboard data unnecessarily
* write clipboard contents into debug logs

Do not add telemetry.

Do not add networking.

The application is entirely local.

---

# 31. Logging

Debug logging should never print the actual clipboard contents.

Bad:

```text
Clipboard selected: my-secret-password
```

Good:

```text
Clipboard item selected: index=4 type=text
```

For images:

```text
Clipboard item loaded: index=2 type=image
```

---

# 32. Dependencies

Prefer using software already present in the user's environment.

Primary dependencies:

* Quickshell
* QML/Qt provided by Quickshell
* cliphist
* wl-copy / wl-paste

Do not introduce:

* Electron
* GTK
* Python services
* Node.js
* a database
* a web server
* a separate daemon

unless a concrete technical limitation makes one unavoidable.

---

# 33. Shell Commands

Where external commands are required, use direct process execution rather than unnecessary shell invocation.

Prefer:

```text
["cliphist", "list"]
```

over:

```text
["bash", "-c", "cliphist list | grep ..."]
```

Use shell pipelines only when genuinely required.

Avoid fragile parsing of human-oriented command output when a machine-readable mechanism exists.

---

# 34. Implementation Investigation

Before implementing the UI heavily, the agent should first verify the clipboard backend.

The agent should test:

### Text

```bash
echo "hello world" | wl-copy
cliphist list
```

### Image

Copy an actual image and inspect:

```bash
cliphist list
```

Then determine how to retrieve the underlying data.

Test:

```bash
cliphist decode
```

against image entries.

Verify:

```bash
cliphist decode <entry> | file -
```

or an equivalent mechanism.

Then verify that the resulting bytes can be consumed by QML.

This investigation should happen before committing to the image architecture.

---

# 35. Important Technical Constraint

The application must not solve the image-preview problem by merely displaying better metadata.

This is insufficient:

```text
PNG • 1024×1024 • 1.4 MB
```

The core requirement is:

```text
ACTUAL IMAGE PREVIEW
```

Metadata can be displayed as secondary information, but it is not a substitute for the image.

---

# 36. Optional Metadata

If useful, an item may display small secondary metadata such as:

```text
PNG · 1024×1024
```

or:

```text
Text · 128 chars
```

But metadata should never dominate the UI.

For images:

```text
┌────────────────────┐
│                    │
│                    │
│    ACTUAL IMAGE    │
│                    │
│                    │
├────────────────────┤
│ PNG · 1024×1024    │
└────────────────────┘
```

The image is the primary content.

---

# 37. What Is Out of Scope

The following should explicitly NOT be implemented:

### Clipboard editing

No:

* text editor
* image editor
* crop tool
* annotation tool
* formatting tool

### Clipboard synchronization

No:

* cloud sync
* phone sync
* LAN sync
* account system

### Clipboard persistence

Do not create a second persistent history database.

### Clipboard transformation

No:

* case conversion
* URL shortening
* Markdown conversion
* JSON formatting
* code formatting

### General utilities

No:

* calculator
* application launcher
* file search
* web search
* command runner
* emoji picker

### Notification functionality

No notification center.

### System controls

No:

* volume control
* brightness control
* network control
* Bluetooth controls
* power controls

These are unrelated to the project's purpose.

---

# 38. MVP

The first implementation is complete when the following works:

1. Launch the application.
2. Existing `cliphist` history appears.
3. Text entries are readable.
4. Image entries show actual image thumbnails.
5. User can navigate entries with the keyboard.
6. User can click entries.
7. Enter selects the current entry.
8. The selected entry becomes the Wayland clipboard.
9. The picker closes.
10. Escape closes without changing the clipboard.
11. Multiple images can be visually distinguished.
12. The application does not permanently store another copy of clipboard history.

Everything beyond this is secondary.

---

# 39. Acceptance Test

The most important test is:

### Scenario

1. Copy image A.
2. Copy image B.
3. Copy image C.
4. Open the QML clipboard picker.
5. Confirm all three images are visible as actual thumbnails.
6. Confirm the user can visually identify A/B/C without reading metadata.
7. Select image B.
8. Close the picker.
9. Paste somewhere.
10. Confirm image B was pasted.

Then test:

1. Copy text A.
2. Copy image B.
3. Copy text C.
4. Open picker.
5. Confirm mixed text/image history displays correctly.
6. Select image B.
7. Paste image B successfully.

Then test:

1. Open picker.
2. Press Escape.
3. Confirm clipboard remains unchanged.

---

# 40. Performance Acceptance Criteria

The picker should:

* open quickly
* not visibly freeze while loading history
* remain responsive while image thumbnails load
* avoid decoding every large image at full resolution
* avoid excessive process spawning
* handle a moderately large clipboard history

A clipboard containing many images should not cause the entire desktop to become sluggish.

---

# 41. Code Quality Requirements

Use idiomatic QML/Quickshell.

Prefer:

* small components
* clear responsibilities
* reactive QML state
* centralized backend interaction
* predictable process lifecycle
* minimal shell dependencies
* readable names
* no unnecessary abstractions

Avoid:

* giant `shell.qml`
* duplicated process logic
* arbitrary timers used to hide race conditions
* blocking shell commands
* global mutable state everywhere
* unnecessary frameworks

The implementation should be understandable by another developer without reverse-engineering it.

---

# 42. Documentation

The repository should contain a concise `README.md` covering:

* what the project is
* why it exists
* dependencies
* how to launch it
* how it integrates with `cliphist`
* how to configure it
* how to bind it to Hyprland
* known limitations

Do not write a massive tutorial.

---

# 43. Agent Working Rules

The implementation agent should follow this process:

### Phase 1 — Inspect

Inspect:

* current repository
* Quickshell version
* existing project structure
* installed `cliphist`
* installed `wl-clipboard`
* available Quickshell APIs

Do not overwrite existing project files blindly.

### Phase 2 — Verify backend

Before building the image UI, prove:

```text
cliphist history
       ↓
identify image
       ↓
retrieve image bytes
       ↓
display image bytes in QML
```

### Phase 3 — Build minimal UI

Implement:

* history model
* text delegate
* image delegate
* selection
* keyboard navigation
* activation

### Phase 4 — Integrate clipboard writing

Verify selected entries can be restored to the Wayland clipboard.

### Phase 5 — Performance

Test with:

* many text entries
* many images
* large images
* mixed history

### Phase 6 — Polish

Only after the functionality works:

* Catppuccin styling
* animations
* spacing
* thumbnail sizing
* search
* hover states

Do not spend significant time polishing a UI before proving image retrieval works.

---

# 44. Priority Order

Implementation priorities are:

```text
P0 — Clipboard functionality
P0 — Actual image previews
P0 — Selecting/restoring clipboard entries
P0 — Keyboard navigation

P1 — Mixed text/image UI
P1 — Performance/lazy loading
P1 — Search

P2 — Catppuccin visual polish
P2 — Animations
P2 — Metadata
P2 — Additional convenience features
```

If a lower-priority feature conflicts with the core clipboard functionality, remove the lower-priority feature.

---

# 45. Final Product Definition

The finished application should feel like:

> **A fast, keyboard-driven clipboard picker where images are actually visible.**

It should NOT feel like:

> A giant desktop shell that happens to contain a clipboard.

The ideal interaction is:

```text
SUPER + V
    ↓
┌─────────────────────────────────────────┐
│ Search clipboard...                     │
├─────────────────────────────────────────┤
│                                         │
│  ┌────────┐ ┌────────┐ ┌────────┐       │
│  │        │ │        │ │        │       │
│  │ IMAGE  │ │ IMAGE  │ │ IMAGE  │       │
│  │        │ │        │ │        │       │
│  └────────┘ └────────┘ └────────┘       │
│                                         │
│  ┌────────┐ ┌────────┐ ┌────────┐       │
│  │ text   │ │ IMAGE  │ │ text   │       │
│  │ preview│ │        │ │ preview│       │
│  └────────┘ └────────┘ └────────┘       │
│                                         │
└─────────────────────────────────────────┘
    ↓
Enter
    ↓
Clipboard restored
    ↓
Picker closes
```

**The single most important UX requirement is that when several images exist in clipboard history, the user can identify the desired image by looking at it rather than deciphering metadata.**
