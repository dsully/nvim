-- Persist the tabline's buffer display order across sessions.
local M = {}

M.on_save = function()
    return { order = require("lib.tabline").snapshot() }
end

M.on_post_load = function(data)
    if data then
        require("lib.tabline").set_order(data.order)
    end
end

return M
