---@module "lazy.types"
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
        end, {
            once = true,
            pattern = ev.VeryLazy,
        })

        hl.apply({
            SnacksNormal = { link = "Normal" },
            SnacksBackdrop = { link = "Normal" },
            SnacksIndent = { fg = colors.blue.bright },
            SnacksIndentScope = { fg = colors.blue.bright },

            SnacksNotifierBorderDebug = { fg = colors.white.bright },
            SnacksNotifierBorderError = { fg = colors.white.bright },
            SnacksNotifierBorderInfo = { fg = colors.white.bright },
            SnacksNotifierBorderTrace = { fg = colors.white.bright },
            SnacksNotifierBorderWarn = { fg = colors.white.bright },
            SnacksNotifierDebug = { bg = colors.bg },
            SnacksNotifierError = { bg = colors.bg },
            SnacksNotifierIconDebug = { fg = colors.white.base },
            SnacksNotifierIconError = { fg = colors.red.base },
            SnacksNotifierIconInfo = { fg = colors.cyan.base },
            SnacksNotifierIconTrace = { fg = colors.gray.base },
            SnacksNotifierIconWarn = { fg = colors.yellow.base },
            SnacksNotifierInfo = { bg = colors.bg },
            SnacksNotifierTrace = { bg = colors.bg },
            SnacksNotifierWarn = { bg = colors.bg },

            -- Picker
            SnacksPicker = { fg = colors.none, bg = colors.black.dim },
            SnacksPickerDir = { fg = colors.gray.bright },
            SnacksPickerInputBorder = { link = "FloatBorder" },
            SnacksPickerListCursorLine = { bg = colors.black.base },
            SnacksPickerMatch = { bg = colors.none, fg = colors.none },
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
        explorer = {
            replace_netrw = true,
        },
        gitbrowse = {
            notify = false,
            url_patterns = {
                [".*github.*%..+.com"] = {
                    branch = "/tree/{branch}",
                    file = "/blob/{branch}/{file}#L{line_start}-L{line_end}",
                    permalink = "/blob/{commit}/{file}#L{line_start}-L{line_end}",
                    commit = "/commit/{commit}",
                },
            },
            what = "permalink",
        },
        image = {
            enabled = true,
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
        scope = {
            enabled = true,
        },
        ---@type snacks.statuscolumn.Config
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
                relative = "cursor",
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
            snacks_image = {
                border = vim.tbl_map(function(icon)
                    return { icon, "FloatBorderSB" }
                end, defaults.ui.border.chars),
            },
            terminal = defaults.ui.float,
            win = defaults.ui.float,
        },
        terminal = {
            enabled = true,
            shell = "fish",
        },
        words = {
            enabled = false,
            filter = function(buf)
                return vim.bo[buf].buftype ~= defaults.ignored.buffer_types
            end,
            modes = { "n" },
        },
    },
    keys = {
        -- stylua: ignore start
        { "<leader>xd", function() Snacks.notifier.hide() end, desc = "Dismiss Notification" },
        { "]]", function() Snacks.words.jump(vim.v.count1) end, desc = "Snacks: goto next reference" },
        { "[[", function() Snacks.words.jump(-vim.v.count1) end, desc = "Snacks: goto prev reference" },

        { [[<C-\>]], function() Snacks.terminal.toggle(vim.env.SHELL) end, mode = { "n", "t" }, desc = "Terminal" },

        -- Git helpers.
        { "<leader>go", function() Snacks.gitbrowse.open() end, desc = "Open Git URL", mode = { "n", "v" } },

        { "<leader>gC", function()
            Snacks.gitbrowse({ open = function(url) vim.fn.setreg("+", url) end, notify = false } --[[@as snacks.gitbrowse.Config]])
        end, desc = "Copy Git URL", mode = { "n", "v" } },

        -- Profiler
        { "<leader>dps", function() Snacks.profiler.scratch() end, desc = "Profiler Scratch Buffer" },

        -- Scratch
        { "<leader>.",  function() Snacks.scratch() end, desc = "Toggle Scratch Buffer" },

        {"<space>g", function()
            Snacks.terminal({ "gitui" }, { cwd = Snacks.git.get_root() or nvim.file.cwd() } --[[@as snacks.terminal.Opts]])
        end, desc = "Git UI" },
    },
}
