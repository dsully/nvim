local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.uv.fs_stat(lazypath) then
    vim.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", lazypath }):wait()
    vim.system({ "git", "-C", lazypath, "checkout", "tags/stable" }):wait()
end

vim.opt.runtimepath:prepend(lazypath)

require("lazy").setup("plugins", {
    change_detection = {
        enabled = false,
        notify = false,
    },
    checker = {
        enabled = true,
        notify = false,
    },
    defaults = {
        lazy = true,
    },
    install = {
        colorscheme = { "nordfox" },
        missing = true,
    },
    performance = {
        rtp = {
            disabled_plugins = {
                "2html_plugin",
                "getscript",
                "getscriptPlugin",
                "gzip",
                "health",
                "logipat",
                "man",
                "matchit",
                "matchparen",
                "netrw",
                "netrwFileHandlers",
                "netrwPlugin",
                "netrwSettings",
                "rplugin",
                "rrhelper",
                "spellfile",
                "spellfile_plugin",
                "tar",
                "tarPlugin",
                "tohtml",
                "tutor",
                "vimball",
                "vimballPlugin",
                "zip",
                "zipPlugin",
            },
        },
    },
    profiling = {
        -- Enables extra stats on the debug tab related to the loader cache.
        -- Additionally gathers stats about all package.loaders
        loader = false,
        -- Track each new require in the Lazy profiling tab
        require = false,
    },
    ui = {
        border = vim.g.border,
    },
})

vim.keymap.set("n", "<leader>pi", require("lazy").show, { desc = " Plugin Info" })
vim.keymap.set("n", "<leader>pp", require("lazy").profile, { desc = " Profile Plugins" })
vim.keymap.set("n", "<leader>ps", require("lazy").sync, { desc = " Sync Plugins" })
