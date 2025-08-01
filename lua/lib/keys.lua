---@class lib.keys
local M = {}

-- Wrapper around vim.keymap.set that will not create a keymap if a lazy.nvim key handler exists.
-- It will also set `silent` to true by default.
---@param lhs string
---@param rhs function|string
---@param mode string[]
---@param opts vim.keymap.set.Opts?
function M.safe_set(lhs, rhs, mode, opts)
    local lazy_keys = require("lazy.core.handler").handlers.keys or {}

    ---@cast lazy_keys LazyKeysHandler
    local modes = type(mode) == "string" and { mode } or mode

    ---@param m string
    modes = vim.tbl_filter(function(m)
        return not (lazy_keys.have and lazy_keys:have(lhs, m))
    end, modes --[[@as table<any,string>]])

    opts = opts or {}

    -- Do not create the keymap if a lazy keys handler exists
    -- But allow for buffer-local keymaps.
    if #modes > 0 or opts and opts.buffer ~= nil then
        opts.silent = opts.silent ~= false

        vim.keymap.set(modes, lhs, rhs, opts)
    else
        vim.notify("Keymap already exists for " .. lhs .. " in: " .. (vim.fn.execute("map " .. lhs) or "?"), vim.log.levels.ERROR)
    end
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
        mode = { mode }
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
M.feed = function(keymap, mode)
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keymap, true, false, true), mode, false)
end

--- Create an undo point in insert mode.
M.create_undo = function()
    if vim.api.nvim_get_mode().mode == "i" then
        M.feed("<c-G>u", "n")
    end
end

return M
