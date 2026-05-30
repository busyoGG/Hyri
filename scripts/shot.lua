local shot = {}

local TPATH = "/tmp"

local function delay(func, delay)
    local demoTimer = hl.timer(function()
        func()
    end, { timeout = delay, type = "oneshot" })

    demoTimer:set_enabled(true)
end

local function get_screenshot_path()
    local filename = "screenshot-" .. os.date("%Y-%m-%d_%H-%M-%S") .. ".png"
    local path = TPATH .. "/" .. filename
    return path
end

local function set_mark()
    local cmd = string.format("echo -n 'file://%s' | wl-copy -t text/uri-list", get_screenshot_path())
    -- hl.exec_cmd("notify-send 'Screenshot taken' 'Saved to " .. cmd .. "'")
    hl.exec_cmd(cmd)

    local FLAG_FILE = '/tmp/screenshot-path'
    local SCALE = hl.get_active_monitor().scale

    hl.exec_cmd("echo " .. get_screenshot_path() .. " " .. SCALE .. " > " .. FLAG_FILE)
end

local function shot_without_dynamic_cursor(cmd)
    hl.config { plugin = { dynamic_cursors = { enabled = false } } }
    local pos = hl.get_cursor_pos()
    hl.dispatch(hl.dsp.cursor.move(pos))

    hl.exec_cmd(cmd)
    set_mark()

    delay(function()
        hl.config { plugin = { dynamic_cursors = { enabled = true } } }
    end, 50)
end

function shot.pick_window()
    hl.notification.create({
        text = "鼠标左键选择窗口截图，右键退出",
        timeout = 2000,
        color = "#ffffff"
    })

    hl.bind(
        "mouse:273",
        function()
            hl.unbind("mouse:272")
            hl.unbind("mouse:273")
        end
    )

    hl.bind(
        "mouse:272",
        function()
            local cur_window = hl.get_active_window()
            local border = hl.get_config("general.border_size")
            -- hl.exec_cmd("notify-send 'Screenshot' 'x,y " .. cur_window.size.x .. "'")
            local cmd = string.format(
                "grim -l 2 -g '%d,%d %dx%d' %s",
                cur_window.at.x - border,
                cur_window.at.y - border,
                cur_window.size.x + border * 2,
                cur_window.size.y + border * 2,
                get_screenshot_path()
            )
            -- hl.exec_cmd("notify-send 'Screenshot' 'cmd = " .. cmd .. "'")
            delay(function()
                shot_without_dynamic_cursor(cmd)
            end, 100)
            hl.unbind("mouse:272")
            hl.unbind("mouse:273")
        end
    )
end

function shot.active_shot()
    local window = hl.get_active_window()
    local pos = window.at
    local size = window.size

    local cmd = string.format(
        "grim -l 2 -g '%d,%d %dx%d' %s",
        pos.x,
        pos.y,
        size.x,
        size.y,
        get_screenshot_path()
    )

    shot_without_dynamic_cursor(cmd)
end

function shot.area_shot()
    local after_freeze_cmd = {
        "grim",
        "-l 2",
        [[-g "$(slurp)"]],
        get_screenshot_path() .. ";",
        "killall wayfreeze",
    }

    local cmd = table.concat({
        "wayfreeze",
        "--enable-keyboard",
        "--hide-cursor",
        "--after-freeze-cmd",
        string.format("'%s'", table.concat(after_freeze_cmd, " ")),
    }, " ")

    shot_without_dynamic_cursor(cmd)
end

function shot.screen_shot(all)
    local cmd

    if all then
        cmd = string.format("grim %s", get_screenshot_path())
    else
        cmd = string.format(
            "grim -l 2 -o %s %s",
            hl.get_active_monitor().name,
            get_screenshot_path()
        )
    end

    shot_without_dynamic_cursor(cmd)
end

function shot.edit(font_family)
    local flag_file = "/tmp/screenshot-path"

    local file = io.open(flag_file, "r")
    if file then
        local content = file:read("*l")
        file:close()


        if content then
            local screenshot_path, scale = content:match("^(%S+)%s+(%S+)$")
            if screenshot_path and scale then
                local function file_stat(path, format)
                    local handle = io.popen(string.format("stat -c%%%s '%s'", format, path))
                    if not handle then
                        return nil
                    end

                    local result = handle:read("*a")
                    handle:close()

                    return tonumber(result)
                end

                local original_size = 0
                local original_mtime = 0

                local test = io.open(screenshot_path, "r")
                if test then
                    test:close()
                    original_size = file_stat(screenshot_path, "s") or 0
                    original_mtime = file_stat(screenshot_path, "Y") or 0
                end

                local cmd = string.format(
                    'satty ' ..
                    '--no-window-decoration ' ..
                    '--disable-notifications ' ..
                    '--action-on-enter save-to-file ' ..
                    '--early-exit ' ..
                    '--initial-tool rectangle ' ..
                    '--profile-startup ' ..
                    '--input-scale %s ' ..
                    '--font-family "%s" ' ..
                    "-f '%s' -o '%s'",
                    scale,
                    font_family,
                    screenshot_path,
                    screenshot_path
                )
                hl.exec_cmd(cmd)

                local copy_cmd = string.format(
                    [[echo -n "file://%s" | wl-copy -t text/uri-list]],
                    screenshot_path
                )

                -- hl.exec_cmd("notify-send 'Screenshot edited' 'Saved to " .. screenshot_path .. "'")
                hl.exec_cmd(copy_cmd)
            end
        end
    end
end

return shot
