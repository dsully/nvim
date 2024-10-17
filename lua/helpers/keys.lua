---@class helpers.keys
local M = {}

-- Wrapper around vim.keymap.set that will not create a keymap if a lazy.nvim key handler exists.
-- It will also set `silent` to true by default.
---@param lhs string
---@param rhs function|string
---@param mode table<string>
---@param opts table?
---@param override boolean?
function M.safe_set(lhs, rhs, mode, opts, override)
    local keys = require("lazy.core.handler").handlers.keys

    ---@cast keys LazyKeysHandler
    local modes = type(mode) == "string" and { mode } or mode

    ---@param m string
    modes = vim.tbl_filter(function(m)
        return not (keys.have and keys:have(lhs, m))
    end, modes)

    -- Do not create the keymap if a lazy keys handler exists
    if #modes > 0 or override then
        opts = opts or {}
        opts.silent = opts.silent ~= false

        if opts.remap and not vim.g.vscode then
            ---@diagnostic disable-next-line: no-unknown
            opts.remap = nil
        end

        vim.keymap.set(modes, lhs, rhs, opts)
    else
        notify.warn("Keymap already exists for " .. lhs .. " in: " .. (vim.fn.execute("map " .. lhs) or "?"))
    end
end

---Create a global key mapping. Defaults to normal mode.
---@param lhs string
---@param rhs function|string
---@param desc string?
---@param mode string|table<string>|nil
---@param opts table?
---@param override boolean?
function M.map(lhs, rhs, desc, mode, opts, override)
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
        }, opts or {}),
        override or false
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
    M.map(lhs, rhs, desc, mode, vim.tbl_deep_extend("force", opts or {}, { buffer = buffer or true }), true)
end

---@param keymap string
---@param mode string
M.feed = function(keymap, mode)
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keymap, true, false, true), mode, false)
end

-- Adapted from LazyVim
---@class keys.Toggle
---@field name string
---@field get fun():boolean
---@field set fun(state:boolean)

---@class keys.Toggle.wrap: keys.Toggle
---@operator call:boolean

M.toggle = {}

---@param toggle keys.Toggle
function M.toggle.wrap(toggle)
    --
    return setmetatable(toggle, {
        __call = function()
            toggle.set(not toggle.get())

            local state = toggle.get()

            if state then
                notify.info("Enabled " .. toggle.name, { title = toggle.name })
            else
                notify.warn("Disabled " .. toggle.name, { title = toggle.name })
            end

            return state
        end,
    }) --[[@as keys.Toggle.wrap]]
end

---@param lhs string
---@param toggle keys.Toggle
function M.toggle.map(lhs, toggle)
    local t = M.toggle.wrap(toggle)

    M.map(lhs, function()
        t()
    end, "Toggle " .. toggle.name)

    M.toggle.wk(lhs, toggle)
end

function M.toggle.wk(lhs, toggle)
    local function safe_get()
        local ok, enabled = pcall(toggle.get)

        if not ok then
            notify.error("Failed to get toggle state for **" .. toggle.name .. "**:\n" .. enabled, { once = true })
        end

        return enabled
    end

    require("which-key").add({
        {
            lhs,
            icon = function()
                return safe_get() and { icon = " ", color = "green" } or { icon = " ", color = "yellow" }
            end,
            desc = function()
                return (safe_get() and "Disable " or "Enable ") .. toggle.name
            end,
        },
    })
end

M.toggle.diagnostics = M.toggle.wrap({
    name = "Diagnostics",
    get = function()
        return vim.diagnostic.is_enabled and vim.diagnostic.is_enabled()
    end,
    set = vim.diagnostic.enable,
})

M.toggle.inlay_hints = M.toggle.wrap({
    name = "Inlay Hints",
    get = function()
        return vim.lsp.inlay_hint.is_enabled({ bufnr = 0 })
    end,
    set = function(state)
        vim.lsp.inlay_hint.enable(state, { bufnr = 0 })
    end,
})

M.toggle.spelling = M.toggle.wrap({
    name = "Spelling",
    get = function()
        return vim.o.spell
    end,
    set = function()
        vim.opt.spelloptions = { "camel", "noplainbuffer" }
        vim.opt.spell = true
    end,
})

M.toggle.treesitter = M.toggle.wrap({
    name = "Treesitter Highlight",
    get = function()
        return vim.b.ts_highlight
    end,
    set = function(state)
        if state then
            vim.treesitter.start()
        else
            vim.treesitter.stop()
        end
    end,
})

---@param opts? {values?: {[1]:any, [2]:any}, name?: string}
M.toggle.option = function(option, opts)
    opts = opts or {}

    local name = opts.name or option
    local on = opts.values and opts.values[2] or true
    local off = opts.values and opts.values[1] or false

    return M.toggle.wrap({
        name = name,
        get = function()
            return vim.opt_local[option]:get() == on
        end,
        set = function(state)
            vim.opt_local[option] = state and on or off
        end,
    })
end

-- Allow calling: keys.toggle.map(lhs, keys.toggle(<opt>, { name = "" }))
-- Where <opt> is a vim.opt
setmetatable(M.toggle, {
    __call = function(m, ...)
        return m.option(...)
    end,
})

return M
