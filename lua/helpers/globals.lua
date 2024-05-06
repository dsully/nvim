--
--- Global debug function
---@vararg any anything to debug
_G.dbg = function(...)
    local objects = {}

    for _, v in pairs({ ... }) do
        table.insert(objects, v ~= nil and vim.inspect(v) or "nil")
    end

    vim.notify(table.concat(objects, "\n"))
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
