vim.cmd.colorscheme("nordish")

require("config.options")

-- auto-commands can be loaded lazily when not opening a file
local lazy_autocmds = vim.fn.argc(-1) == 0

if not lazy_autocmds then
    require("config.autocommands")
end

vim.api.nvim_create_autocmd("User", {
    callback = function()
        if lazy_autocmds then
            require("config.autocommands")
        end
        require("config.keymaps")
    end,
    pattern = "VeryLazy",
    once = true,
})

require("config.lazy").setup()
