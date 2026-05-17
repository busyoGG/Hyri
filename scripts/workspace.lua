local M = {}

local cursor_pos

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

local ratio_for_windows = {}

function M.window_on_drag()
    local active_window = hl.get_active_window()
    local ratio = get_width_ratio(active_window)
    ratio_for_windows[active_window.pid] = ratio

    hl.dispatch(hl.dsp.window.drag())
end

function M.window_on_put()
    local cursor_pos = hl.get_cursor_pos()
    local active_window = hl.get_active_window()
    local ratio = ratio_for_windows[active_window.pid]

    local bound = { active_window.at.x + active_window.size.x * 0.25, active_window.at.x + active_window.size.x * 0.75 }

    if cursor_pos.x < bound[1] then
        hl.dispatch(hl.dsp.layout("promote"))
        hl.dispatch(hl.dsp.layout("swapcol l"))
    elseif cursor_pos.x > bound[2] then
        hl.dispatch(hl.dsp.layout("promote"))
    end

    hl.dispatch(hl.dsp.layout("colresize " .. ratio))
end

local width_for_windows = {}
function M.max_width()
    local cur = hl.get_active_window()
    if width_for_windows[cur.pid] then
        hl.dispatch(hl.dsp.layout("colresize " .. width_for_windows[cur.pid]))
        width_for_windows[cur.pid] = nil
    else
        local cur_ratio = get_width_ratio(cur)

        width_for_windows[cur.pid] = cur_ratio
        if cur_ratio == 1.0 then
            hl.dispatch(hl.dsp.layout("colresize 0.5"))
        else
            hl.dispatch(hl.dsp.layout("colresize 1.0"))
        end
    end
end

function M.drag_to_move()
    hl.exec_cmd("notify-send 'Drag to move' --expire-time=1000")
end

-- function M.on_window_open()
--     hl.on("window.open", function(w)
--         local workspace = hl.get_active_workspace()
--         if workspace.windows <= 1 then
--             M.max_width()
--         end
--     end)
-- end

return M
