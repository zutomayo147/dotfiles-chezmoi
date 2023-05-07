local wezterm = require("wezterm")
local act = wezterm.action -- A helper function for my fallback fonts
local utils = require("utils")
local keybinds = require("keybinds")
local scheme = wezterm.get_builtin_color_schemes()["nord"]
require("on")
-- function font_with_fallback(name, params)
--     local names = { name, 'Noto Color Emoji', 'JetBrains Mono' }
--     return wezterm.font_with_fallback(names, params)
-- end

-- Show which key table is active in the status area
wezterm.on("update-right-status", function(window, pane)
    local name = window:active_key_table()
    if name then
        name = "TABLE: " .. name
    end
    window:set_right_status(name or "")
end)

-- /etc/ssh/sshd_config
-- AcceptEnv TERM_PROGRAM_VERSION COLORTERM TERM TERM_PROGRAM WEZTERM_REMOTE_PANE
-- sudo systemctl reload sshd

---------------------------------------------------------------
--- functions
---------------------------------------------------------------
-- local function enable_wayland()
-- 	local wayland = os.getenv("XDG_SESSION_TYPE")
-- 	if wayland == "wayland" then
-- 		return true
-- 	end
-- 	return false
-- end
---------------------------------------------------------------
--- Merge the Config
---------------------------------------------------------------
local function insert_ssh_domain_from_ssh_config(c)
    if c.ssh_domains == nil then
        c.ssh_domains = {}
    end
    for host, config in pairs(wezterm.enumerate_ssh_hosts()) do
        table.insert(c.ssh_domains, {
            name = host,
            remote_address = config.hostname .. ":" .. config.port,
            username = config.user,
            multiplexing = "None",
            assume_shell = "Posix",
        })
    end
    return c
end

--- load local_config
-- Write settings you don't want to make public, such as ssh_domains
package.path = os.getenv("HOME") .. "/.local/share/wezterm/?.lua;" .. package.path
local function load_local_config(module)
    local m = package.searchpath(module, package.path)
    if m == nil then
        return {}
    end
    return dofile(m)
    -- local ok, _ = pcall(require, "local")
    -- if not ok then
    -- 	return {}
    -- end
    -- return require("local")
end

