local M = {}

---@param buffer integer
---@param mode string|table
---@param lhs string
---@param rhs function|string
---@param opts table|nil
function M.bmap(buffer, mode, lhs, rhs, opts)
    --
    vim.keymap.set(
        mode,
        lhs,
        rhs,
        vim.tbl_deep_extend("force", {
            buffer = buffer,
            desc = "Undocumented",
            noremap = true,
            silent = true,
        }, opts)
    )
end

return M
