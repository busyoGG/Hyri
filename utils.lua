local M = {}

function M.dump_table(t)
    local s = ""
    for k, v in pairs(t) do
        s = s .. tostring(k) .. "=" .. tostring(v) .. " "
    end
    return s
end

return M
