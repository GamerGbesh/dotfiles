#!/usr/bin/env python3
"""Hyprlock polling helper: label (1s) and art (2s). No background daemon.
Requires playerctl, curl, Python 3 and Pillow. Artwork is cached by URL.
"""

import fcntl
import hashlib
import html
import json
import os
from pathlib import Path
import subprocess
import sys
import time
from urllib.parse import unquote, urlparse

from PIL import Image, ImageDraw, ImageOps

CACHE = (
    Path(os.environ.get("XDG_CACHE_HOME", str(Path.home() / ".cache")))
    / "hyprlock-media"
)
CACHE.mkdir(parents=True, exist_ok=True, mode=0o700)
FALLBACK = CACHE / "no-cover.png"


def run(*args):
    try:
        return subprocess.run(
            args, capture_output=True, text=True, timeout=2, check=True
        ).stdout.strip()
    except (OSError, subprocess.SubprocessError):
        return ""


def snapshot():
    # Share a short-lived snapshot between image and label, and keep the same
    # player if multiple players are playing. Prefer Playing over Paused.
    with (CACHE / "metadata.lock").open("w") as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        state_file = CACHE / "metadata.json"
        try:
            old = json.loads(state_file.read_text())
        except (OSError, ValueError):
            old = {}
        if 0 <= time.time() - old.get("time", 0) < 0.6:
            return old
        players = run("playerctl", "--list-all").splitlines()
        previous = old.get("player")
        if previous in players:
            players.remove(previous)
            players.insert(0, previous)
        candidates = [(p, run("playerctl", "--player", p, "status")) for p in players]
        chosen = next(((p, s) for p, s in candidates if s == "Playing"), None)
        chosen = chosen or next(((p, s) for p, s in candidates if s == "Paused"), None)
        data = {"time": time.time()}
        if chosen:
            player, status = chosen
            data.update(player=player, status=status)
            # Query fields independently so metadata containing newlines or
            # separators cannot shift the title, artist or artwork fields.
            for key, field in [
                ("title", "xesam:title"),
                ("artist", "xesam:artist"),
                ("art", "mpris:artUrl"),
            ]:
                data[key] = run("playerctl", "--player", player, "metadata", field)
        state_file.write_text(json.dumps(data))
        return data


def clean(value, limit):
    value = " ".join(value.split())
    if len(value) > limit:
        value = value[: limit - 1].rstrip() + "…"
    return html.escape(value, quote=False)


def label(data):
    if not data.get("player"):
        return '<span size="small" alpha="75%">♫  Nothing playing</span>'
    title = clean(data.get("title") or "Unknown track", 38)
    artist = clean(data.get("artist") or "Unknown artist", 44)
    player = clean(data["player"].split(".")[0].capitalize(), 20)
    status = "▶  NOW PLAYING" if data["status"] == "Playing" else "Ⅱ  PAUSED"
    return (
        f'<span size="small" foreground="#cba6f7">{status} · {player}</span>\n'
        f'<b>{title}</b>\n<span size="small" alpha="80%">{artist}</span>'
    )


def fallback():
    if not FALLBACK.exists():
        image = Image.new("RGB", (256, 256), "#313244")
        draw = ImageDraw.Draw(image)
        draw.line(
            [(112, 168), (112, 76), (180, 60), (180, 151)], fill="#cba6f7", width=10
        )
        draw.line([(112, 92), (180, 76)], fill="#cba6f7", width=10)
        draw.ellipse((72, 151, 115, 185), fill="#cba6f7")
        draw.ellipse((140, 134, 183, 168), fill="#cba6f7")
        image.save(FALLBACK)
    return str(FALLBACK)


def artwork(data):
    default = fallback()
    url = data.get("art", "")
    if not url:
        return default
    key = hashlib.sha256(url.encode()).hexdigest()
    target = CACHE / (key + ".png")
    failed = CACHE / (key + ".failed")
    with (CACHE / "art.lock").open("w") as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        if target.exists():
            return str(target)
        if failed.exists() and time.time() - failed.stat().st_mtime < 60:
            return default
        raw = CACHE / (key + ".download")
        temporary = CACHE / (key + ".tmp.png")
        try:
            parsed = urlparse(url)
            if parsed.scheme in ("http", "https"):
                subprocess.run(
                    [
                        "curl",
                        "--fail",
                        "--silent",
                        "--location",
                        "--proto",
                        "=http,https",
                        "--proto-redir",
                        "=http,https",
                        "--connect-timeout",
                        "3",
                        "--max-time",
                        "6",
                        "--max-filesize",
                        "10485760",
                        "--output",
                        str(raw),
                        url,
                    ],
                    check=True,
                    timeout=8,
                    stdout=subprocess.DEVNULL,
                    stderr=subprocess.DEVNULL,
                )
                source = raw
            elif parsed.scheme == "file" and parsed.netloc in ("", "localhost"):
                source = Path(unquote(parsed.path))
            elif not parsed.scheme and Path(url).is_absolute():
                source = Path(url)
            else:
                return default
            with Image.open(source) as cover:
                cover = ImageOps.exif_transpose(cover).convert("RGB")
                ImageOps.fit(cover, (320, 320), method=Image.Resampling.LANCZOS).save(
                    temporary
                )
            temporary.replace(target)
            failed.unlink(missing_ok=True)
            # Bound persistent cache growth while retaining the current cover.
            covers = sorted(
                (p for p in CACHE.glob("*.png") if p != FALLBACK),
                key=lambda p: p.stat().st_mtime,
                reverse=True,
            )
            for stale in covers[64:]:
                if stale != target:
                    stale.unlink(missing_ok=True)
            for stale in CACHE.glob("*.failed"):
                if time.time() - stale.stat().st_mtime > 86400:
                    stale.unlink(missing_ok=True)
            return str(target)
        except (
            OSError,
            ValueError,
            subprocess.SubprocessError,
            Image.DecompressionBombError,
        ):
            failed.touch()
            return default
        finally:
            raw.unlink(missing_ok=True)
            temporary.unlink(missing_ok=True)


if __name__ == "__main__":
    mode = sys.argv[1] if len(sys.argv) > 1 else "label"
    if mode == "fallback":
        print(fallback())
    elif mode in ("label", "art"):
        data = snapshot()
        print(label(data) if mode == "label" else artwork(data))
    else:
        raise SystemExit("Usage: hyprlock-media.py [label|art|fallback]")
