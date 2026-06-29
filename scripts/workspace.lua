local M = {}

local cursor_pos

local windows_width = {}
local windows_states = {}

------------------------
---- local function ----
------------------------

local function get_width_ratio(cur)
    local mon = hl.get_monitor(cur.monitor)
    local gaps_out = hl.get_config("general.gaps_out")
    local border_size = hl.get_config("general.border_size")

    local max_width = mon.size.width / mon.scale - gaps_out.left * 2 - border_size * 2
    return cur.size.x / max_width
end

local function get_height_ratio(cur)
    local mon = hl.get_monitor(cur.monitor)
    local gaps_out = hl.get_config("general.gaps_out")
    local border_size = hl.get_config("general.border_size")

    local max_height = mon.height / mon.scale - gaps_out.top * 2 - border_size * 2 - mon.reserved.top
    return cur.size.y / max_height
end

local function get_workspaces_by_monitor(cur)
    local workspaces = hl.get_workspaces()
    local mon_workspaces = {}

    local i = 0

    for index, value in ipairs(workspaces) do
        if value.monitor == cur.monitor then
            table.insert(mon_workspaces, value)
            if value.id == cur.id then
                i = #mon_workspaces
            end
        end
    end
    return mon_workspaces, i
end

-------------------------
---- module function ----
-------------------------

function M.change_workspace(prev)
    local cur = hl.get_active_workspace()
    local mon_workspaces, i = get_workspaces_by_monitor(cur)

    if prev then
        if i > 1 then
            hl.dispatch(hl.dsp.focus({ workspace = mon_workspaces[i - 1] }))
        end
    else
        if prev then
            hl.dispatch(hl.dsp.focus({ workspace = 'm-1' }))
        else
            if i == #mon_workspaces then
                hl.dispatch(hl.dsp.focus({ workspace = 'r+1' }))
            else
                hl.dispatch(hl.dsp.focus({ workspace = mon_workspaces[i + 1] }))
            end
        end
    end
end

function M.move_window_to_workspace(prev)
    local cur = hl.get_active_workspace()
    local mon_workspaces, i = get_workspaces_by_monitor(cur)

    if prev then
        if i > 1 then
            hl.dispatch(hl.dsp.window.move({ workspace = mon_workspaces[i - 1] }))
        end
    else
        if prev then
            hl.dispatch(hl.dsp.window.move({ workspace = 'm-1' }))
        else
            if i == #mon_workspaces then
                hl.dispatch(hl.dsp.window.move({ workspace = 'r+1' }))
            else
                hl.dispatch(hl.dsp.window.move({ workspace = mon_workspaces[i + 1] }))
            end
        end
    end
end

function M.window_on_drag()
    -- hl.dispatch(hl.dsp.exec_cmd("notify-send 'active window ratio: " .. ratio_for_windows .. "' --expire-time=1000"))
    -- hl.exec_cmd("ydotool key 125:1")
    if windows_width[hl.get_active_window().pid] == nil then
        M.update_window_width(hl.get_active_window())
        M.update_window_state(hl.get_active_window(), { max_width = windows_width[hl.get_active_window().pid] >= 1.0 })
    end
    hl.dispatch(hl.dsp.window.drag())
end

function M.window_on_put()
    -- hl.exec_cmd("ydotool key 125:0")
    -- local cursor_pos = hl.get_cursor_pos()
    local active_window = hl.get_active_window()

    ---- upstream fixed ----
    
    -- local bound = { active_window.at.x + active_window.size.x * 0.25, active_window.at.x + active_window.size.x * 0.75 }

    -- if cursor_pos.x < bound[1] then
    --     hl.dispatch(hl.dsp.layout("promote"))
    --     hl.dispatch(hl.dsp.layout("swapcol l"))
    -- elseif cursor_pos.x > bound[2] then
    --     hl.dispatch(hl.dsp.layout("promote"))
    -- end

    ---- upstream fixed ----

    if get_height_ratio(active_window) >= 1.0 then
        if windows_states[active_window.pid].max_width then
            hl.dispatch(hl.dsp.layout("colresize 1.0"))
        else
            hl.dispatch(hl.dsp.layout("colresize " .. windows_width[active_window.pid]))
        end
    end

    -- hl.dispatch(hl.dsp.exec_cmd("notify-send 'active window ratio: " .. ratio_for_windows .. "' --expire-time=1000"))
end

function M.max_width()
    local cur = hl.get_active_window()
    if windows_states[cur.pid].max_width then
        hl.dispatch(hl.dsp.layout("colresize " .. windows_width[cur.pid]))
        M.update_window_state(cur, { max_width = false })
    else
        hl.dispatch(hl.dsp.layout("colresize 1.0"))
        M.update_window_state(cur, { max_width = true })
    end
end

function M.drag_to_move()
    hl.exec_cmd("notify-send 'Drag to move' --expire-time=1000")
end

function M.resize_window_done()
    local cur = hl.get_active_window()
    M.update_window_width(cur)
    M.update_window_state(cur, { max_width = windows_width[cur.pid] >= 1.0 })
end

function M.on_window_open()
    hl.on("window.open", function(w)
        local start_as_full_width = M.update_window_width(w)
        M.update_window_state(w, { max_width = start_as_full_width and start_as_full_width or windows_width[w.pid] >= 1.0 })
    end)
end

-- Update the width of the window when it is opened
function M.update_window_width(w)
    local width = get_width_ratio(w)
    local start_as_full_width = false
    -- if max width is 1.0, set it to 0.5 to avoid issues with max_width function
    if width >= 1.0 then
        width = 0.5
        start_as_full_width = true
    end

    windows_width[w.pid] = width
    return start_as_full_width
end

function M.update_window_state(w, state)
    windows_states[w.pid] = state
end

return M