local local_config = load_local_config("local")
-- local local_config = {
-- 	ssh_domains = {
-- 		{
-- 			-- This name identifies the domain
-- 			name = "my.server",
-- 			-- The address to connect to
-- 			remote_address = "192.168.8.31",
-- 			-- The username to use on the remote host
-- 			username = "katayama",
-- 		},
-- 	},
-- }
-- return local_config
local config = {
    enable_tab_bar = false,
    window_decorations = "NONE",
    use_dead_keys = false,
    check_for_updates = false,
    use_ime = true,
    warn_about_missing_glyphs = false,
    animation_fps = 1,
    cursor_blink_ease_in = "Constant",
    cursor_blink_ease_out = "Constant",
    cursor_blink_rate = 0,
    enable_wayland = false,
    color_scheme_dirs = { os.getenv("HOME") .. "/.config/wezterm/colors/" },
    enable_scroll_bar = false,

    -- adjust_window_size_when_changing_font_size = false,
    adjust_window_size_when_changing_font_size = true,
    window_padding = {
        left = 0,
        right = 0,
        top = 0,
        bottom = 0,
    },
    use_fancy_tab_bar = false,
    tab_bar_at_bottom = false,
    -- inactive_pane_hsb = {
    --     saturation = 0.9,
    --     brightness = 0.8,
    -- },
    -- enable_csi_u_key_encoding = true,
    -- leader = { key = "Space", mods = "CTRL|SHIFT" },
    -- keys = keybinds.create_keybinds(),
    -- key_tables = keybinds.key_tables,
    -- mouse_bindings = keybinds.mouse_bindings,

    -- disable_default_key_bindings = true,
    -- leader = { key = 'a', mods = 'CTRL', timeout_milliseconds = 1000 },
    keys = {
        -- {
        --     key = 'H',
        --     mods = 'SHIFT|CTRL',
        --     action = wezterm.action.Search { Regex = '[a-f0-9]{6,}' },
        -- },
        {
            key = "v",
            mods = "CTRL",
            action = act.PasteFrom("Clipboard"),
        },
        {
            key = "Space",
            mods = "CTRL|SHIFT",
            action = act.ActivateCopyMode,
        },
    },
    -- key_tables = {
    --     search_mode = {
    --         { key = 'Enter', mods = 'NONE', action = act.CopyMode 'PriorMatch' },
    --         { key = 'Escape', mods = 'NONE', action = act.CopyMode 'Close' },
    --         { key = 'n', mods = 'CTRL', action = act.CopyMode 'NextMatch' },
    --         { key = 'p', mods = 'CTRL', action = act.CopyMode 'PriorMatch' },
    --         { key = 'r', mods = 'CTRL', action = act.CopyMode 'CycleMatchType' },
    --         { key = 'u', mods = 'CTRL', action = act.CopyMode 'ClearPattern' },
    --         {
    --             key = 'PageUp',
    --             mods = 'NONE',
    --             action = act.CopyMode 'PriorMatchPage',
    --         },
    --         {
    --             key = 'PageDown',
    --             mods = 'NONE',
    --             action = act.CopyMode 'NextMatchPage',
    --         },
    --         { key = 'UpArrow', mods = 'NONE', action = act.CopyMode 'PriorMatch' },
    --         {
    --             key = 'DownArrow',
    --             mods = 'NONE',
    --             action = act.CopyMode 'NextMatch',
    --         },
    --     },
    -- },
    hyperlink_rules = {
        -- Linkify things that look like URLs and the host has a TLD name.
        -- Compiled-in default. Used if you don't specify any hyperlink_rules.
        {
            regex = "\\b\\w+://[\\w.-]+\\.[a-z]{2,15}\\S*\\b",
            format = "$0",
        },

        -- linkify email addresses
        -- Compiled-in default. Used if you don't specify any hyperlink_rules.
        {
            regex = [[\b\w+@[\w-]+(\.[\w-]+)+\b]],
            format = "mailto:$0",
        },

        -- file:// URI
        -- Compiled-in default. Used if you don't specify any hyperlink_rules.
        {
            regex = [[\bfile://\S*\b]],
            format = "$0",
        },

        -- Linkify things that look like URLs with numeric addresses as hosts.
        -- E.g. http://127.0.0.1:8000 for a local development server,
        -- or http://192.168.1.1 for the web interface of many routers.
        {
            regex = [[\b\w+://(?:[\d]{1,3}\.){3}[\d]{1,3}\S*\b]],
            format = "$0",
        },

        -- Make task numbers clickable
        -- The first matched regex group is captured in $1.
        {
            regex = [[\b[tT](\d+)\b]],
            format = "https://example.com/tasks/?t=$1",
        },

        -- localhost
        {
            regex = [[((http([s]){0,1}://){0,1}(localhost|127.0.0.1){1}(([:]){0,1}[0-9]{4}){0,1}/{0,1}){1}]],
            format = "$1",
        },

        -- {
        --     regex = [[github\.com/([a-zA-Z0-9_-]+/){1,2}[a-zA-Z0-9_-]+/?$]]
        --     format = "$1",
        -- },

        -- Make username/project paths clickable. This implies paths like the following are for GitHub.
        -- ( "nvim-treesitter/nvim-treesitter" | wbthomason/packer.nvim | wez/wezterm | "wez/wezterm.git" )
        -- As long as a full URL hyperlink regex exists above this it should not match a full URL to
        -- GitHub or GitLab / BitBucket (i.e. https://gitlab.com/user/project.git is still a whole clickable URL)
        {
            regex = [[["]?([\w\d]{1}[-\w\d]+)(/){1}([-\w\d\.]+)["]?]],
            format = "https://www.github.com/$1/$3",
        },
    },

    -- font = wezterm.font("HackGenNerdConsole"),
    -- font_dirs = { 'fonts' },
    -- font = wezterm.font('JetBrainsMono Nerd Font', { weight = 'Regular', stretch = 'Expanded', italic = false }),
    font = wezterm.font("JetBrainsMono", { weight = "Regular", stretch = "Expanded", italic = false }),
    -- font = wezterm.font('UDEVGothic', { weight = 'Regular', stretch = 'Expanded', italic = false }),
    -- font = wezterm.font("UDEVGothicLG", { weight = "Regular", stretch = "Expanded", italic = false }),
    -- font = wezterm.font("UDEVGothicLG", { weight = "Regular", italic = false }),

    freetype_load_target = "Normal",
    -- font = wezterm.font('JetBrainsMono Nerd Font', { weight = 'Medium', stretch = 'Normal', italic = false }),
    -- font_rules = {
    --     -- Select a fancy italic font for italic text
    --     {
    --         italic = true,
    --         font = font_with_fallback 'Operator Mono SSm Lig Medium Italic',
    --     },
    --
    --     -- Similarly, a fancy bold+italic font
    --     {
    --         italic = true,
    --         intensity = 'Bold',
    --         font = font_with_fallback 'Operator Mono SSm Lig Book Italic',
    --     },
    --
    --     -- Make regular bold text a different color to make it stand out even more
    --     {
    --         intensity = 'Bold',
    --         font = font_with_fallback(
    --             'Operator Mono SSm Lig Bold',
    --             { foreground = 'tomato' }
    --         ),
    --     },
    --
    --     -- For half-intensity text, use a lighter weight font
    --     {
    --         intensity = 'Half',
    --         font = font_with_fallback 'Operator Mono SSm Lig Light',
    --     },
    -- },
    -- freetype_load_flags = 'NO_HINTING|MONOCHROME',
    font_size = 9.5,
    -- font_size = 11.5,
    -- font_size = 11,
    -- font_size = 12,
    -- font_antialias = "None",
    -- font_antialias = "Subpixel",
    bold_brightens_ansi_colors = true,
    -- bold_brightens_ansi_colors = false,
    initial_cols = 260,
    initial_rows = 65,
    cell_width = 1.0,
    -- line_height = 1.0,
    -- default_prog = { "/usr/bin/tmux attach", "-l" },
    -- default_prog = { "/usr/bin/tmux", "-l" },
    default_prog = { "/usr/bin/tmux" },
    -- default_prog = { "/usr/bin/zsh" },
    -- default_prog = { "/usr/bin/tmux attach || /usr/bin/tmux", "-l" },
    -- {
    --     default_prog = { "/usr/bin/tmux", "-l" },
    --     args = { "attach" }
    -- },
    default_cwd = "~",
    default_cursor_style = "SteadyUnderline",
    -- cursor_thickness = '0.1',
    -- font_hinting = "Full",
    -- color_scheme = 'Red Scheme',
    color_scheme = "Sonokai (Gogh)",
    colors = {
        -- color_scheme = "Molokai",
        -- color_scheme = "Sakura",
        -- The default text color
        -- foreground = "silver",
        foreground = "white",
        -- foreground = "pink",
        -- The default background color
        background = "black",
        -- background = "#222436",
        -- background = "#2D2A2E",
        -- Overrides the cell background color when the current cell is occupied by the
        -- cursor and the cursor style is set to Block
        -- cursor_bg = "white",
        -- Overrides the text color when the current cell is occupied by the cursor
        cursor_fg = "black",
        -- Specifies the border color of the cursor when the cursor style is set to Block,
        -- or the color of the vertical or horizontal bar when the cursor style is set to
        -- Bar or Underline.
        cursor_bg = "AZURE",
        cursor_border = "AZURE",

        -- the foreground color of selected text
        selection_fg = "black",
        -- the background color of selected text
        -- selection_bg = "#fffacd",
        selection_bg = "pink",

        -- The color of the scrollbar "thumb"; the portion that represents the current viewport
        -- scrollbar_thumb = "#222222",

        -- The color of the split lines between panes
        split = "#444444",

        -- ansi = { "#000000", "DEEPPINK", "#B5Bd68", "#F0E68C", "GREENYELLOW", "#EE82EE", "#8ABEB7", "#C0C0C0" },
        -- ansi = { "#000000", "DEEPPINK", "#EE82EE", "#F0E68C", "GREENYELLOW", "#8ABEB7", "#8ABEB7", "#C0C0C0" },
        ansi = { "#000000", "DEEPPINK", "#FE5FD6", "#F0E68C", "GREENYELLOW", "#8ABEB7", "#8ABEB7", "#C0C0C0" },
        -- ansi = { "white", "white", "white", "white", "white", "white", "white", "white" },
        -- ansi = { "red", "red", "#EE82EE", "red", "red", "white", "red", "red" },

        -- brights = { "grey", "orchid", "yellowgreen", "yellow", "#7EA1BB", "#A0463E", "POWDERBLUE", "white" },
        -- brights = { "#808080", "#DA70D6", "#9ACD32", "#FFFF00", "#7EA1BB", "#A0463E", "#B0E0E6", "white" },
        -- brights = { "#808080", "#C3C3BE", "#9ACD32", "#FFFF00", "#7EA1BB", "#B294BB", "#B0E0E6", "white" },
        brights = { "#808080", "#C3C3BE", "#F85ED2", "#FFFF00", "#7EA1BB", "#B294BB", "#B0E0E6", "white" },
        -- brights = { "#808080", "#C3C3BE", "#F85ED2", "#FFFF00", "#7EA1BB", "#B294BB", "#B0E0E6", "#EE82EE" },
        -- brights = { "white", "white", "white", "white", "white", "white", "white", "white" },

        -- Arbitrary colors of the palette in the range from 16 to 255
        -- indexed = { [136] = "#af8700" },

        -- Since: 20220319-142410-0fcdea07
        -- When the IME, a dead key or a leader key are being processed and are effectively
        -- holding input pending the result of input composition, change the cursor
        -- to this color to give a visual cue about the compose state.
        compose_cursor = "POWDERBLUE",
        tab_bar = {
            -- The color of the inactive tab bar edge/divider
            inactive_tab_edge = "#575757",
        },
    },
    inactive_pane_hsb = {
        saturation = 0.9,
        brightness = 0.8,
    },
    -- window_background_image = '~/Pictures/pc/mac.png',
    -- window_background_opacity = 1.0,
    scrollback_lines = 3500,

    window_background_image_hsb = {
        -- Darken the background image by reducing it to 1/3rd
        brightness = 0.3,

        -- You can adjust the hue by scaling its value.
        -- a multiplier of 1.0 leaves the value unchanged.
        hue = 1.0,

        -- You can adjust the saturation also.
        saturation = 1.0,
    },

    -- window_frame = {
    --     -- The font used in the tab bar.
    --     -- Roboto Bold is the default; this font is bundled
    --     -- with wezterm.
    --     -- Whatever font is selected here, it will have the
    --     -- main font setting appended to it to pick up any
    --     -- fallback fonts you may have used there.
    --     font = wezterm.font({ family = "Roboto", weight = "Bold" }),
    --
    --     -- The size of the font in the tab bar.
    --     -- Default to 10. on Windows but 12.0 on other systems
    --     font_size = 11.0,
    --
    --     -- The overall background color of the tab bar when
    --     -- the window is focused
    --     active_titlebar_bg = "#333333",
    --
    --     -- The overall background color of the tab bar when
    --     -- the window is not focused
    --     inactive_titlebar_bg = "#333333",
    -- },
}
local merged_config = utils.merge_tables(config, local_config)
return insert_ssh_domain_from_ssh_config(merged_config)
-- return {
-- }