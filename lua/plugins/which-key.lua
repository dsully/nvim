local icons = defaults.icons

return {
    "folke/which-key.nvim",
    event = ev.VeryLazy,
    init = function()
        hl.apply({
            { WhichKey = { link = "Identifier" } },
            { WhichKeyBorder = { default = true, link = "FloatBorder" } },
            { WhichKeyDesc = { link = "Keyword" } },
            { WhichKeyFloat = { link = "NormalFloat" } },
            { WhichKeyGroup = { link = "Function" } },
            { WhichKeySeparator = { link = "Comment" } },
            { WhichKeyValue = { link = "Comment" } },
        })
    end,
    opts = {
        delay = 1000,
        disable = {
            bt = defaults.ignored.buffer_types,
            ft = defaults.ignored.file_types,
        },
        icons = {
            rules = {
                { pattern = "copy", icon = " " },
                { pattern = "emojii", icon = "󰞅 " },
                { pattern = "grep", icon = "󰈞 " },
                { pattern = "icon", icon = " " },
                { pattern = "inspect", icon = " " },
                { pattern = "pattern", icon = "󰛪 " },
                { pattern = "log", icon = "󰦪 " },
                { pattern = "open", icon = "󰏋 " },
                { pattern = "refactor", icon = icons.misc.gear },
                { pattern = "word", icon = " " },
                { pattern = "url", icon = "󰖟 " },
                { pattern = "yank", icon = " " },
            },
        },
        plugins = {
            marks = true,
            registers = true,
            spelling = {
                enabled = false, -- enabling this will show WhichKey when pressing z= to select spelling suggestions
            },
            presets = {
                operators = true, -- adds help for operators like d, y, ...
                motions = true, -- adds help for motions
                text_objects = true, -- help for text objects triggered after entering an operator
                windows = true, -- default bindings on <c-w>
                nav = true, -- misc bindings to work with windows
                z = true, -- bindings for folds, spelling and others prefixed with z
                g = true, -- bindings for prefixed with g
            },
        },
        preset = "classic",
        replace = {
            key = {
                { "<space>", "Space" },
                { "<cr>", "Return" },
                { "<tab>", "Tab" },
            },
        },
        show_help = false, -- show help message on the command line when the popup is visible
        show_keys = false, -- show the currently pressed key and its label as a message in the command line
        spec = {
            { "<c-w>", group = "windows" },
            { "<leader>", group = "actions" },
            { "<leader>a", group = "AI", icon = "󱙺 ", mode = { "n", "t" } },
            { "<leader>b", group = "Buffers", icon = "" },
            { "<leader>c", group = "Code", icon = icons.misc.code, mode = { "n", "t" } },
            { "<leader>d", group = "Debug" },
            { "<leader>dp", group = "Profiler" },
            { "<leader>f", group = "Find", icon = icons.misc.telescope },
            { "<leader>g", group = "Git", icon = icons.misc.git, mode = { "n", "x" } },
            { "<leader>gh", group = "GitHub", icon = icons.misc.github, mode = { "n", "x" } },
            { "<leader>n", group = "Notifications", icon = icons.diagnostics.info },
            { "<leader>q", group = "Quit", icon = icons.misc.exit },
            { "<leader>r", group = "Rules", icon = " " },
            { "<leader>s", group = "Substitute", icon = " " },
            { "<leader>S", group = "Snippets", icon = " " },
            { "<leader>t", group = "Test", icon = "󰱑 " },
            { "<leader>v", group = "View", icon = icons.misc.telescope },
            { "<leader>x", group = "Diagnostics", icon = " " },
            { "<space>", group = "actions" },
            { "<space>t", group = "Toggle" },
            { "K", desc = "Documentation", icon = " " },
            { "[", group = "previous", icon = "󰒮" },
            { "]", group = "next", icon = "󰒭" },
            { "g", group = "go to" },
            { "s", group = "surround" },
            { "z", group = "spelling & folds" },

            -- {
            --     "sh",
            --     group = "Surround Highlighting",
            --     {
            --         { "shn", desc = "Highlight Next Surround" },
            --         { "shl", desc = "Highlight Prev Surround" },
            --     },
            -- },

            -- Don't delete into the system clipboard.
            { "dw", '"_dw', hidden = true, mode = { "n", "x" }, noremap = true },

            -- Ignore junk
            { "<2-LeftMouse>", hidden = true },
            { "<C-L>", hidden = true },
            { "<C-W>d", desc = "Open Float" },
            --
            -- vim-matchup
            { "%", hidden = true },

            -- Builtins
            { "<leader>?", hidden = true },
            { "!", hidden = true },
            { "&", hidden = true },
            { "<", hidden = true },
            { ">", hidden = true },
            { "H", hidden = true },
            { "L", hidden = true },
            { "M", hidden = true },
            { "V", hidden = true },
            { "r", hidden = true },
            { "v", hidden = true },
            { "~", hidden = true },
        },
        triggers = {
            { "<auto>", mode = "nixsotc" },
            { "s", mode = { "n", "v" } },
        },
        win = {
            border = defaults.ui.border.name,
            -- Don't allow the popup to overlap with the cursor
            no_overlap = true,
        },
    },
}
