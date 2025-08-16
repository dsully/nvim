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

    local timer = vim.uv.new_timer()
    local check = vim.uv.new_check()

    local replay = function()
        if timer then
            timer:stop()
        end

        if check ~= nil then
            check:stop()
        end

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
    if check ~= nil then
        check:start(function()
            if vim.notify ~= temp then
                replay()
            end
        end)
    end

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

function M.init()
    M.bootstrap()
    M.lazy_notify()
    M.lazy_file()

    vim.cmd.colorscheme(vim.g.colorscheme)

    hl.apply({
        LazyButton = { bg = colors.black.base },
        LazyCommit = { fg = colors.white.bright },
        LazyDimmed = { link = "Comment" },
        LazyProp = { fg = colors.white.bright },
    })

    ev.on(ev.User, function(args)
        --
        if args.data ~= nil and args.data.plugin ~= nil then
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
            } --[[@as wk.Spec]], { notify = false })
        end)
    end)

    local spec = {
        { import = "config.autocommands" },
        { import = "plugins" },
        { import = "plugins.ai" },
        { import = "plugins.filetypes" },
        { import = "plugins.languages" },
        { import = "plugins.snacks" },
    }

    if vim.env.WORK ~= nil then
        spec = vim.tbl_extend("force", spec, { import = "plugins.work" })
    end

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

    vim.api.nvim_create_user_command("LazyHealth", function(...)
        vim.cmd.Lazy({ "load all", bang = true })
        vim.cmd.checkhealth()
    end, { desc = "Load all plugins and run :checkhealth" })

    vim.api.nvim_create_user_command("LazyPlugin", function(opts)
        --
        dd(lazy.opts(unpack(opts.fargs) --[[@as string ]]))
    end, {
        complete = function(_, line)
            local words = vim.split(line, "%s+")

            if #words <= 2 then
                ---@type string
                local prefix = words[2] or ""

                ---@type string[]
                local matches = {}

                for
                    _,
                    plugin --[[@as LazyPlugin[] ]]
                in ipairs(require("lazy").plugins()) do
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
end

return M
