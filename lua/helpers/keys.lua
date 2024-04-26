local M = {}

---Create a global key mapping. Defaults to normal mode.
---@param lhs string
---@param rhs function|string
---@param desc string?
---@param mode string?|table?
---@param opts table?
function M.map(lhs, rhs, desc, mode, opts)
    --
    vim.keymap.set(
        mode or "n",
        lhs,
        rhs,
        vim.tbl_deep_extend("force", {
            desc = desc or "Undocumented",
            noremap = true,
            silent = true,
        }, opts or {})
    )
end

---Create a buffer-local key mapping. Defaults to normal mode.
---@param lhs string
---@param rhs function|string
---@param desc string?
---@param buffer integer?
---@param mode string?|table?
---@param opts table?
function M.bmap(lhs, rhs, desc, buffer, mode, opts)
    --
    M.map(lhs, rhs, desc, mode, vim.tbl_deep_extend("force", opts or {}, { buffer = buffer or true }))
end

return M
