require("helpers.globals")
require("config.options")

vim.cmd.colorscheme(vim.g.colorscheme)

-- auto-commands can be loaded lazily when not opening a file
local lazy_autocmds = vim.fn.argc(-1) == 0

if not lazy_autocmds then
    require("config.autocommands")
end

ev.on(ev.User, function()
    if lazy_autocmds then
        require("config.autocommands")
    end
    require("config.keymaps")
end, {
    pattern = "VeryLazy",
    once = true,
})

require("config.lazy").setup()
