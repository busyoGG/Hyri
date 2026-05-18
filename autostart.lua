hl.on("hyprland.start", function()
    hl.exec_cmd("xwayland-satellite &")
    hl.exec_cmd(
        "xprop -root -f _XWAYLAND_GLOBAL_OUTPUT_SCALE 32c -set _XWAYLAND_GLOBAL_OUTPUT_SCALE 2000")
    delay_run(5000, function()
        hl.exec_cmd("/home/busyo/.config/hypr/scripts/import-kde-portal-env.sh")
        hl.exec_cmd("wl-paste --watch cliphist store &")
        hl.exec_cmd("usr/lib/pam_kwallet_init")
        hl.exec_cmd("/usr/bin/kwalletd6")
        hl.exec_cmd("dms run")
        hl.exec_cmd("dsearch serve")
        hl.exec_cmd("/home/busyo/.config/hypr/scripts/clipboard_sync.sh")
        hl.exec_cmd("kdeconnect-indicator")
        -- hl.exec_cmd("awww-daemon")
        hl.exec_cmd("rslsync")
        hl.exec_cmd("/home/busyo/文档/EnhanceScript/QQWatcher.sh")
        hl.exec_cmd(
            "/usr/bin/python3 /home/busyo/文档/EnhanceScript/replay_watcher.py >> /home/busyo/replay.log 2>&1 </dev/null")
        -- hl.exec_cmd("nohup xwayland-satellite > /dev/null 2>&1 &")

        -- apps
        hl.exec_cmd("gtk-launch steam")
        hl.exec_cmd("gtk-launch discord")
        hl.exec_cmd("gtk-launch qq")
        hl.exec_cmd("gtk-launch org.telegram.desktop.desktop")
        hl.exec_cmd("gtk-launch io.element.Element")
        hl.exec_cmd("gtk-launch vivaldi-stable")
        hl.exec_cmd("gtk-launch org.qbittorrent.qBittorrent")
    end)
end)

function delay_run(delay, func)
    local demoTimer = hl.timer(function()
        -- hl.exec_cmd(cmd)
        func()
    end, { timeout = delay, type = "oneshot" })

    demoTimer:set_enabled(true)
end
