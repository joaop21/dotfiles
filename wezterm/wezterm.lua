local wezterm = require("wezterm")

local config = wezterm.config_builder()

-- Colors and Appearance
config.color_scheme = "Tokyo Night Moon"

config.window_padding = {
	left = 0,
	right = 0,
	top = 0,
	bottom = 0,
}

-- Tab Bar Appearance and Colors
config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true

-- Fonts
config.font = wezterm.font("MesloLGS Nerd Font Mono")
config.font_size = 13

return config
