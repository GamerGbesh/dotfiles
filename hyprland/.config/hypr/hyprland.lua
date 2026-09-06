-- #######################################################################################
-- Hyprland Lua Configuration  (Hyprland ≥ 0.55)
-- https://wiki.hypr.land/Configuring/Start/
-- #######################################################################################

-- Required modules
require("monitors")
require("env")
require("animation")
require("keybinds")
require("autostart")
require("windows")
require("layouts")
-- require("plugins")

-- Color module
local colors = require("mocha")

hl.config({
	cursor = {
		no_hardware_cursors = false,
	},

	render = {
		direct_scanout = false,
	},

	general = {
		gaps_in = 5,
		gaps_out = 5,
		border_size = 2,

		col = {
			active_border = {
				colors = {
					"rgba(" .. colors.mauve:sub(2) .. "ff)",
					"rgba(" .. colors.pink:sub(2) .. "ff)",
					"rgba(" .. colors.blue:sub(2) .. "ff)",
					"rgba(" .. colors.lavender:sub(2) .. "ff)",
				},
				angle = 45,
			},
			inactive_border = "rgba(" .. colors.surface0:sub(2) .. "aa)",
		},

		resize_on_border = false,
		allow_tearing = false,
		layout = "dwindle",
	},

	decoration = {
		rounding = 10,
		rounding_power = 2,

		active_opacity = 1.0,
		inactive_opacity = 0.95,

		shadow = {
			enabled = true,
			range = 4,
			render_power = 3,
			color = "rgba(1a1a1aee)",
		},

		blur = {
			enabled = true,
			size = 6,
			passes = 3,
			vibrancy = 0.18,
		},
	},

	animations = {
		enabled = true,
	},

	master = {
		new_status = "master",
		focus_master_on_close = true,
	},

	misc = {
		force_default_wallpaper = -1,
		disable_hyprland_logo = false,
	},

	input = {
		kb_layout = "us",
		kb_variant = "",
		kb_model = "",
		kb_options = "",
		kb_rules = "",

		follow_mouse = 1,
		sensitivity = 0,

		touchpad = {
			natural_scroll = true,
		},
	},
})

hl.device({
	name = "epic-mouse-v1",
	sensitivity = -0.5,
})
