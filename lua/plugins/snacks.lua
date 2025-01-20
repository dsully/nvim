---@type LazySpec
return {
    "folke/snacks.nvim",
    config = function(_, opts)
        local notify = vim.notify
        local snacks = require("snacks")

        snacks.setup(opts)

        -- Restore vim.notify after snacks setup and let noice.nvim take over
        -- this is needed to have early notifications show up in noice history
        vim.notify = notify

        _G.notify = snacks.notify

        ev.on(ev.User, function()
            -- Toggle mappings
            snacks.toggle.diagnostics():map("<space>td")
            snacks.toggle.indent():map("<leader>tI")
            snacks.toggle.inlay_hints():map("<space>ti")
            snacks.toggle.line_number():map("<space>tn")
            snacks.toggle.treesitter():map("<space>tt")
            snacks.toggle.option("spell", { name = "Spelling" }):map("<space>ts")
            snacks.toggle.option("wrap", { name = "Wrap" }):map("<space>tw")

            snacks.toggle.profiler():map("<leader>dpp")
            snacks.toggle.profiler_highlights():map("<leader>dph")

            _G.dd = function(...)
                Snacks.debug.inspect(...)
            end

            _G.bt = function()
                Snacks.debug.backtrace()
            end

            vim.print = _G.dd -- Override print to use snacks for `:=` command
        end, {
            once = true,
            pattern = ev.VeryLazy,
        })

        hl.apply({
            SnacksNormal = { link = "Normal" },
            SnacksBackdrop = { link = "Normal" },
            SnacksIndent = { fg = colors.blue.bright },
            SnacksIndentScope = { fg = colors.blue.bright },
            SnacksNotifierIconTrace = { fg = colors.gray.base },
            SnacksNotifierBorderTrace = { fg = colors.white.bright },
            SnacksNotifierIconDebug = { fg = colors.white.base },
            SnacksNotifierBorderDebug = { fg = colors.white.bright },
            SnacksNotifierIconInfo = { fg = colors.cyan.base },
            SnacksNotifierBorderInfo = { fg = colors.white.bright },
            SnacksNotifierIconWarn = { fg = colors.yellow.base },
            SnacksNotifierBorderWarn = { fg = colors.white.bright },
            SnacksNotifierIconError = { fg = colors.red.base },
            SnacksNotifierBorderError = { fg = colors.white.bright },

            -- Picker
            SnacksPicker = { fg = colors.none, bg = colors.black.dim },
            SnacksPickerDir = { fg = colors.gray.bright },
            SnacksPickerInputBorder = { link = "FloatBorder" },
            SnacksPickerListCursorLine = { bg = colors.black.base },
            SnacksPickerMatch = { fg = "none", bg = "none" },
            SnacksPickerTotals = { bg = colors.black.dim },
        })
    end,
    lazy = false,
    priority = 1000,
    ---@type snacks.Config
    opts = {
        bigfile = {
            enabled = true,
        },
        ---@class snacks.dashboard.Config
        dashboard = {
            enabled = true,
            formats = {
                icon = function(item)
                    if item.file and item.icon == "file" or item.icon == "directory" then
                        return Snacks.dashboard.icon(item.file, item.icon)
                    end

                    local icon_to_hl = {
                        ["󰁯 "] = "String",
                        [" "] = "@comment.todo",
                        [" "] = "Keyword",
                        [" "] = "@text.strong",
                    }

                    return { item.icon, width = 2, hl = icon_to_hl[item.icon] or "icon" } --[[@as snacks.dashboard.Text]]
                end,
                footer = { "%s", align = "center" },
                header = { "%s", align = "center" },
                file = function(item, ctx)
                    local fname = vim.fn.fnamemodify(item.file, ":.") -- Or: ":~"

                    fname = ctx.width and #fname > ctx.width and vim.fn.pathshorten(fname) or fname

                    if #fname > ctx.width then
                        local dir = vim.fn.fnamemodify(fname, ":h")
                        local file = vim.fn.fnamemodify(fname, ":t")

                        if dir and file then
                            file = file:sub(-(ctx.width - #dir - 2))
                            fname = dir .. "/…" .. file
                        end
                    end

                    return { fname }
                end,
            },
            preset = {
                ---@type snacks.dashboard.Item[]|fun(items:snacks.dashboard.Item[]):snacks.dashboard.Item[]?
                keys = {
                    { icon = "󰁯 ", key = "l", desc = "Load Session", action = ":SessionLoad", label = "[l]" },
                    { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert", label = "[n]" },
                    { icon = "󰱼 ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('find_files')", label = "[f]" },
                    { icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.dashboard.pick('live_grep')", label = "[g]" },
                    { icon = " ", key = "p", desc = "Profile Plugins", action = ":Lazy profile", enabled = package.loaded.lazy ~= nil, label = "[p]" },
                    { icon = " ", key = "u", desc = "Update Plugins", action = ":Lazy sync", enabled = package.loaded.lazy ~= nil, label = "[u]" },
                    { icon = " ", key = "q", desc = "Quit", action = ":qa!", label = "[q]" },
                },
                pick = "fzf-lua",
            },
            sections = {
                function()
                    -- In an initialized but empty / no commits repo,
                    -- there will be an error thrown to stderr from git-dashboard-nvim.
                    if not Snacks.git.get_root() then
                        return {}
                    end

                    local heatmap = require("git-dashboard-nvim").heatmap()

                    -- Trigger git-dashboard's highlighting
                    ev.emit(ev.FileType, { pattern = "dashboard" })

                    return {
                        align = "left",
                        height = 12,
                        padding = 1,
                        text = { table.concat(heatmap, "\n") },
                    }
                end,
                {
                    align = "center",
                    text = { "[ Recent Files ]", hl = "Function" } --[[@as snacks.dashboard.Text]],
                    padding = 1,
                },
                { section = "recent_files", indent = 1, padding = 1 },
                {
                    align = "center",
                    text = { string.rep("─", 50), hl = "FloatBorder" } --[[@as snacks.dashboard.Text]],
                    padding = 1,
                },
                { section = "keys", indent = 1 },
                {
                    align = "center",
                    text = { string.rep("─", 50), hl = "FloatBorder" } --[[@as snacks.dashboard.Text]],
                    padding = 1,
                },
                { section = "startup" },
            },
            width = 80,
        },
        gitbrowse = {
            notify = false,
        },
        ---@type snacks.indent.Config
        indent = {
            animate = {
                enabled = false,
            },
            indent = {
                enabled = false,
            },
        },
        input = {
            enabled = true,
            win = {
                actions = {
                    delete_word = function()
                        vim.cmd.normal({ "diw", bang = true })
                    end,
                },
                keys = {
                    i_cw = { "<c-w>", "delete_word", mode = "i" },
                    i_jk = { "jk", { "cmp_close", "cancel" }, mode = "i" },
                },
            },
        },
        notifier = {
            enabled = true,
            icons = {
                error = defaults.icons.diagnostics.error,
                warn = defaults.icons.diagnostics.warn,
                info = defaults.icons.diagnostics.info,
                debug = defaults.icons.diagnostics.debug,
                trace = defaults.icons.diagnostics.trace,
            },
        },
        ---@type snacks.picker.Config
        picker = {
            enabled = true,
            ---@class snacks.picker.icons
            icons = {
                kinds = defaults.icons.lsp,
            },
            layout = {
                layout = {
                    backdrop = false,
                    border = defaults.ui.border.name,
                    height = 0.85,
                    width = 0.85,
                    title = "{source} {live}",
                    title_pos = "center",

                    box = "vertical",
                    {
                        border = defaults.ui.border.name,
                        height = 0.5,
                        win = "preview",
                    },
                    {
                        border = "none",
                        win = "list",
                    },
                    {
                        border = "top",
                        height = 1,
                        win = "input",
                    },
                },
                reverse = false,
            },
            ---@class snacks.picker.matcher.Config
            matcher = {
                fuzzy = false,
            },
            prompt = " ",
            win = {
                input = {
                    keys = {
                        ["<C-h>"] = { "toggle_hidden", mode = { "i", "n" } },
                        ["<C-c>"] = { "close", mode = { "i", "n" } },
                        ["<Esc>"] = { "close", mode = { "i", "n" } },
                    },
                },
            },
            ui_select = true,
        },
        scope = {
            enabled = true,
        },
        statuscolumn = {
            enabled = true,
            left = { "git" },
            right = { "sign" },
            git = { patterns = { "GitSign" } },
        },
        styles = {
            dashboard = {
                bo = { filetype = "dashboard" },
            },
            input = {
                border = defaults.ui.border.name,
            },
            notification = {
                border = defaults.ui.border.name,
                wo = { wrap = true },
            },
            scratch = {
                border = defaults.ui.border.name,
                height = 0.8,
                width = 0.8,
            },
            terminal = defaults.ui.float,
            win = defaults.ui.float,
        },
        words = { enabled = true },
    },
    -- stylua: ignore
    keys = {
        ---@diagnostic disable-next-line: param-type-mismatch
        { "<leader>nd", function() Snacks.notifier:hide() end, desc = "Notification: Dismiss" },
        { "]]", function() Snacks.words.jump(vim.v.count1) end, desc = "snacks: goto next reference" },
        { "[[", function() Snacks.words.jump(-vim.v.count1) end, desc = "snacks: goto prev reference" },

        { [[<C-\>]], function() Snacks.terminal.toggle(vim.env.SHELL) end, mode = { "n", "t" }, desc = "Terminal" },

        -- Git helpers.
        { "<leader>go", function() Snacks.gitbrowse.open() end, desc = "Open Git URL", mode = { "n", "v" } },
        { "<leader>gC", function()
            Snacks.gitbrowse({ open = function(url) vim.fn.setreg("+", url) end, notify = false })
        end, desc = "Copy Git URL", mode = { "n", "v" } },

        -- Profiler
        { "<leader>dps", function() Snacks.profiler.scratch() end, desc = "Profiler Scratch Buffer" },

        -- Scratch
        { "<leader>.",  function() Snacks.scratch() end, desc = "Toggle Scratch Buffer" },

        {"<space>g", function()
            Snacks.terminal({ "gitui" }, { cwd = require("helpers.file").git_root() or vim.uv.cwd() })
        end, desc = "Git UI" },

        -- Pickers
        { "<leader>ff", function()
            local sort = {
                fields = {
                  "file",
                },
            }

            if require("helpers.file").is_git() then
                Snacks.picker.git_files({ sort = sort, untracked = true })
            else
                Snacks.picker.files({ filter = { cwd = true }, sort = sort })
            end
        end,
        desc = "Files" },

        { "<leader>fh", function() Snacks.picker.highlights() end, desc = "Highlights" },

        -- { "<leader>f/", function() require("helpers.picker").grep_curbuf_cword() end, desc = "Current Buffer <cword>" },
        { "<leader>f;", function() Snacks.picker.resume() end, desc = "Resume Picker" },
        { "<leader>fb", function() Snacks.picker.buffers() end, desc = "Buffers" },
        { "<leader>fC", function() Snacks.picker.git_log({ current_file = true }) end, desc = "Commits" },
        { "<leader>fc", function() Snacks.picker.git_log() end, desc = "Commits" },
        { "<leader>fd", function() Snacks.picker.diagnostics({ format = "file" }) end, desc = "Diagnostics" },
        { "<leader>fg", function() Snacks.picker.grep() end, desc = "Grep" },
        { "<leader>fk", function() Snacks.picker.keymaps() end, desc = "Keymaps" },
        { "<leader>fo", function() Snacks.picker.recent({ filter = { cwd = true }}) end, desc = "Recently Opened" },
        { "<leader>fo", function() Snacks.picker.qflist() end, desc = "Quickfix List" },
        { "<leader>fw", function() Snacks.picker.grep_word() end, desc = "Words" },
        { "<leader>fs", function() Snacks.picker.lsp_workspace_symbols() end, desc = "Symbols" },
        -- { "<leader>fn", function() require("helpers.picker").notifications() end, desc = "Notifications" },
        --
        { "gD", function() Snacks.picker.lsp_type_definitions() end, desc = "Goto Type Definition" },
        { "gd", function() Snacks.picker.lsp_definitions({ unique_lines = true }) end, desc = "Goto Definition" },
        { "gi", function() Snacks.picker.lsp_implementations() end, desc = "Goto Implementation" },
        { "grr", function() Snacks.picker.lsp_references({ nowait = true }) end, desc = "References" },
        { "gO", function() Snacks.picker.lsp_symbols() end, desc = "References" },
    },
}
