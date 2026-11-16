import QtQuick
import Quickshell
import Quickshell.Io

// Loads and saves the timetable JSON. Every mutation writes straight to disk,
// and the file is watched so edits made elsewhere show up live.
//
// Shape (shared with the `timetable` CLI):
//   { title, showWeekend, slots: [{start, end}], entries: [{day, start, span, title, location, note, color}] }
// day: 0 = Monday … 6 = Sunday. start/span are slot indices.
Scope {
    id: store

    readonly property string dir: (Quickshell.env("XDG_DATA_HOME") || (Quickshell.env("HOME") + "/.local/share")) + "/timetable"
    readonly property string path: dir + "/timetable.json"

    property var tt: defaults()

    // ---- Helpers -------------------------------------------------------

    function defaults() {
        const slots = [];
        for (let h = 7; h < 19; h++)
            slots.push({ start: fmt(h * 60 + 30), end: fmt(h * 60 + 85) });
        return { title: "Timetable", showWeekend: false, slots: slots, entries: [] };
    }

    function normalize(d) {
        const out = defaults();
        if (!d || typeof d !== "object") return out;
        if (typeof d.title === "string") out.title = d.title;
        out.showWeekend = !!d.showWeekend;
        if (Array.isArray(d.slots) && d.slots.length > 0)
            out.slots = d.slots.filter(s => s && toMin(s.start) >= 0 && toMin(s.end) >= 0)
                               .map(s => ({ start: s.start, end: s.end }));
        if (Array.isArray(d.entries))
            out.entries = d.entries.filter(e => e && e.day >= 0 && e.day <= 6 && e.start >= 0 && e.span >= 1)
                                   .map(e => ({
                day: e.day, start: e.start, span: e.span,
                title: e.title || "", location: e.location || "", note: e.note || "",
                color: e.color || "mauve"
            }));
        return out;
    }

    function clone() { return JSON.parse(JSON.stringify(tt)); }

    function commit(d) {
        tt = d;
        file.setText(JSON.stringify(d, null, 2) + "\n");
    }

    function toMin(s) {
        const m = /^(\d{1,2}):(\d{2})$/.exec(String(s || "").trim());
        if (!m) return -1;
        const h = +m[1], mi = +m[2];
        return h < 24 && mi < 60 ? h * 60 + mi : -1;
    }

    function fmt(min) {
        const h = Math.floor(min / 60), m = min % 60;
        return (h < 10 ? "0" : "") + h + ":" + (m < 10 ? "0" : "") + m;
    }

    // Entries for one day, each tagged with its index in tt.entries.
    function entriesFor(d, day) {
        const out = [];
        for (let i = 0; i < d.entries.length; i++)
            if (d.entries[i].day === day) out.push(Object.assign({ index: i }, d.entries[i]));
        return out;
    }

    // Index of the entry covering (day, slot), or -1.
    function occupant(day, slot, ignore) {
        const es = tt.entries;
        for (let i = 0; i < es.length; i++)
            if (i !== ignore && es[i].day === day && slot >= es[i].start && slot < es[i].start + es[i].span)
                return i;
        return -1;
    }

    function colorForTitle(title) {
        const t = title.trim().toLowerCase();
        if (!t) return "";
        const e = tt.entries.find(x => x.title.trim().toLowerCase() === t);
        return e ? e.color : "";
    }

    function nextColor() {
        const used = tt.entries.map(e => e.color);
        const free = Theme.palette.find(c => !used.includes(c));
        return free || Theme.palette[tt.entries.length % Theme.palette.length];
    }

    // ---- Mutations (return "" on success, an error message otherwise) ---

    function saveEntry(index, e) {
        if (!e.title) return "Give it a title.";
        if (e.start < 0 || e.span < 1 || e.start + e.span > tt.slots.length) return "That range is outside the timetable.";
        for (let s = e.start; s < e.start + e.span; s++) {
            const o = occupant(e.day, s, index);
            if (o >= 0) return "Overlaps with " + tt.entries[o].title + ".";
        }
        const d = clone();
        if (index >= 0) d.entries[index] = e; else d.entries.push(e);
        d.entries.sort((a, b) => a.day - b.day || a.start - b.start);
        commit(d);
        return "";
    }

    function deleteEntry(index) {
        const d = clone();
        d.entries.splice(index, 1);
        commit(d);
    }

    function setSlot(i, start, end) {
        const a = toMin(start), b = toMin(end);
        if (a < 0 || b < 0) return "Use HH:MM (24-hour).";
        if (b <= a) return "End must be after start.";
        if (i > 0 && a < toMin(tt.slots[i - 1].end)) return "Starts before the previous slot ends.";
        if (i < tt.slots.length - 1 && b > toMin(tt.slots[i + 1].start)) return "Ends after the next slot starts.";
        const d = clone();
        d.slots[i] = { start: fmt(a), end: fmt(b) };
        commit(d);
        return "";
    }

    function addSlot() {
        const s = tt.slots;
        const last = s[s.length - 1];
        const len = toMin(last.end) - toMin(last.start);
        const gap = s.length > 1 ? toMin(last.start) - toMin(s[s.length - 2].end) : 5;
        const a = toMin(last.end) + gap;
        if (a + len >= 24 * 60) return;
        const d = clone();
        d.slots.push({ start: fmt(a), end: fmt(a + len) });
        commit(d);
    }

    function removeSlot(i) {
        if (tt.slots.length <= 1) return "The timetable needs at least one slot.";
        for (let day = 0; day < 7; day++)
            if (occupant(day, i, -1) >= 0) return "A block uses this slot. Move or delete it first.";
        const d = clone();
        d.slots.splice(i, 1);
        d.entries.forEach(e => { if (e.start > i) e.start -= 1; });
        commit(d);
        return "";
    }

    function setTitle(t) {
        if (t === tt.title) return;
        const d = clone();
        d.title = t;
        commit(d);
    }

    function setShowWeekend(on) {
        const d = clone();
        d.showWeekend = on;
        commit(d);
    }

    // ---- File I/O ------------------------------------------------------

    Process {
        command: ["mkdir", "-p", store.dir]
        running: true
        onExited: file.path = store.path
    }

    FileView {
        id: file
        watchChanges: true
        printErrors: false
        onFileChanged: reload()
        onLoaded: {
            try {
                const d = store.normalize(JSON.parse(text()));
                if (JSON.stringify(d) !== JSON.stringify(store.tt)) store.tt = d;
            } catch (err) {
                console.warn("timetable: couldn't parse " + store.path + ": " + err);
            }
        }
        onLoadFailed: err => {
            if (err === FileViewError.FileNotFound) store.commit(store.defaults());
        }
    }
}
