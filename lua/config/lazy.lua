local M = {
    data = tostring(vim.fn.stdpath("data")),
}

function M.lazy_file()
    -- Add support for the LazyFile event
    local Event = require("lazy.core.handler.event")

    Event.mappings.LazyFile = { id = ev.LazyFile, event = { ev.BufReadPost, ev.BufNewFile, ev.BufWritePre } }
    Event.mappings["User LazyFile"] = Event.mappings.LazyFile
end

function M.lazy_notify()
    local notifs = {}

    local function temp(...)
        table.insert(notifs, vim.F.pack_len(...))
    end

    local orig = vim.notify
    vim.notify = temp

    local timer = vim.loop.new_timer()
    local check = assert(vim.loop.new_check())

    local replay = function()
        if timer then
            timer:stop()
        end

        check:stop()

        if vim.notify == temp then
            vim.notify = orig -- Put back the original notify if needed
        end

        vim.schedule(function()
            for _, notif in ipairs(notifs) do
                vim.notify(vim.F.unpack_len(notif))
            end
        end)
    end

    -- Wait till vim.notify has been replaced
    check:start(function()
        if vim.notify ~= temp then
            replay()
        end
    end)

    -- Or if it took more than 500ms, then something went wrong
    if timer then
        timer:start(500, 0, replay)
    end
end

function M.bootstrap()
    local lazypath = vim.fs.joinpath(M.data, "lazy/lazy.nvim")

    if not vim.uv.fs_stat(lazypath) then
        vim.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", lazypath }):wait()
        vim.system({ "git", "-C", lazypath, "checkout", "tags/stable" }):wait()
    end

    vim.opt.runtimepath:prepend(lazypath)
end

function M.setup()
    M.bootstrap()
    M.lazy_notify()
    M.lazy_file()

    vim.cmd.colorscheme(vim.g.colorscheme)

    ---@type LazyConfig
    require("lazy").setup({
        spec = {
            {
                "autocmds",
                import = "config.autocommands",
                event = "User LazyDone",
                virtual = true,
            },
            {
                "keymaps",
                import = "config.keymaps",
                event = "User LazyDone",
                virtual = true,
            },
            {
                "treesitter",
                event = ev.LazyFile,
                init = function()
                    --
                    ev.on(ev.FileType, function(event)
                        --
                        if pcall(vim.treesitter.start, event.buf) then
                            ev.emit(ev.User, { pattern = "ts_attach" })
                        end
                    end, {
                        desc = "Start treesitter highlighting",
                    })
                end,
                virtual = true,
            },
            { import = "plugins" },
            { import = "plugins.ai" },
            { import = "plugins.filetypes" },
            { import = "plugins.languages" },
        },
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
            path = vim.env.HOME .. "/dev/home/neovim",
            patterns = { vim.env.USER },
        },
        diff = {
            -- diff command <d> can be one of:
            -- * browser: opens the github compare view. Note that this is always mapped to <K> as well,
            --   so you can have a different command for diff <d>
            -- * git: will run git diff and open a buffer with filetype git
            -- * terminal_git: will open a pseudo terminal with git diff
            -- * diffview.nvim: will open Diffview to show the diff
            cmd = "diffview.nvim",
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
                paths = {
                    vim.fs.joinpath(M.data, "ts-install"),
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
    })

    hl.apply({
        LazyCommit = { fg = colors.white.bright },
        LazyDimmed = { link = "Comment" },
        LazyProp = { fg = colors.white.bright },
    })

    vim.api.nvim_create_user_command("LazyHealth", function()
        vim.cmd.Lazy({ "load all", bang = true })
        vim.cmd.checkhealth()
    end, { desc = "Load all plugins and run :checkhealth" })

    vim.api.nvim_create_user_command("LazyPlugin", function(opts)
        --
        dd(lazy.opts(unpack(opts.fargs)))
    end, {
        complete = function(_, line)
            local words = vim.split(line, "%s+")

            if #words <= 2 then
                local prefix = words[2] or ""

                ---@type table<string>
                local matches = {}

                for _, plugin in ipairs(require("lazy").plugins()) do
                    if vim.startswith(plugin.name, prefix) then
                        matches[#matches + 1] = plugin.name
                    end
                end

                table.sort(matches)

                return matches
            end
        end,
        desc = "Show the merged configuration for a given plugin.",
        nargs = "*",
    })

    ev.on(ev.User, function(args)
        --
        if args.data and args.data.plugin then
            local pl = require("lazy.core.config").plugins[args.data.plugin] or {}

            ---@diagnostic disable: undefined-field
            if pl.highlights then
                hl.apply(pl.highlights)
            end
        end
    end, {
        desc = "Apply plugin highlights",
        pattern = "LazyPlugin*",
    })

    ev.on_load("which-key.nvim", function()
        vim.schedule(function()
            local lazy = require("lazy")

            require("which-key").add({
                { "<leader>p", group = "Plugins", icon = " " },
                { "<leader>ph", vim.cmd.LazyHealth, desc = "Health", icon = "󰄬 " },
                { "<leader>pi", lazy.show, desc = "Info", icon = " " },
                { "<leader>pp", lazy.profile, desc = "Profile", icon = " " },
                { "<leader>ps", lazy.sync, desc = "Sync", icon = "󱋖 " },
            }, { notify = false })
        end)
    end)
end

return M
