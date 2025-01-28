-- Make my life easier..
_G.defaults = require("config.defaults")
_G.colors = require("config.highlights").colors
_G.ev = require("helpers.event")
_G.hl = require("helpers.highlights")
_G.keys = require("helpers.keys")

_G.lazy = {
    ---@param name string
    ---@return table
    opts = function(name)
        local plugin = require("lazy.core.config").spec.plugins[name]

        if not plugin then
            return {}
        end

        return require("lazy.core.plugin").values(plugin, "opts", false)
    end,
}

_G.nvim = {
    file = require("helpers.file"),
    root = require("helpers.root"),
}

---Create a Neovim command
---@param name string
---@param rhs string|fun(args: vim.api.keyset.create_user_command.command_args)
---@param opts vim.api.keyset.user_command
_G.nvim.command = function(name, rhs, opts)
    vim.api.nvim_create_user_command(name, rhs, opts or {})
end

--- Create a namespace.
--- @param name string The name of the namespace.
_G.nvim.ns = function(name)
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
