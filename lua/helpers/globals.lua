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
