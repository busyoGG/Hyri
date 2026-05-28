--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/
-- and https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/

-- Example window rules that are useful

local function rule(name, match, properties)
    for index, value in ipairs(match) do
        local opts = {
            name = name .. "-" .. index,
            match = value,
        }

        -- 合并 properties
        for k, v in pairs(properties or {}) do
            opts[k] = v
        end

        hl.window_rule(opts)
    end
end

-- 辅助函数：处理各种输入格式
local function matches(...)
    local result = {}
    local args = { ... }

    for _, arg in ipairs(args) do
        if type(arg) == "string" then
            -- 字符串 -> class
            table.insert(result, { class = arg })
        elseif type(arg) == "table" then
            -- 直接保留 table（包括复合条件）
            table.insert(result, arg)
        end
    end

    return result
end

rule("fix-xwayland-drags", {
    {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },
}, {
    no_focus = true,
})

rule("opacity-0.8", matches(
    "com.mitchellh.ghostty",
    "org.kde.konsole"
), {
    opacity = 0.8,
})

rule("opacity-0.9", matches(
    "obsidian",
    "discord",
    "kate",
    "QQ",
    "dolphin",
    "btrfs-assistant",
    "Element"
), {
    opacity = 0.9,
})

rule("full-width", matches(
    "vivaldi-stable",
    "code",
    "^(firefox|firefox-developer-edition|org.mozilla.firefox)$",
    "mpv",
    "jetbrains-rider",
    "virt-manager",
    "steam_app_default"
), {
    scrolling_width = 1.0,
})

rule("open-on-DP-3", matches(
    "discord",
    "QQ",
    "org.telegram.desktop",
    "Element",
    "wechat"
), {
    monitor = "DP-3",
})

rule("open-on-DP-2", matches(
    "vivaldi-stable",
    "steam_app_default",
    "steam_app_0",
    "yuanshen.exe"
), {
    monitor = "DP-2",
})

rule("mihoyo-launcher", matches(
    { class = "steam_app_default", title = "米哈游启动器" }
), {
    render_unfocused = true,
    fullscreen = false,
    confine_pointer = false,
})

rule("games", matches(
    "steam_app_default",
    "steam_app_0",
    "yuanshen.exe"
), {
    render_unfocused = true,
    sync_fullscreen = true,
    fullscreen = true,
    fullscreen_state = 2,
    confine_pointer = false,
    focus_on_activate = false,
})

rule("no-floating", matches(
    "QQ"
), {
    float = false,
})

-- 注意：复合条件 { class = "QQ", title = "xxx" } 会为每个 title 创建独立的规则
rule("floating", matches(
    "satty",
    "org.kde.kcalc",
    "org.kde.ark",
    "org.kde.kdeconnect.daemon",
    "showmethekey-gtk",
    { class = "QQ", title = "天气|资料卡" },
    { class = "steam", title = "好友列表" }
), {
    float = true,
})
