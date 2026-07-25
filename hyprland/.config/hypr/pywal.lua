local M = {}

local function read_file(path)
	local file = io.open(path, "r")
	if not file then
		return nil
	end

	local content = file:read("*all")
	file:close()

	return content
end

local function get_color(json, name)
	return json:match('"' .. name .. '"%s*:%s*"([^"]+)"')
end

function M.load()
	local home = os.getenv("HOME")
	local file = read_file(home .. "/.cache/wal/colors.json")

	if not file then
		return {}
	end

	return {
		background = get_color(file, "background"),
		foreground = get_color(file, "foreground"),

		color0 = get_color(file, "color0"),
		color1 = get_color(file, "color1"),
		color2 = get_color(file, "color2"),
		color3 = get_color(file, "color3"),
		color4 = get_color(file, "color4"),
		color5 = get_color(file, "color5"),
		color6 = get_color(file, "color6"),
		color7 = get_color(file, "color7"),
		color8 = get_color(file, "color8"),
		color9 = get_color(file, "color9"),
		color10 = get_color(file, "color10"),
		color11 = get_color(file, "color11"),
		color12 = get_color(file, "color12"),
		color13 = get_color(file, "color13"),
		color14 = get_color(file, "color14"),
		color15 = get_color(file, "color15"),
	}
end

return M
