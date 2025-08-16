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
    init = function()
        -- Common misspellings
        vim.cmd.cnoreabbrev("qw", "wq")
        vim.cmd.cnoreabbrev("Wq", "wq")
        vim.cmd.cnoreabbrev("WQ", "wq")
        vim.cmd.cnoreabbrev("Qa", "qa")
        vim.cmd.cnoreabbrev("Bd", "bd")
        vim.cmd.cnoreabbrev("bD", "bd")
    end,
    ---@module "which-key.nvim"
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
            { "<leader>gm", group = "Merge", mode = { "n", "v" } },
            { "<leader>n", group = "Notifications" },
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

            -- Search mappings
            { "/", "ms/", desc = "Keeps jumplist after forward searching" },
            { "?", "ms?", desc = "Keeps jumplist after backward searching" },

            -- Navigation mappings (don't count as jumps)
            {
                "}",
                function()
                    vim.cmd.normal({ args = { vim.v.count1 .. "}" }, bang = true, mods = { keepjumps = true } })
                end,
                desc = "Next paragraph (keepjumps)",
            },
            {
                "{",
                function()
                    vim.cmd.normal({ args = { vim.v.count1 .. "{" }, bang = true, mods = { keepjumps = true } })
                end,
                desc = "Previous paragraph (keepjumps)",
            },

            -- Custom paste mapping
            {
                "p",
                function()
                    -- Remove trailing newline from the " register.
                    local lines = vim.split(vim.fn.getreg('"'):gsub("\n$", ""), "\n", { plain = true })
                    local count = vim.v.vcount1 or 1

                    -- Handle character-wise registers (like from 'x' command)
                    local type = vim.fn.getregtype('"') == "v" and "c" or "l"

                    -- Position cursor at start of the paste
                    for _ = 1, count do
                        vim.api.nvim_put(lines, type, true, false)
                        vim.cmd.normal({ args = { "`[" }, bang = true })
                    end
                end,
                desc = 'Paste on newline from the " register without extra newline.',
            },

            -- Yank mappings
            { "Y", "y$", desc = "Yank to clipboard", mode = { "n", "v" } },
            { "gY", '"*y$', desc = "Yank until end of line to system clipboard", mode = { "n", "v" } },
            { "gy", '"*y', desc = "Yank to system clipboard", mode = { "n", "v" } },
            { "gp", '"*p', desc = "Paste from system clipboard", mode = { "n", "v" } },

            -- Comment mappings
            { "gco", "o<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>", desc = "Add Comment Below" },
            { "gcO", "O<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>", desc = "Add Comment Above" },

            -- Leader mappings
            { "<leader>Y", "<cmd>%y<cr>", desc = "Yank All Lines" },

            -- Control mappings
            { "<C-a>", "gg<S-v>G", desc = "Select All" },
            { "<C-c>", "ciw", desc = "Change In Word" },

            -- Duplicate and comment
            { "yc", "<cmd>norm yygcc<cr>p", desc = "Duplicate line and comment original" },

            -- Alt mappings for line movement
            { "<A-j>", ":m .+1<cr>==", desc = "Move line down" },
            { "<A-k>", ":m .-2<cr>==", desc = "Move line up" },
            { "<A-j>", "<Esc>:m .+1<cr>==gi", desc = "Move line down (insert mode)", mode = "i" },
            { "<A-k>", "<Esc>:m .-2<cr>==gi", desc = "Move line up (insert mode)", mode = "i" },
            { "<A-j>", ":m '>+1<cr>gv=gv", desc = "Move block down", mode = "v" },
            { "<A-k>", ":m '<-2<cr>gv=gv", desc = "Move block up", mode = "v" },

            -- Space mappings
            {
                "<space>n",
                function()
                    return nvim.file.edit
                end,
                desc = "New File",
                expr = false,
            },

            -- macOS specific mappings
            vim.fn.has("mac") == 1
                    and {
                        {
                            "<space>o",
                            function()
                                if vim.bo.buftype ~= nil then
                                    vim.system({ "open", nvim.file.filename() }):wait()
                                end
                            end,
                            desc = "Open in App",
                        },
                        {
                            "<space>T",
                            function()
                                local root = Snacks.git.get_root()

                                if root then
                                    vim.system({ "/usr/bin/open", "-g", "-a", "Tower", root }):wait()
                                end
                            end,
                            desc = "Open in Tower",
                        },
                    }
                or nil,

            -- Spelling
            {
                "zg",
                function()
                    require("lib.spelling").add_word_to_typos(vim.fn.expand("<cword>"))
                end,
                desc = "Add word to spell list",
            },

            -- Code block functions
            {
                "<leader>cc",
                function()
                    vim.fn.setreg("+", string.format("```%s\n%s\n```", vim.bo.filetype, require("lib.buffer").code_block()))
                end,
                desc = "Copy Code: GitHub",
                mode = "v",
            },

            {
                "<leader>cs",
                function()
                    vim.fn.setreg("+", require("lib.buffer").code_block())
                end,
                desc = "Copy Code: Slack",
                mode = "v",
            },

            -- Command mode mappings
            { "<c-a>", "<home>", desc = "goto start of line", mode = "c" },
            { "<c-e>", "<end>", desc = "goto end of line", mode = "c" },

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
