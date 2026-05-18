local function regex(list)
    return table.concat(list, "|")
end
--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/
-- and https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/

-- Example window rules that are useful

local suppressMaximizeRule = hl.window_rule({
    -- Ignore maximize requests from all apps. You'll probably like this.
    name            = "all classes",
    match           = { class = ".*" },

    suppress_event  = "maximize",
    persistent_size = true,
})
-- suppressMaximizeRule:set_enabled(false)

hl.window_rule({
    -- Fix some dragging issues with XWayland
    name     = "fix-xwayland-drags",
    match    = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },

    no_focus = true,
})

hl.window_rule({
    name = "opacity-0.8",
    match = {
        class = table.concat({
            "com.mitchellh.ghostty",
            "org.kde.konsole",
        }, "|"),
    },
    opacity = 0.8,
})

hl.window_rule({
    name = "opacity-0.9",
    match = {
        class = table.concat({
            "obsidian",
            "discord",
            "kate",
            "QQ",
            "dolphin",
            "btrfs-assistant",
            "Element",
        }, "|"),
    },
    opacity = 0.9,
})

hl.window_rule({
    name = "full-width",
    match = {
        class = regex({
            "vivaldi-stable",
            "code",
            "^(firefox|firefox-developer-edition|org.mozilla.firefox)$",
            "mpv",
            -- "Unity",
            "jetbrains-rider",
            "virt-manager",
            "steam_app_default",
        }),
    },
    scrolling_width = 1.0,
})

hl.window_rule({
    name = "open-on-DP-3",
    match = {
        class = regex({
            "discord",
            "QQ",
            "org.telegram.desktop",
            "Element",
            "wechat",
        }),
    },
    monitor = "DP-3",
})

hl.window_rule({
    name = "open-on-DP-2",
    match = {
        class = regex({
            "vivaldi-stable",
            "steam_app_default",
            "steam_app_0",
            "yuanshen.exe",
        }),
    },
    monitor = "DP-2",
})

hl.window_rule({
    name = "games",
    match = {
        class = regex({
            "steam_app_default",
            "steam_app_0",
            "yuanshen.exe",
        }),
    },
    render_unfocused = true,
    sync_fullscreen = true,
    fullscreen = true,
    fullscreen_state = 2,
    confine_pointer = false,
})

hl.window_rule({
    name = "floating",
    match = {
        class = regex({
            "satty",
            "org.kde.kcalc",
            "org.kde.ark",
            "org.kde.kdeconnect.daemon",
            "showmethekey-gtk"
        }),
    },
    float = true,
})

hl.window_rule({
    name = "no-floating",
    match = {
        class = regex({
            "QQ",
        }),
    },
    float = false,
})

hl.window_rule({
    name = "floating-QQ",
    match = {
        title = table.concat({
            "天气",
            "资料卡",
        }, "|"),
    },
    float = true,
})

hl.window_rule({
    match = {
        class = "steam",
        title = "^notificationtoasts_\\d+_desktop$",
    },

    move = { "monitor_w - window_w + 138", "monitor_h - window_h + 30" },
})
