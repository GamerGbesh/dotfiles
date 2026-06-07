-- Suppress maximize requests from all windows
hl.window_rule({
	match = { class = ".*" },
	suppress_event = "maximize",
})

-- Fix XWayland drag issues (empty class+title+xwayland is sufficient to identify unmanaged windows)
hl.window_rule({
	match = { class = "^$", title = "^$", xwayland = true },
	no_focus = true,
})

-- hyprland-run: float and position near bottom-left
-- move takes a space-separated string; monitor_h is a supported variable
hl.window_rule({
	match = { class = "hyprland-run" },
	move = "20 monitor_h-120",
	float = true,
})

hl.layer_rule({
	match = "waybar",
	blur = true,
})

hl.window_rule({
	match = { class = "waypaper" },
	float = true,
	center = true,
})

hl.window_rule({
	match = { class = "dev.zed.Zed", title = "Zed — Settings" },
	float = true,
	center = true,
	size = { 1600, 1000 },
})
