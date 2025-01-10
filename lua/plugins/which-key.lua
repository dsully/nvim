---@type LazySpec
return {
    "folke/which-key.nvim",
    event = ev.VeryLazy,
    highlights = {
        WhichKey = { link = "Identifier" },
        WhichKeyBorder = { default = true, link = "FloatBorder" },
        WhichKeyDesc = { link = "Keyword" },
        WhichKeyFloat = { link = "NormalFloat" },
        WhichKeyGroup = { link = "Function" },
        WhichKeySeparator = { link = "Comment" },
        WhichKeyValue = { link = "Comment" },
    },
    ---@type wk.Config
    opts = {
        delay = 1000,
        disable = {
            bt = defaults.ignored.buffer_types,
            ft = defaults.ignored.file_types,
        },
        icons = {
            rules = {
                { pattern = "ai", icon = defaults.icons.misc.ai },
                { pattern = "codecompanion", icon = defaults.icons.misc.ai },
                { pattern = "copy", icon = " " },
                { pattern = "emoji", icon = "󰞅 " },
                { pattern = "grep", icon = "󰈞 " },
                { pattern = "icon", icon = " " },
                { pattern = "inspect", icon = " " },
                { pattern = "pattern", icon = "󰛪 " },
                { pattern = "log", icon = "󰦪 " },
                { pattern = "open", icon = "󰏋 " },
                { pattern = "refactor", icon = defaults.icons.misc.gear },
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
            { "<leader>", group = "actions", icon = defaults.icons.misc.actions },
            { "<leader>b", group = "Buffers" },
            { "<leader>c", group = "Code", mode = { "n", "v" } },
            { "<leader>d", group = "Debug" },
            { "<leader>dl", group = "Log" },
            { "<leader>dp", group = "Profiler" },
            { "<leader>f", group = "Find" },
            { "<leader>g", group = "Git", mode = { "n", "v" } },
            { "<leader>gh", group = "GitHub", mode = { "n", "v" } },
            { "<leader>n", group = "Notifications" },
            { "<leader>q", group = "Quit" },
            { "<leader>r", group = "Rules" },
            { "<leader>s", group = "Substitute" },
            { "<leader>S", group = "Snippets" },
            { "<leader>t", group = "Test" },
            { "<leader>x", group = "Diagnostics" },
            { "<space>", group = "actions", icon = defaults.icons.misc.actions },
            { "<space>t", group = "Toggle" },
            { "K", desc = "Documentation" },
            { "[", group = "previous", icon = "󰒮" },
            { "]", group = "next", icon = "󰒭" },
            { "g", group = "go to", icon = defaults.icons.misc.exit },
            { "s", group = "surround", icon = defaults.icons.misc.surround },
            { "z", group = "spelling & folds", icon = "󰀬 " },

            -- {
            --     "sh",
            --     group = "Surround Highlighting",
            --     {
            --         { "shn", desc = "Highlight Next Surround" },
            --         { "shl", desc = "Highlight Prev Surround" },
            --     },
            -- },

            -- Don't delete into the system clipboard.
            { "dw", '"_dw', hidden = true, mode = { "n", "v" }, noremap = true },

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
    opts_extend = { "spec" },
}
