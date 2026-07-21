hl.config({
	plugin = {
		hyprfocus = {
			enable = false,
			animate_floating = true,
		},
	},
})

hl.animation({
	leaf = "hyprfocusIn",
	enabled = true,
	speed = 10,
	bezier = "default",
})

hl.animation({
	leaf = "hyprfocusOut",
	enabled = true,
	speed = 10,
	bezier = "default",
})
