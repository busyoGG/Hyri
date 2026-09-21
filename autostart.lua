hl.on("hyprland.start", function()
    -- Exec("xwayland-satellite &")
    -- Exec(
    --     "xprop -root -f _XWAYLAND_GLOBAL_OUTPUT_SCALE 32c -set _XWAYLAND_GLOBAL_OUTPUT_SCALE 2000")
    Exec("hyprpm reload")
    Exec("hyprctl reload")
    Exec("xprop -root -format _XWAYLAND_GLOBAL_OUTPUT_SCALE 32c -set _XWAYLAND_GLOBAL_OUTPUT_SCALE 2")
    Exec("echo \"Xft.dpi: 192\" | xrdb -merge")

    Exec("/home/busyo/.config/hypr/scripts/import-kde-portal-env.sh")
    Exec("wl-paste --watch cliphist store &")
    Exec("usr/lib/pam_kwallet_init")
    Exec("/usr/bin/kwalletd6")
    Exec("dsearch serve")
    Exec("/home/busyo/.config/hypr/scripts/clipboard_sync.sh")
    Exec("kdeconnect-indicator")
    Exec("fcitx5-follow")
    -- Exec("awww-daemon")
    Exec("rslsync")
    Exec("/home/busyo/文档/EnhanceScript/QQWatcher.sh")
    Exec(
        "/usr/bin/python3 /home/busyo/文档/EnhanceScript/replay_watcher.py >> /home/busyo/replay.log 2>&1 </dev/null")
    -- Exec("nohup xwayland-satellite > /dev/null 2>&1 &")
    Exec(
    "KIMI_CODE_EXPERIMENTAL_SECONDARY_MODEL=1 kimi web --host 0.0.0.0 --port 58627 --no-open --allowed-host 192.168.1.215 --allowed-host steamdeck --allowed-host steamdeck.tailaa0080.ts.net </dev/null >/home/busyo/Dev/nginx/pswd 2>&1 &")
    -- Exec("dsh web")
    Exec("/home/busyo/.kimi-code/openviking-venv/bin/openviking-server",1)

    -- apps
    -- Exec("dms run", 1)
    Exec("noctalia", 1)
    Exec("gtk-launch sparkle", 6)
    
    Exec("XCURSOR_SIZE=64 gtk-launch steam", 7)
    -- Exec("gtk-launch com.follow.clash", 5)
    Exec("gtk-launch discord", 7)
    Exec("gtk-launch qq", 7)
    Exec("gtk-launch org.telegram.desktop.desktop", 7)
    Exec("gtk-launch io.element.Element", 7)
    Exec("gtk-launch vivaldi-stable", 7)
    Exec("gtk-launch org.qbittorrent.qBittorrent", 7)
end)

function Exec(cmd, delay)
    local full_cmd = "sleep " .. (delay or 0) .. "; " .. cmd
    hl.exec_cmd(full_cmd)
end
