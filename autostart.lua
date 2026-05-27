hl.on("hyprland.start", function()
    -- Exec("xwayland-satellite &")
    -- Exec(
    --     "xprop -root -f _XWAYLAND_GLOBAL_OUTPUT_SCALE 32c -set _XWAYLAND_GLOBAL_OUTPUT_SCALE 2000")
    Exec("hyprpm reload")
    Exec("xprop -root -format _XWAYLAND_GLOBAL_OUTPUT_SCALE 32c -set _XWAYLAND_GLOBAL_OUTPUT_SCALE 2")
    Exec("echo \"Xft.dpi: 192\" | xrdb -merge")

    Exec("/home/busyo/.config/hypr/scripts/import-kde-portal-env.sh")
    Exec("wl-paste --watch cliphist store &")
    Exec("usr/lib/pam_kwallet_init")
    Exec("/usr/bin/kwalletd6")
    Exec("dsearch serve")
    Exec("/home/busyo/.config/hypr/scripts/clipboard_sync.sh")
    Exec("kdeconnect-indicator")
    -- Exec("awww-daemon")
    Exec("rslsync")
    Exec("/home/busyo/文档/EnhanceScript/QQWatcher.sh")
    Exec(
        "/usr/bin/python3 /home/busyo/文档/EnhanceScript/replay_watcher.py >> /home/busyo/replay.log 2>&1 </dev/null")
    -- Exec("nohup xwayland-satellite > /dev/null 2>&1 &")

    -- apps
    Exec("dms run", 2)
    Exec("XCURSOR_SIZE=64 gtk-launch steam", 5)
    Exec("gtk-launch discord", 5)
    Exec("gtk-launch qq", 5)
    Exec("gtk-launch org.telegram.desktop.desktop", 5)
    Exec("gtk-launch io.element.Element", 5)
    Exec("gtk-launch vivaldi-stable", 5)
    Exec("gtk-launch org.qbittorrent.qBittorrent", 5)
end)

function Exec(cmd, delay)
    local full_cmd = "sleep " .. (delay or 0) .. "; " .. cmd
    hl.exec_cmd(full_cmd)
end

-- hl.on("hyprland.start", function()
--     -- hl.exec_cmd("xwayland-satellite &")
--     -- hl.exec_cmd(
--     --     "xprop -root -f _XWAYLAND_GLOBAL_OUTPUT_SCALE 32c -set _XWAYLAND_GLOBAL_OUTPUT_SCALE 2000")
--     hl.exec_cmd("xprop -root -format _XWAYLAND_GLOBAL_OUTPUT_SCALE 32c -set _XWAYLAND_GLOBAL_OUTPUT_SCALE 2")
--     hl.exec_cmd("echo \"Xft.dpi: 192\" | xrdb -merge")

--     hl.exec_cmd("/home/busyo/.config/hypr/scripts/import-kde-portal-env.sh")
--     hl.exec_cmd("wl-paste --watch cliphist store &")
--     hl.exec_cmd("usr/lib/pam_kwallet_init")
--     hl.exec_cmd("/usr/bin/kwalletd6")
--     hl.exec_cmd("dsearch serve")
--     hl.exec_cmd("/home/busyo/.config/hypr/scripts/clipboard_sync.sh")
--     hl.exec_cmd("kdeconnect-indicator")
--     -- hl.exec_cmd("awww-daemon")
--     hl.exec_cmd("rslsync")
--     hl.exec_cmd("/home/busyo/文档/EnhanceScript/QQWatcher.sh")
--     hl.exec_cmd(
--         "/usr/bin/python3 /home/busyo/文档/EnhanceScript/replay_watcher.py >> /home/busyo/replay.log 2>&1 </dev/null")
--     -- hl.exec_cmd("nohup xwayland-satellite > /dev/null 2>&1 &")

--     -- apps
--     hl.exec_cmd("dms run")
--     hl.exec_cmd("sleep 5;gtk-launch steam")
--     hl.exec_cmd("sleep 5;gtk-launch discord")
--     hl.exec_cmd("sleep 5;gtk-launch qq")
--     hl.exec_cmd("sleep 5;gtk-launch org.telegram.desktop.desktop")
--     hl.exec_cmd("sleep 5;gtk-launch io.element.Element")
--     hl.exec_cmd("sleep 5;gtk-launch vivaldi-stable")
--     hl.exec_cmd("sleep 5;gtk-launch org.qbittorrent.qBittorrent")
-- end)
