-- Make my life easier..
_G.defaults = require("config.defaults")
_G.colors = require("config.highlights").colors
_G.ev = require("helpers.event")
_G.hl = require("config.highlights")
_G.keys = require("helpers.keys")
_G.notify = require("helpers.notify")

local M = {}

---@return string
M.location = function()
    ---@type debuginfo
    local me = debug.getinfo(1, "S")
    local level = 2

    ---@type debuginfo
    local info = debug.getinfo(level, "S")

    while info and (info.source == me.source or info.source == "@" .. vim.env.MYVIMRC or info.what ~= "Lua") do
        level = level + 1
        info = debug.getinfo(level, "S")
    end

    info = info or me

    local source = info.source:sub(2)

    source = vim.uv.fs_realpath(source) or source

    return source .. ":" .. info.linedefined
end

---@param value any
---@param opts? {location:string, bt?:boolean}
M.dump = function(value, opts)
    opts = opts or {}
    opts.location = opts.location or M.location()

    if vim.in_fast_event() then
        return vim.schedule(function()
            M.dump(value, opts)
        end)
    end

    opts.location = vim.fn.fnamemodify(opts.location, ":~:.")

    local msg = opts.location .. "\n\n" .. vim.inspect(value)

    if opts.bt then
        msg = msg .. "\n" .. debug.traceback("", 2)
    end

    notify.info(msg, {
        title = "Debug: ",
        icon = "",
        on_open = function(win)
            vim.wo[win].conceallevel = 3
            vim.wo[win].concealcursor = ""
            vim.wo[win].spell = false

            local buf = vim.api.nvim_win_get_buf(win)

            if not pcall(vim.treesitter.start, buf, "lua") then
                vim.bo[buf].filetype = "lua"
            end
        end,
    })
end

--- Global debug function
_G.dbg = function(...)
    ---@type any
    local value = { ... }

    if vim.tbl_isempty(value) then
        value = nil
    else
        value = vim.islist(value) and vim.tbl_count(value) <= 1 and value[1] or value
    end

    M.dump(value)
end

--- Global backtrace function
_G.bt = function(...)
    ---@type any
    local value = { ... }

    if vim.tbl_isempty(value) then
        value = nil
    else
        value = vim.islist(value) and vim.tbl_count(value) <= 1 and value[1] or value
    end

    M.dump(value, { bt = true })
end

--- Create a namespace.
--- @param name string The name of the namespace.
_G.ns = function(name)
    return vim.api.nvim_create_namespace("dsully/" .. name)
end

-- Handling to open GitHub partial URLs: organization/repository
local open = vim.ui.open

---@param uri string
vim.ui.open = function(uri) ---@diagnostic disable-line: duplicate-set-field
    --
    if not string.match(uri, "[a-z]*://[^ >,;]*") and string.match(uri, "[%w%p\\-]*/[%w%p\\-]*") then
        uri = string.format("https://github.com/%s", uri)
    end

    open(uri)
end
