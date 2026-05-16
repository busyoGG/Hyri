local M = {}

local cursor_pos

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

function M.change_workspace(prev)
    local cur = hl.get_active_workspace()
    local mon_workspaces, i = get_workspaces_by_monitor(cur)

    if prev then
        if i > 1 then
            hl.dispatch(hl.dsp.focus({ workspace = mon_workspaces[i - 1] }))
        end
    else
        if cur.windows > 0 then
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
end

function M.move_window_to_workspace(prev)
    local cur = hl.get_active_workspace()
    local mon_workspaces, i = get_workspaces_by_monitor(cur)

    if prev then
        if i > 1 then
            hl.dispatch(hl.dsp.window.move({ workspace = mon_workspaces[i - 1] }))
        end
    else
        if cur.windows > 1 then
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
end

function M.window_on_put()
    local cursor_pos = hl.get_cursor_pos()
    local active_window = hl.get_active_window()

    local bound = { active_window.at.x + active_window.size.x * 0.25, active_window.at.x + active_window.size.x * 0.75 }

    if cursor_pos.x < bound[1] then
        hl.dispatch(hl.dsp.layout("promote"))
        hl.dispatch(hl.dsp.layout("swapcol l"))
    elseif cursor_pos.x > bound[2] then
        hl.dispatch(hl.dsp.layout("promote"))
    end
end

local width_for_windows = {}
local max_width_timer
function M.max_width()
    local cur = hl.get_active_window()
    if width_for_windows[cur.pid] then
        if max_width_timer then
            max_width_timer:set_enabled(false)
            max_width_timer = nil
            hl.dispatch(hl.dsp.window.resize({ x = width_for_windows[cur.pid], y = cur.size.y, window = cur }))

            hl.dispatch(hl.dsp.layout("colresize 1.0"))
        else
            local step = (cur.size.x - width_for_windows[cur.pid]) / 20
            max_width_timer = hl.timer(
                function()
                    hl.dispatch(hl.dsp.window.resize({ x = cur.size.x - step, y = cur.size.y, window = cur }))
                end, { timeout = 10, type = "repeat" })

            max_width_timer:set_enabled(true)

            hl.timer(
                function()
                    max_width_timer:set_enabled(false)
                    max_width_timer = nil
                    hl.dispatch(hl.dsp.window.resize({ x = width_for_windows[cur.pid], y = cur.size.y, window = cur }))
                    width_for_windows[cur.pid] = nil
                end, { timeout = 200, type = "oneshot" })
        end
    else
        width_for_windows[cur.pid] = cur.size.x
        hl.dispatch(hl.dsp.layout("colresize 1.0"))
    end
end

function M.drag_to_move()
    hl.exec_cmd("notify-send 'Drag to move' --expire-time=1000")
end

return M
