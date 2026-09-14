#!/usr/bin/env python3
"""
cliphist_helper.py - High performance clipboard backend helper for QML Clipboard.
Handles cliphist listing, asynchronous thumbnail generation, decoding, and clipboard restoration.
"""

import sys
import os
import re
import json
import subprocess
import io
from pathlib import Path

# Runtime directories
RUNTIME_DIR = os.environ.get("XDG_RUNTIME_DIR", f"/run/user/{os.getuid()}")
CACHE_DIR = Path(RUNTIME_DIR) / "qml_clipboard"
THUMBS_DIR = CACHE_DIR / "thumbnails"

# Max thumbnail dimension (bounding box)
THUMB_MAX_SIZE = (384, 384)

# Regex to detect cliphist binary preview lines
# Examples:
# 11506	[[ binary data 78 KiB png 1920x1080 ]]
# 11504	[[ binary data 185 B png 64x64 ]]
# 11507	[[ binary data 825 B jpeg 100x100 ]]
BINARY_REGEX = re.compile(
    r"^\[\[\s*binary\s+data\s+([0-9.]+\s*[A-Za-z]+)\s+([a-zA-Z0-9_-]+)(?:\s+(\d+x\d+))?\s*\]\]$"
)

def init_dirs():
    THUMBS_DIR.mkdir(parents=True, exist_ok=True)

def cleanup_thumbs():
    """Clean up old thumbnails in runtime cache directory."""
    if THUMBS_DIR.exists():
        for f in THUMBS_DIR.glob("*.png"):
            try:
                f.unlink()
            except Exception:
                pass

def decode_image_thumbnail(item_id: str) -> str | None:
    """Decodes image data from cliphist and saves a resized thumbnail to runtime cache."""
    try:
        dest_path = THUMBS_DIR / f"{item_id}.png"
        if dest_path.exists() and dest_path.stat().st_size > 0:
            return str(dest_path)

        proc = subprocess.Popen(
            ["cliphist", "decode"],
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.DEVNULL,
        )
        raw_bytes, _ = proc.communicate(f"{item_id}\t".encode("utf-8"), timeout=2.0)
        if not raw_bytes or proc.returncode != 0:
            return None

        # Import Pillow here to keep start times negligible
        from PIL import Image

        img = Image.open(io.BytesIO(raw_bytes))

        # Convert CMYK or P palette with transparency if needed
        if img.mode in ("RGBA", "LA") or (img.mode == "P" and "transparency" in img.info):
            img = img.convert("RGBA")
        elif img.mode != "RGB":
            img = img.convert("RGB")

        # Resize keeping aspect ratio
        img.thumbnail(THUMB_MAX_SIZE, Image.Resampling.BILINEAR)
        img.save(dest_path, "PNG", optimize=False)
        return str(dest_path)
    except Exception:
        # Fallback or error
        return None

def parse_cliphist_line(line: str) -> dict | None:
    line = line.strip("\r\n")
    if not line:
        return None

    parts = line.split("\t", 1)
    item_id = parts[0].strip()
    preview_content = parts[1] if len(parts) > 1 else ""

    bin_match = BINARY_REGEX.match(preview_content)
    if bin_match:
        size_str = bin_match.group(1)
        fmt = bin_match.group(2).upper()
        dims = bin_match.group(3) or ""

        is_image = fmt.lower() in ("png", "jpeg", "jpg", "webp", "gif", "bmp", "ico", "svg", "tiff", "avif")

        meta_parts = [fmt]
        if dims:
            meta_parts.append(dims.replace("x", " × "))
        if size_str:
            meta_parts.append(size_str)
        meta_str = " · ".join(meta_parts)

        thumb_file = THUMBS_DIR / f"{item_id}.png"
        has_thumb = thumb_file.exists() and thumb_file.stat().st_size > 0

        return {
            "id": item_id,
            "type": "image" if is_image else "binary",
            "format": fmt,
            "dimensions": dims,
            "size": size_str,
            "meta": meta_str,
            "preview": f"{fmt} {dims}" if dims else f"{fmt} Image",
            "raw": line,
            "thumb": str(thumb_file) if has_thumb else "",
        }
    else:
        # Text entry
        # Clean up multi-line display if needed
        char_count = len(preview_content)
        meta_str = f"{char_count} chars" if char_count > 0 else "Text"
        return {
            "id": item_id,
            "type": "text",
            "format": "TEXT",
            "dimensions": "",
            "size": "",
            "meta": meta_str,
            "preview": preview_content,
            "raw": line,
            "thumb": "",
        }

def list_entries(max_items: int = 250):
    init_dirs()
    try:
        proc = subprocess.run(
            ["cliphist", "list"],
            capture_output=True,
            text=True,
            check=True,
            timeout=3.0,
        )
        lines = proc.stdout.splitlines()[:max_items]
    except Exception as e:
        print(json.dumps({"items": [], "error": str(e)}))
        return

    items = []
    for line in lines:
        parsed = parse_cliphist_line(line)
        if parsed:
            items.append(parsed)

    print(json.dumps({"items": items, "error": None}))

