---@class lib.keys
local M = {}

-- Wrapper around vim.keymap.set. Sets `silent` to true by default.
---@param lhs string
---@param rhs function|string
---@param mode string[]
---@param opts vim.keymap.set.Opts?
function M.safe_set(lhs, rhs, mode, opts)
    local modes = type(mode) == "string" and { mode } or mode
    local options = vim.deepcopy(opts or {}, true)

    options.silent = options.silent ~= false

    vim.keymap.set(modes, lhs, rhs, options)
end

---Create a global key mapping. Defaults to normal mode.
---@param lhs string
---@param rhs function|string
---@param desc string?
---@param mode string|string[]|nil
---@param opts vim.keymap.set.Opts?
function M.map(lhs, rhs, desc, mode, opts)
    --
    if type(mode) == "string" then
        mode = { mode } --[[@as string[] ]]
    end

    M.safe_set(
        lhs,
        rhs,
        mode or { "n" },
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
---@param mode string|string[]|nil
---@param opts vim.keymap.set.Opts?
function M.bmap(lhs, rhs, desc, buffer, mode, opts)
    --
    M.map(lhs, rhs, desc, mode, vim.tbl_deep_extend("force", opts or {}, { buffer = buffer or true }))
end

---Create a global key mapping in v mode.
---@param lhs string
---@param rhs function|string
---@param desc string?
---@param buffer integer?
---@param opts vim.keymap.set.Opts?
function M.vmap(lhs, rhs, desc, buffer, opts)
    --
    M.safe_set(
        lhs,
        rhs,
        { "v" },
        vim.tbl_deep_extend("force", {
            desc = desc or "Undocumented",
            noremap = true,
            silent = true,
        }, vim.tbl_deep_extend("force", opts or {}, { buffer = buffer or true }))
    )
end

---@param keymap string
---@param mode string
function M.feed(keymap, mode)
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keymap, true, false, true), mode, false)
end

--- Create an undo point in insert mode.
function M.create_undo()
    if vim.api.nvim_get_mode().mode == "i" then
        M.feed("<c-G>u", "n")
    end
end

return M
