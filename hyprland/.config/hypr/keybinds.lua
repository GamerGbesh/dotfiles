local terminal = "kitty"
local fileManager = "dolphin"
local menu = "wofi --show drun"
local mainBrowser = "firefox"
local mainMod = "SUPER"

-- Vim directional binding
local left = "h"
local right = "l"
local up = "k"
local down = "j"

-- Arrow keys
-- local left = "left"
-- local right = "right"
-- local up = "up"
-- local down = "down"

-- Core actions
hl.bind("ALT + F4", hl.dsp.window.close())
hl.bind(mainMod .. " + RETURN", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + F", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.fullscreen({ action = "toggle" }))
hl.bind(mainMod .. " + space", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd(mainBrowser))
hl.bind(mainMod .. " + V", hl.dsp.exec_cmd("cliphist list | wofi --dmenu | cliphist decode | wl-copy"))
hl.bind(mainMod .. " + ESCAPE", hl.dsp.exec_cmd("missioncenter"))
hl.bind(mainMod .. " + PERIOD", hl.dsp.exec_cmd("wofi-emoji"))
hl.bind(mainMod .. " + N", hl.dsp.exec_cmd("swaync-client -t"))
hl.bind(mainMod .. " + W", hl.dsp.exec_cmd("waypaper"))
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("/home/gbesh/.config/swaync/scripts/acapture.sh"))
hl.bind(mainMod .. " + D", hl.dsp.exec_cmd("/home/gbesh/.config/swaync/scripts/dnd-notify.sh"))
hl.bind("CTRL + SHIFT + B", hl.dsp.exec_cmd("pkill -SIGUSR1 waybar"))
-- Screenshots
hl.bind("print", hl.dsp.exec_cmd("hyprshot -m region -o ~/Pictures/Screenshots"))
hl.bind("CTRL + print", hl.dsp.exec_cmd("hyprshot -m output -o ~/Pictures/Screenshots"))
hl.bind(mainMod .. " + print", hl.dsp.exec_cmd("hyprshot -m window -o ~/Pictures/Screenshots"))
hl.bind("ALT + print", hl.dsp.exec_cmd("hyprshot -m active -o ~/Pictures/Screenshots"))
hl.bind(mainMod .. " + P", hl.dsp.exec_cmd("hyprpicker | wl-copy"))

-- Power / Calculator
hl.bind(mainMod .. " + Q", hl.dsp.exec_cmd("wlogout -b 4"), { locked = true, repeating = true })
hl.bind("XF86Calculator", hl.dsp.exec_cmd("gnome-calculator"), { locked = true, repeating = true })

-- Workspace switching: hl.dsp.focus({ workspace = id })
-- Relative switching: "e+1" / "e-1"
for i = 1, 9 do
	hl.bind(mainMod .. " + " .. i, hl.dsp.focus({ workspace = i }))
	hl.bind(mainMod .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = i }))
end
hl.bind(mainMod .. " + 0", hl.dsp.focus({ workspace = 10 }))
hl.bind(mainMod .. " + SHIFT + 0", hl.dsp.window.move({ workspace = 10 }))

hl.bind(mainMod .. " + CTRL + " .. right, hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + CTRL + " .. left, hl.dsp.focus({ workspace = "e-1" }))

-- Scroll through workspaces with mouse wheel
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))
-- Drag the mouse wheel
hl.config({
	binds = {
		drag_threshold = 10, -- Fire a drag event only after dragging for more than 10px
	},
})
hl.bind(mainMod .. "+ mouse:272", hl.dsp.window.drag(), { mouse = true }) -- ALT + LMB: Move a window by dragging more than 10px.
hl.bind(mainMod .. "+ mouse:273", hl.dsp.window.resize(), { mouse = true }) -- ALT + LMB: Floats a window by clicking

-- Special workspace (scratchpad)
hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

hl.bind(mainMod .. "+ U", hl.dsp.workspace.toggle_special("hidden"))
hl.bind(mainMod .. "+ SHIFT + U", hl.dsp.window.move({ workspace = "special:hidden" }))

-- Focus movement: hl.dsp.focus({ direction = "..." }) — full word, not l/r/u/d
hl.bind(mainMod .. " + " .. left, hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + " .. right, hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + " .. up, hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + " .. down, hl.dsp.focus({ direction = "down" }))

-- Move window (swap with neighbour)
hl.bind(mainMod .. " + SHIFT + " .. left, hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + " .. right, hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + " .. up, hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + " .. down, hl.dsp.window.move({ direction = "down" }))

-- Resize window (keyboard)
hl.bind(mainMod .. " + SHIFT + CTRL + " .. left, hl.dsp.window.resize({ x = -50, y = 0, relative = true }))
hl.bind(mainMod .. " + SHIFT + CTRL + " .. right, hl.dsp.window.resize({ x = 50, y = 0, relative = true }))
hl.bind(mainMod .. " + SHIFT + CTRL + " .. up, hl.dsp.window.resize({ x = 0, y = -50, relative = true }))
hl.bind(mainMod .. " + SHIFT + CTRL + " .. down, hl.dsp.window.resize({ x = 0, y = 50, relative = true }))

-- Move floating window (moveactive dispatcher via exec_raw)
hl.bind(mainMod .. " + ALT + " .. left, hl.dsp.window.move({ x = -50, y = 0, relative = true }))
hl.bind(mainMod .. " + ALT + " .. right, hl.dsp.window.move({ x = 50, y = 0, relative = true }))
hl.bind(mainMod .. " + ALT + " .. up, hl.dsp.window.move({ x = 0, y = -50, relative = true }))
hl.bind(mainMod .. " + ALT + " .. down, hl.dsp.window.move({ x = 0, y = 50, relative = true }))
-- Volume
hl.bind(
	"XF86AudioRaiseVolume",
	hl.dsp.exec_cmd("wpctl set-volume  @DEFAULT_AUDIO_SINK@ 5%+ --limit 1.0"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioLowerVolume",
	hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%- --limit 0.0"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioMicMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
	{ locked = true, repeating = true }
)

-- Brightness
hl.bind(
	"XF86MonBrightnessUp",
	hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+ && ~/.config/hypr/scripts/brightness_osd.sh"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86MonBrightnessDown",
	hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%- && ~/.config/hypr/scripts/brightness_osd.sh"),
	{ locked = true, repeating = true }
)

-- Media
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

-- Games
hl.bind("XF86Launch2", hl.dsp.exec_cmd("heroic"))

-- 4-finger horizontal swipe → switch workspace
hl.gesture({ fingers = 4, direction = "horizontal", action = "workspace" })
