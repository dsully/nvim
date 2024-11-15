require("helpers.globals")
require("config.options")

vim.cmd.colorscheme(vim.g.colorscheme)

-- perf: Defer loading of filetype and autocommands if no files were passed.
if vim.fn.argc(-1) == 0 then
    --
    ev.on(ev.User, function()
        require("config.autocommands")
        require("config.filetype")
    end, {
        pattern = "VeryLazy",
        once = true,
    })
else
    require("config.autocommands")
    require("config.filetype")
end

require("config.lazy").setup()
require("config.keymaps")
