#!/usr/bin/env python3
"""
Test suite for QML Clipboard Acceptance Tests
"""

import subprocess
import time
import io
from PIL import Image, ImageDraw

def copy_image(img, fmt="PNG"):
    buf = io.BytesIO()
    img.save(buf, format=fmt)
    mime = "image/png" if fmt == "PNG" else "image/jpeg"
    p = subprocess.Popen(["wl-copy", "-t", mime], stdin=subprocess.PIPE)
    p.communicate(buf.getvalue())
    time.sleep(0.15)

def copy_text(txt):
    p = subprocess.Popen(["wl-copy"], stdin=subprocess.PIPE)
    p.communicate(txt.encode("utf-8"))
    time.sleep(0.15)

print("=== Setting up test clipboard entries ===")

# 1. Red square
img_a = Image.new("RGB", (200, 200), color=(243, 139, 168)) # Catppuccin red
copy_image(img_a, "PNG")
print("1. Copied Image A (Red square)")

# 2. Blue gradient
img_b = Image.new("RGB", (400, 200), color=(137, 180, 250)) # Catppuccin blue
draw_b = ImageDraw.Draw(img_b)
for i in range(0, 400, 20):
    draw_b.line([(i, 0), (i, 200)], fill=(180, 190, 254), width=3)
copy_image(img_b, "PNG")
print("2. Copied Image B (Blue patterned)")

# 3. Transparent Green circle (RGBA)
img_c = Image.new("RGBA", (250, 250), color=(0, 0, 0, 0)) # Transparent
draw_c = ImageDraw.Draw(img_c)
draw_c.ellipse([(25, 25), (225, 225)], fill=(166, 227, 161, 255), outline=(148, 226, 213, 255), width=6)
copy_image(img_c, "PNG")
print("3. Copied Image C (Transparent Green circle)")

# 4. Text entries
copy_text("git commit -m 'feat: implement Catppuccin Mocha QML clipboard'")
print("4. Copied Text A")

# 5. Wide landscape screenshot
img_wide = Image.new("RGB", (1920, 600), color=(49, 50, 68))
draw_w = ImageDraw.Draw(img_wide)
draw_w.text((100, 250), "Quickshell Wayland Clipboard Picker", fill=(203, 166, 247))
copy_image(img_wide, "PNG")
print("5. Copied Wide Image")

# 6. Multi-line code text
copy_text("""function calculateStats(items) {
    const total = items.length;
    const images = items.filter(i => i.type === 'image');
    return { total, imageCount: images.length };
}""")
print("6. Copied Code Snippet Text")

print("\n=== Current top cliphist entries ===")
p_list = subprocess.run(["cliphist", "list"], capture_output=True, text=True)
for line in p_list.stdout.splitlines()[:8]:
    print(line)
