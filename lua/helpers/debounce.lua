local M = {}

---@param ms integer
---@param fn function
function M.debounce(ms, fn)
    local timer = vim.uv.new_timer()
    return function(...)
        local argv = { ... }

        if timer ~= nil then
            timer:start(ms, 0, function()
                timer:stop()
                vim.schedule_wrap(fn)(unpack(argv))
            end)
        end
    end
end

return M
