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

hl.window_rule({
	match = { class = "com.app.bluetui" },
	float = true,
	center = true,
	size = { 700, 600 },
})

hl.window_rule({
	match = { class = "edit68k.exe" },
	float = false,
})

hl.window_rule({
	match = { class = "com.ktechpit.whatsie", title = "Downloads" },
	float = true,
	center = true,
	size = { 700, 600 },
})

hl.window_rule({
	match = { class = "org.mozilla.Thunderbird", title = [[^Write.*]] },
	float = true,
	center = true,
	size = { 700, 600 },
})

hl.window_rule({
	match = { class = "dev.zed.Zed" },
	opacity = 0.95,
})

hl.layer_rule({
	match = { title = "noctalia", namespace = "noctalia-background-.*$" },
	ignore_alpha = 0.5,
	blur = true,
	blur_popups = true,
})

hl.workspace_rule({ workspace = "1", layout = "master" })
hl.workspace_rule({ workspace = "3", layout = "scrolling" })
