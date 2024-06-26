vim.cmd.colorscheme("nordish")

require("config.options")

-- auto-commands can be loaded lazily when not opening a file
local lazy_autocmds = vim.fn.argc(-1) == 0

if not lazy_autocmds then
    require("config.autocommands")
end

local e = require("helpers.event")

e.on(e.User, function()
    if lazy_autocmds then
        require("config.autocommands")
    end
    require("config.keymaps")
end, {
    pattern = "VeryLazy",
    once = true,
})

require("helpers.globals")

require("config.lazy").setup()
