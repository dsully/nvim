-- Make my life easier..
_G.defaults = require("config.defaults")
_G.colors = require("config.highlights").colors
_G.ev = require("lib.event")
_G.hl = require("lib.highlights")
_G.keys = require("lib.keys")

_G.nvim = {
    buffer = require("lib.buffer"),
    file = require("lib.file"),
    lsp = require("lib.lsp"),
    root = require("lib.root"),
}

---Create a Neovim command
---@param name string
---@param rhs string|fun(args: vim.api.keyset.create_user_command.command_args)
---@param opts vim.api.keyset.user_command | table<string, string>
_G.nvim.command = function(name, rhs, opts)
    if not opts then
        opts = {}
    end

    vim.api.nvim_create_user_command(name, rhs, opts --[[@as vim.api.keyset.user_command]])
end

--- Create a namespace.
--- @param name string The name of the namespace.
_G.nvim.ns = function(name)
    return vim.api.nvim_create_namespace("dsully." .. name)
end

-- Set up vim.notify to use snacks notifier, falling back to the builtin while
-- snacks is not yet loaded (e.g. during early plugin installation at startup).
-- @param msg: string,
-- @paraam level: (snacks.notifier.level|number)?
-- @param opts: snacks.notifier.Notif.opts?
local builtin_notify = vim.notify

vim.notify = function(msg, level, opts_param)
    if package.loaded.snacks then
        require("snacks").notifier.notify(msg, level, opts_param)
    else
        builtin_notify(msg, level, opts_param)
    end
end

--- Create a floating window using snacks.win
---@param options snacks.win.Config
---@param lines string[]
---@return snacks.win
vim.ui.float = function(options, lines)
    local snacks = require("snacks")

    ---@param self snacks.win
    local on_buf = function(self)
        -- nvim_buf_set_lines rejects any entry containing a newline, so split
        -- multi-line strings (e.g. vim.inspect output) into individual lines.
        local flattened = {}

        for _, line in ipairs(lines) do
            if type(line) == "string" and line:find("\n") then
                vim.list_extend(flattened, vim.split(line, "\n", { plain = true }))
            else
                flattened[#flattened + 1] = line
            end
        end

        vim.api.nvim_buf_set_lines(self.buf --[[@as integer]], 0, -1, false, flattened)
    end

    return snacks.win.new(vim.tbl_deep_extend("force", defaults.ui.float or {}, options or {}, { on_buf = on_buf }))
end

-- Handling to open GitHub partial URLs: organization/repository
local open = vim.ui.open

---@param uri string
vim.ui.open = function(uri)
    --
    if not string.match(uri, "[a-z]*://[^ >,;]*") and string.match(uri, "[%w%p\\-]*/[%w%p\\-]*") then
        uri = string.format("https://github.com/%s", uri)
    end

    open(uri)
end

nvim.command("Root", nvim.root.info, { desc = "Roots for the current buffer" })