def generate_all_thumbs(max_items: int = 150):
    """Background worker that generates thumbnails for images in order and outputs progress."""
    init_dirs()
    try:
        proc = subprocess.run(
            ["cliphist", "list"],
            capture_output=True,
            text=True,
            check=True,
            timeout=3.0,
        )
        lines = proc.stdout.splitlines()[:max_items]
    except Exception:
        return

    for line in lines:
        parsed = parse_cliphist_line(line)
        if parsed and parsed["type"] == "image":
            item_id = parsed["id"]
            thumb_file = THUMBS_DIR / f"{item_id}.png"
            if thumb_file.exists() and thumb_file.stat().st_size > 0:
                try:
                    print(json.dumps({"id": item_id, "thumb": str(thumb_file)}), flush=True)
                except BrokenPipeError:
                    return
                continue

            thumb_path = decode_image_thumbnail(item_id)
            if thumb_path:
                try:
                    print(json.dumps({"id": item_id, "thumb": thumb_path}), flush=True)
                except BrokenPipeError:
                    return

def generate_single_thumb(item_id: str):
    init_dirs()
    thumb_path = decode_image_thumbnail(item_id)
    if thumb_path:
        print(json.dumps({"id": item_id, "thumb": thumb_path, "success": True}))
    else:
        print(json.dumps({"id": item_id, "thumb": "", "success": False}))

MIME_MAP = {
    "png": "image/png",
    "jpeg": "image/jpeg",
    "jpg": "image/jpeg",
    "webp": "image/webp",
    "gif": "image/gif",
    "bmp": "image/bmp",
    "svg": "image/svg+xml",
    "ico": "image/x-icon",
    "tiff": "image/tiff",
    "tif": "image/tiff",
    "avif": "image/avif",
}

def copy_entry(raw_line: str):
    """Restore entry to clipboard using cliphist decode | wl-copy"""
    try:
        norm = raw_line.replace("\\t", "\t")
        parts = norm.split("\t", 1)
        item_id = parts[0].strip()
        preview = parts[1] if len(parts) > 1 else ""

        # Determine MIME type
        mime_type = None
        bin_match = BINARY_REGEX.match(preview)
        if bin_match:
            fmt = bin_match.group(2).lower()
            mime_type = MIME_MAP.get(fmt, None)

        p_decode = subprocess.Popen(
            ["cliphist", "decode"],
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.DEVNULL,
        )
        raw_bytes, _ = p_decode.communicate(f"{item_id}\t".encode("utf-8"), timeout=2.0)
        if p_decode.returncode != 0 or not raw_bytes:
            print(json.dumps({"success": False, "error": "cliphist decode failed"}))
            return

        copy_cmd = ["wl-copy", "-t", mime_type] if mime_type else ["wl-copy"]
        p_copy = subprocess.Popen(
            copy_cmd,
            stdin=subprocess.PIPE,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )
        p_copy.communicate(raw_bytes, timeout=2.0)

        if p_copy.returncode == 0:
            print(json.dumps({"success": True}))
        else:
            print(json.dumps({"success": False, "error": f"wl-copy exited with {p_copy.returncode}"}))
    except Exception as e:
        print(json.dumps({"success": False, "error": str(e)}))

def delete_entry(raw_line: str):
    """Delete entry from cliphist"""
    try:
        norm = raw_line.replace("\\t", "\t")
        parts = norm.split("\t", 1)
        item_id = parts[0].strip()

        proc = subprocess.Popen(
            ["cliphist", "delete"],
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.DEVNULL,
        )
        proc.communicate(f"{item_id}\t".encode("utf-8"), timeout=2.0)

        # Also remove cached thumbnail if present
        thumb = THUMBS_DIR / f"{item_id}.png"
        if thumb.exists():
            try:
                thumb.unlink()
            except Exception:
                pass
        print(json.dumps({"success": True}))
    except Exception as e:
        print(json.dumps({"success": False, "error": str(e)}))

def wipe_all():
    """Wipe all entries from cliphist"""
    try:
        subprocess.run(["cliphist", "wipe"], check=True, timeout=2.0)
        cleanup_thumbs()
        print(json.dumps({"success": True}))
    except Exception as e:
        print(json.dumps({"success": False, "error": str(e)}))

if __name__ == "__main__":
    if len(sys.argv) < 2:
        list_entries()
        sys.exit(0)

    cmd = sys.argv[1]
    if cmd == "list":
        list_entries()
    elif cmd == "generate_all":
        generate_all_thumbs()
    elif cmd == "thumb" and len(sys.argv) > 2:
        generate_single_thumb(sys.argv[2])
    elif cmd == "copy" and len(sys.argv) > 2:
        copy_entry(sys.argv[2])
    elif cmd == "delete" and len(sys.argv) > 2:
        delete_entry(sys.argv[2])
    elif cmd == "wipe":
        wipe_all()
    elif cmd == "cleanup":
        cleanup_thumbs()
    else:
        print(json.dumps({"error": f"Unknown command: {cmd}"}))
        sys.exit(1)
