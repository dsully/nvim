---@class helpers.keys
local M = {}

-- Wrapper around vim.keymap.set that will not create a keymap if a lazy.nvim key handler exists.
-- It will also set `silent` to true by default.
---@param lhs string
---@param rhs function|string
---@param mode table<string>
---@param opts table?
function M.safe_set(lhs, rhs, mode, opts)
    local keys = require("lazy.core.handler").handlers.keys

    ---@cast keys LazyKeysHandler
    local modes = type(mode) == "string" and { mode } or mode

    ---@param m string
    modes = vim.tbl_filter(function(m)
        return not (keys.have and keys:have(lhs, m))
    end, modes)

    opts = opts or {}

    -- Do not create the keymap if a lazy keys handler exists
    -- But allow for buffer-local keymaps.
    if #modes > 0 or opts and opts.buffer ~= nil then
        opts.silent = opts.silent ~= false

        if opts.remap and not vim.g.vscode then
            opts.remap = nil
        end

        vim.keymap.set(modes, lhs, rhs, opts)
    else
        vim.notify("Keymap already exists for " .. lhs .. " in: " .. (vim.fn.execute("map " .. lhs) or "?"), vim.log.levels.WARN)
    end
end

---Create a global key mapping. Defaults to normal mode.
---@param lhs string
---@param rhs function|string
---@param desc string?
---@param mode string|table<string>|nil
---@param opts table?
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
---@param mode string|table<string>|nil
---@param opts table?
function M.bmap(lhs, rhs, desc, buffer, mode, opts)
    --
    M.map(lhs, rhs, desc, mode, vim.tbl_deep_extend("force", opts or {}, { buffer = buffer or true }))
end

---Create a global key mapping in x/v mode.
---@param lhs string
---@param rhs function|string
---@param desc string?
---@param buffer integer?
---@param opts table?
function M.xmap(lhs, rhs, desc, buffer, opts)
    --
    M.safe_set(
        lhs,
        rhs,
        { "x" },
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

return M
