local shot = {}

local TPATH = "/tmp"

local FILENAME = "screenshot-" .. os.date("%Y-%m-%d_%H-%M-%S") .. ".png"

local SCREENSHOT_PATH = TPATH .. "/" .. FILENAME

local function update_filename()
    FILENAME = "screenshot-" .. os.date("%Y-%m-%d_%H-%M-%S") .. ".png"
    SCREENSHOT_PATH = TPATH .. "/" .. FILENAME
end

local function set_mark()
    local cmd = string.format("echo -n 'file://%s' | wl-copy -t text/uri-list", SCREENSHOT_PATH)
    -- hl.exec_cmd("notify-send 'Screenshot taken' 'Saved to " .. cmd .. "'")
    hl.exec_cmd(cmd)

    local FLAG_FILE = '/tmp/screenshot-path'
    local SCALE = hl.get_active_monitor().scale

    hl.exec_cmd("echo " .. SCREENSHOT_PATH .. " " .. SCALE .. " > " .. FLAG_FILE)
end

function shot.active_shot()
    update_filename()
    local window = hl.get_active_window()
    local pos = window.at
    local size = window.size

    local cmd = string.format(
        "grim -l 2 -g '%d,%d %dx%d' %s",
        pos.x,
        pos.y,
        size.x,
        size.y,
        SCREENSHOT_PATH
    )

    hl.exec_cmd(cmd)
    set_mark()
end

function shot.area_shot()
    update_filename()
    local after_freeze_cmd = {
        "grim",
        "-l 2",
        [[-g "$(slurp)"]],
        SCREENSHOT_PATH .. ";",
        "killall wayfreeze",
    }

    local cmd = table.concat({
        "wayfreeze",
        "--enable-keyboard",
        "--hide-cursor",
        "--after-freeze-cmd",
        string.format("'%s'", table.concat(after_freeze_cmd, " ")),
    }, " ")

    hl.exec_cmd(cmd)
    set_mark()
end

function shot.screen_shot(all)
    update_filename()
    local cmd

    if all then
        cmd = string.format("grim %s", SCREENSHOT_PATH)
    else
        cmd = string.format(
            "grim -l 2 -o %s %s",
            hl.get_active_monitor().name,
            SCREENSHOT_PATH
        )
    end

    hl.exec_cmd(cmd)
    set_mark()
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
