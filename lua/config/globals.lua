-- Make my life easier..
_G.defaults = require("config.defaults")
_G.colors = require("config.highlights").colors
_G.ev = require("helpers.event")
_G.hl = require("helpers.highlights")
_G.keys = require("helpers.keys")

--- Create a namespace.
--- @param name string The name of the namespace.
_G.ns = function(name)
    return vim.api.nvim_create_namespace("dsully/" .. name)
end

--- Create a floating window using snacks.win
---@param options snacks.win.Config
---@param lines string[]
---@return snacks.win
vim.ui.float = function(options, lines)
    local snacks = require("snacks")

    ---@param self snacks.win
    local on_buf = function(self)
        vim.api.nvim_buf_set_lines(self.buf, 0, -1, false, lines)
    end

    return snacks.win.new(vim.tbl_deep_extend("force", defaults.ui.float or {}, options or {}, { on_buf = on_buf }))
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
