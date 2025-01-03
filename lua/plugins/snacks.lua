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
            snacks.toggle.inlay_hints():map("<space>ti")
            snacks.toggle.line_number():map("<space>tn")
            snacks.toggle.treesitter():map("<space>tt")
            snacks.toggle.option("spell", { name = "Spelling" }):map("<space>ts")
            snacks.toggle.option("wrap", { name = "Wrap" }):map("<space>tw")

            snacks.toggle.profiler():map("<leader>dpp")
            snacks.toggle.profiler_highlights():map("<leader>dph")
        end, {
            once = true,
            pattern = ev.VeryLazy,
        })

        hl.apply({
            { SnacksNormal = { link = "Normal" } },
            { SnacksBackdrop = { link = "Normal" } },

            { SnacksIndentScope = { fg = colors.blue.bright } },

            { SnacksNotifierIconTrace = { fg = colors.gray.base } },
            { SnacksNotifierBorderTrace = { fg = colors.white.bright } },

            { SnacksNotifierIconDebug = { fg = colors.white.base } },
            { SnacksNotifierBorderDebug = { fg = colors.white.bright } },

            { SnacksNotifierIconInfo = { fg = colors.cyan.base } },
            { SnacksNotifierBorderInfo = { fg = colors.white.bright } },

            { SnacksNotifierIconWarn = { fg = colors.yellow.base } },
            { SnacksNotifierBorderWarn = { fg = colors.white.bright } },

            { SnacksNotifierIconError = { fg = colors.red.base } },
            { SnacksNotifierBorderError = { fg = colors.white.bright } },
        })
    end,
    priority = 1000,
    lazy = false,
    ---@type snacks.Config
    opts = {
        bigfile = {
            enabled = true,
        },
        gitbrowse = {
            notify = false,
        },
        ---@type snacks.indent.Config
        ---@diagnostic disable-next-line: missing-fields
        indent = {
            animate = {
                enabled = false,
            },
            indent = {
                enabled = false,
            },
        },
        input = {
            enable = true,
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
        statuscolumn = {
            enabled = true,
            left = { "git" },
            right = { "sign" },
            git = { patterns = { "GitSign" } },
        },
        styles = {
            ---@diagnostic disable-next-line: missing-fields
            input = {
                border = defaults.ui.border.name,
            },
            ---@diagnostic disable-next-line: missing-fields
            notification = {
                border = defaults.ui.border.name,
                wo = { wrap = true },
            },
            ---@diagnostic disable-next-line: missing-fields
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
        { "<leader>go", function() Snacks.gitbrowse.open() end, desc = "Open Git URL", mode = { "n", "x" } },
        { "<leader>gC", function()
            ---@diagnostic disable-next-line: missing-fields
            Snacks.gitbrowse({ open = function(url) vim.fn.setreg("+", url) end, notify = false })
        end, desc = "Copy Git URL", mode = { "n", "x" } },

        -- Profiler
        { "<leader>dps", function() Snacks.profiler.scratch() end, desc = "Profiler Scratch Buffer" },

        -- Scratch
        { "<leader>.",  function() Snacks.scratch() end, desc = "Toggle Scratch Buffer" },
    },
}
