local shot = require("scripts.shot")
local workspace = require("scripts.workspace")

---------------------
---- KEYBINDINGS ----
---------------------

local mainMod = "SUPER" -- Sets "Windows" key as main modifier
local mainAlt = "ALT"
local mainCtrl = "CTRL"

-- Example binds, see https://wiki.hypr.land/Configuring/Basics/Binds/ for more

-- general
hl.bind(mainCtrl .. " + Q", hl.dsp.exec_cmd("ghostty"))
hl.bind(mainAlt .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + M",
    hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"))
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))

-- controls
hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))

hl.bind(mainMod .. " + mouse_down", hl.dsp.layout("focus l"))
hl.bind(mainMod .. " + mouse_up", hl.dsp.layout("focus r"))

hl.bind(mainAlt .. " + mouse_down", function()
    workspace.change_workspace(true)
end)
hl.bind(mainAlt .. " + mouse_up", function()
    workspace.change_workspace(false)
end)

hl.bind(mainCtrl .. " + " .. mainMod .. " + mouse_down", hl.dsp.layout("swapcol l"))
hl.bind(mainCtrl .. " + " .. mainMod .. " + mouse_up", hl.dsp.layout("swapcol r"))

hl.bind(mainCtrl .. " + " .. mainAlt .. " + mouse_down", function()
    workspace.move_window_to_workspace(true)
end)
hl.bind(mainCtrl .. " + " .. mainAlt .. " + mouse_up", function()
    workspace.move_window_to_workspace(false)
end)

-- Switch workspaces with mainMod + [0-9]
-- Move active window to a workspace with mainMod + SHIFT + [0-9]
for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

hl.bind(mainMod .. " + mouse:272", workspace.window_on_put, { release = true })

-- Laptop multimedia keys for volume and LCD brightness
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),
    { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
    { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
    { locked = true, repeating = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
    { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), { locked = true, repeating = true })

-- Requires playerctl
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })


-- change IM
hl.bind(mainCtrl .. " + space", hl.dsp.exec_cmd("~/文档/EnhanceScript/fcitx5-input-switcher.sh"))

-- dms
hl.bind(mainAlt .. " + space", hl.dsp.exec_cmd("dms ipc call spotlight toggle"))
hl.bind("XF86Calculator", hl.dsp.exec_cmd("dms ipc call notepad toggle"))

-- shot
hl.bind("print", function()
    shot.screen_shot(false)
end)
hl.bind(mainCtrl .. " + print", function()
    shot.screen_shot(true)
end)
hl.bind(mainCtrl .. " + " .. mainAlt .. " + A", shot.area_shot)
hl.bind(mainAlt .. " + print", shot.active_shot)

hl.bind(mainMod .. " + E", function()
    shot.edit("方正FW筑紫A圆 简 E")
end)


-- ocr
hl.bind(mainAlt .. " + 1", hl.dsp.exec_cmd("~/.config/hypr/scripts/shot/ocr.sh"))
hl.bind(mainAlt .. " + 2", hl.dsp.exec_cmd("~/.config/hypr/scripts/shot/qrcode.sh"))

-- test
hl.bind(mainAlt .. " + 3", function()
    local window = hl.get_active_window()
    hl.exec_cmd("notify-send 'Active Window Info' 'Class: " ..
        (window.class or "N/A") .. "\nTitle: " .. (window.title or "N/A") .. "'")
end)
