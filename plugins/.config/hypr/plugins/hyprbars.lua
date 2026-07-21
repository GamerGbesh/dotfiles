hl.config({
	plugin = {
		hyprbars = {
			bar_height = 30,
			on_double_click = "hyprctl dispatch 'hl.dsp.window.fullscreen({ action = toggle})'",
			enabled = false,
			bar_color = "#334155",
		},
	},
})

hl.plugin.hyprbars.add_button({
	bg_color = "rgb(ff4040)",
	fg_color = "rgb(ffffff)",
	size = 20,
	icon = "󰅖",
	action = "hyprctl dispatch 'hl.dsp.window.close()'",
})

hl.plugin.hyprbars.add_button({
	bg_color = "rgb(eeee11)",
	fg_color = "rgb(000000)",
	size = 20,
	icon = "󰊔",
	action = "hyprctl dispatch 'hl.dsp.window.fullscreen({ action = toggle})'",
})
