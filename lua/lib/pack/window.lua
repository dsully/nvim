local state = require("lib.pack.state")

local M = {}

---@return integer?
function M.valid_window()
    if state.winid ~= nil and vim.api.nvim_win_is_valid(state.winid) then
        return state.winid
    end
end

---@return integer?
function M.valid_buffer()
    if state.bufnr ~= nil and vim.api.nvim_buf_is_valid(state.bufnr) then
        return state.bufnr
    end
end

---Return the plugin name on the line under the cursor, if any.
---@return string?
function M.plugin_at_cursor()
    local winid = M.valid_window()

    if not winid then
        return nil
    end

    local row = vim.api.nvim_win_get_cursor(winid)[1]

    return state.line_to_name[row]
end

return M
