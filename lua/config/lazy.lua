local M = {
    data = tostring(vim.fn.stdpath("data")),
}

function M.lazy_file()
    -- Add support for the LazyFile event
    local Event = require("lazy.core.handler.event")

    Event.mappings.LazyFile = { id = ev.LazyFile, event = { ev.BufReadPost, ev.BufNewFile, ev.BufWritePre } }
    Event.mappings["User LazyFile"] = Event.mappings.LazyFile
end

function M.init()
    vim.pack.add({ "https://github.com/folke/lazy.nvim" }, { confirm = false })

    M.lazy_file()

    vim.cmd.colorscheme(vim.g.colorscheme)

    ev.on_load("which-key.nvim", function()
        vim.schedule(function()
            local lazy = require("lazy")

            require("which-key").add({
                { "<leader>p", group = "Plugins", icon = " " },
                { "<leader>pi", lazy.show, desc = "Info", icon = " " },
                { "<leader>pp", lazy.profile, desc = "Profile", icon = " " },
                { "<leader>ps", lazy.sync, desc = "Sync", icon = "󱋖 " },
            } --[[@as wk.Spec]], { notify = false })
        end)
    end)

    local spec = {
        { import = "config.autocommands" },
        { import = "plugins" },
        { import = "plugins.ai" },
        { import = "plugins.languages" },
        { import = "plugins.snacks" },
    }

    if vim.env.WORK ~= nil then
        spec = vim.tbl_extend("force", spec, { import = "plugins.work" })
    end

    ---@diagnostic disable-next-line: missing-fields
    require("lazy").setup({
        spec = spec,
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
            version = false, -- always use the latest git commit
        },
        dev = {
            fallback = true,
            path = vim.env.HOME .. "/dev/forked/neovim",
            patterns = { vim.env.USER },
        },
        diff = {
            -- diff command <d> can be one of:
            -- * browser: opens the github compare view. Note that this is always mapped to <K> as well,
            --   so you can have a different command for diff <d>
            -- * git: will run git diff and open a buffer with filetype git
            -- * terminal_git: will open a pseudo terminal with git diff
            -- * diffview.nvim: will open Diffview to show the diff
            cmd = "git",
        },
        install = {
            colorscheme = { vim.g.colorscheme },
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

                    --
                    "plenary",
                },
            },
        },
        pkg = {
            sources = {
                "rockspec",
            },
        },
        profiling = {
            -- Enables extra stats on the debug tab related to the loader cache.
            -- Additionally gathers stats about all package.loaders
            loader = true,
            -- Track each new require in the Lazy profiling tab
            require = false,
        },
        rocks = {
            -- On Linux, libncurses-dev and libreadline-dev need to be installed for hererocks to build.
            hererocks = true,
        },
        ui = {
            backdrop = 90,
            border = defaults.ui.border.name,
        },
    } --[[@as LazyConfig]])
end

return M
