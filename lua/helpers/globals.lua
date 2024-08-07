--
--- Global debug function
---@param ... any
_G.dbg = function(...)
    local info = debug.getinfo(2, "S")
    local source = info.source:sub(2)

    local args = { ... }

    if vim.islist(args) and vim.tbl_count(args) <= 1 then
        args = args[1]
    end

    local msg = "Source: " .. source("\n\n") .. vim.split(vim.inspect(vim.deepcopy(args)), "\n")

    require("helpers.float").open({ filetype = "lua", lines = msg, window = { width = 0.8 } })
end

--
--- Global telescope loader.
---
---@param command string The telescope command to run.
---@param args (fun(): table<string>)|table<string>|nil The arguments to pass to the telescope command.
_G.tscope = function(command, args)
    --
    return function()
        if type(args) == "function" then
            args = args()
        end

        vim.cmd.Telescope({ args = { command, unpack(args or {}) } })
    end
end

--- Create a namespace.
--- @param name string The name of the namespace.
_G.ns = function(name)
    return vim.api.nvim_create_namespace("dsully/" .. name)
end

-- Handling to open GitHub partial URLs: organization/repository
local open = vim.ui.open

vim.ui.open = function(uri) ---@diagnostic disable-line: duplicate-set-field
    --
    if not string.match(uri, "[a-z]*://[^ >,;]*") and string.match(uri, "[%w%p\\-]*/[%w%p\\-]*") then
        uri = string.format("https://github.com/%s", uri)
    end

    open(uri)
end
