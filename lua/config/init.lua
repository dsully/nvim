require("config.globals")
require("config.options")

vim.cmd.colorscheme(vim.g.colorscheme)

-- perf: Defer loading of autocommands if no files were passed.
if vim.fn.argc(-1) == 0 then
    --
    ev.on(ev.User, function()
        require("config.autocommands")
    end, {
        pattern = "VeryLazy",
        once = true,
    })
else
    require("config.autocommands")
end

require("config.lazy").setup()
require("config.keymaps")
