-- This is an example Hyprland Lua config file.
-- Refer to the wiki for more information.
-- https://wiki.hypr.land/Configuring/Start/

-- Please note not all available settings / options are set here.
-- For a full list, see the wiki

-- You can (and should!!) split this configuration into multiple files
-- Create your files separately and then require them like this:
-- require("myColors")

-- local workspace = require("scripts.workspace")

hl.env("QT_QPA_PLATFORMTHEME", "kde")
hl.env("XCURSOR_SIZE", "32")
hl.env("HYPRCURSOR_SIZE", "32")
hl.env("XMODIFIERS", "@im=fcitx")

------------------
---- MONITORS ----
------------------

-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
hl.monitor({
    output   = "DP-2",
    mode     = "3840x2160@160",
    position = "1920x0",
    scale    = "2",
    bitdepth = 10,
    -- cm       = "hdr",
})

hl.monitor({
    output   = "DP-3",
    mode     = "1920x1080@144",
    position = "0x0",
    scale    = "1",
    bitdepth = 10,
})

-----------------------
----- PERMISSIONS -----
-----------------------

-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Permissions/
-- Please note permission changes here require a Hyprland restart and are not applied on-the-fly
-- for security reasons

-- hl.config({
--   ecosystem = {
--     enforce_permissions = true,
--   },
-- })

-- hl.permission("/usr/(bin|local/bin)/grim", "screencopy", "allow")
-- hl.permission("/usr/(lib|libexec|lib64)/xdg-desktop-portal-hyprland", "screencopy", "allow")
hl.permission({ binary = "/usr/(bin|local/bin)/hyprpm", type = "plugin", mode = "allow" })

-----------------------
---- LOOK AND FEEL ----
-----------------------

-- Refer to https://wiki.hypr.land/Configuring/Basics/Variables/
hl.config({
    general = {
        gaps_in          = { top = 0, left = 5, right = 5, bottom = 0 },
        gaps_out         = 8,

        border_size      = 3,

        col              = {
            active_border   = { colors = { "rgba(ff0000ff)", "rgba(00ff00ff)" }, angle = 45 },
            inactive_border = "rgba(595959aa)",
        },

        -- Set to true to enable resizing windows by clicking and dragging on borders and gaps
        resize_on_border = true,

        -- Please see https://wiki.hypr.land/Configuring/Advanced-and-Cool/Tearing/ before you turn this on
        allow_tearing    = false,

        layout           = "scrolling",
    },

    decoration = {
        rounding         = 20,
        rounding_power   = 2.8,

        -- Change transparency of focused and unfocused windows
        active_opacity   = 1.0,
        inactive_opacity = 1.0,

        shadow           = {
            enabled      = true,
            range        = 4,
            render_power = 3,
            color        = 0xee1a1a1a,
        },

        blur             = {
            enabled       = true,
            size          = 3,
            passes        = 3,
            vibrancy      = 0.1696,
            popups        = true,
            input_methods = true,
        },
    },

    animations = {
        enabled = true,
    },
})

-- See https://wiki.hypr.land/Configuring/Layouts/Dwindle-Layout/ for more
hl.config({
    dwindle = {
        preserve_split = true, -- You probably want this
    },
})

-- See https://wiki.hypr.land/Configuring/Layouts/Master-Layout/ for more
hl.config({
    master = {
        new_status = "master",
    },
})

-- See https://wiki.hypr.land/Configuring/Layouts/Scrolling-Layout/ for more
hl.config({
    scrolling = {
        fullscreen_on_one_column = false,
        wrap_focus = false,
        wrap_swapcol = false,
        follow_min_visible = 1.0,
    },
})

----------------
----  MISC  ----
----------------

hl.config({
    misc = {
        force_default_wallpaper = -1,    -- Set to 0 or 1 to disable the anime mascot wallpapers
        disable_hyprland_logo   = false, -- If true disables the random hyprland logo / anime girl background. :(
        render_unfocused_fps    = 60,
        focus_on_activate       = true,
        -- on_focus_under_fullscreen = 1,
    },
})


---------------
---- INPUT ----
---------------

hl.config({
    input = {
        kb_layout          = "us",
        kb_variant         = "",
        kb_model           = "",
        kb_options         = "",
        kb_rules           = "",

        follow_mouse       = 1,

        sensitivity        = 0, -- -1.0 - 1.0, 0 means no modification.

        touchpad           = {
            natural_scroll = false,
        },
        numlock_by_default = true,
        mouse_refocus      = false,
        focus_on_close     = 2,
    },
    binds = {
        scroll_event_delay = 1,
    },
})

-- others

hl.config({
    cursor = {
        no_warps = true,
    },
    render = {
        use_fp16 = 0,
    },
})

hl.config({
    xwayland = {
        -- enabled = false,
        -- force_zero_scaling = true,
        use_nearest_neighbor = false,
    }
})

hl.gesture({
    fingers = 3,
    direction = "horizontal",
    action = "workspace"
})


require("autostart")
require("hotkey")
require("windowrule")
require("layerrule")
require("animation")

-- workspace.on_window_open()

require("dms.cursor")

-- event listener

hl.on("window.active", function(w)
    local mon = hl.get_active_monitor()
    if w.at.x < mon.position.x then
        hl.dispatch(hl.dsp.layout("focus r"))
    elseif w.at.x + w.size.x > mon.position.x + mon.width / mon.scale then
        hl.dispatch(hl.dsp.layout("focus l"))
    end
end)
