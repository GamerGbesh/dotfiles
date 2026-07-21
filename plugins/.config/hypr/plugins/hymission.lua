hl.bind("SUPER + TAB", hl.plugin.hymission.toggle)
hl.bind("SUPER + A", function()
	hl.plugin.hymission.toggle("forceall")
end)
hl.bind("SUPER + CTRL + TAB", function()
	hl.plugin.hymission.open("onlycurrentworkspace")
end)

hl.plugin.hymission.gesture({
	fingers = 4,
	direction = "vertical",
	action = "open",
	scope = "onlycurrentworkspace",
})

hl.config({
	plugin = {
		hymission = {
			toggle_switch_mode = 1,
			switch_toggle_auto_next = 1,
			switch_release_key = "Super_L",
		},
	},
})
