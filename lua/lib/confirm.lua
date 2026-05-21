-- Local handling for unsaved-buffer confirmation.
--
-- cokeline routes its unsaved-buffer prompt through `vim.ui.select` (snacks),
-- which renders a broken/empty picker. Custom floating-window prompts don't
-- survive this config either: a blocking `getchar` float is never flushed while
-- noice owns rendering, and a focused async float is auto-closed by focus
-- changes. Neovim's native `confirm()` dialog renders reliably, so we use it for
-- the decision and let `mini.bufremove` perform the layout-preserving deletion
-- (with `force`, since we've already handled the unsaved changes).

local M = {}

---Delete a buffer, prompting to save when it has unsaved changes.
---@param bufnr integer?
function M.delete_buffer(bufnr)
    local target = (bufnr and bufnr ~= 0) and bufnr or vim.api.nvim_get_current_buf()
    local delete = require("mini.bufremove").delete

    if not vim.bo[target].modified then
        delete(target, true)
        return
    end

    local name = vim.api.nvim_buf_get_name(target)
    local label = name ~= "" and vim.fn.fnamemodify(name, ":~:.") or "[No Name]"

    local choice = vim.fn.confirm(string.format('Buffer "%s" has unsaved changes.', label), "&Save and close\n&Discard and close\n&Cancel", 3)

    if choice == 1 then
        if name == "" then
            vim.notify("Buffer has no name; save it manually first.", vim.log.levels.WARN)
            return
        end

        vim.api.nvim_buf_call(target, function()
            vim.cmd.write()
        end)

        delete(target, true)
    elseif choice == 2 then
        delete(target, true)
    end
end

return M
