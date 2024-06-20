local icons = require("config.defaults").icons

return {
    "folke/which-key.nvim",
    config = function(_, opts)
        local wk = require("which-key")

        wk.setup(opts)

        for _, menu in pairs({
            { key = [[\\]], opts = { desc = "Local" } },
            { key = "g", opts = { desc = "Go" } },
            { key = "q", opts = { desc = "Quit" } },
            { key = "s", opts = { desc = "Surround" } },
            { key = "z", opts = { desc = "Spelling & Folds" } },
            { key = "<leader>", opts = {} },
            { key = "<space>", opts = { desc = "Actions" } },
            { key = "<c-w>", opts = { desc = "Windows" } },
            { key = "]", opts = { desc = "Next 󰒭" } },
            { key = "[", opts = { desc = "Previous 󰒮" } },
            { key = "<leader>c", opts = { desc = icons.misc.copilot .. "Copilot" }, mode = { "n", "t" } },
            { key = "<leader>c", opts = { desc = " Code" }, mode = { "n", "t" } },
            { key = "<leader>f", opts = { desc = " Find" } },
            { key = "<leader>m", opts = { desc = " Map View" } },
            { key = "<leader>n", opts = { desc = " Notifications" } },
            { key = "<leader>q", opts = { desc = "󰗼 Quit" } },
            { key = "<leader>r", opts = { desc = " Rules" } },
            { key = "<leader>s", opts = { desc = " Snippets" }, mode = { "n" } },
            { key = "<leader>v", opts = { desc = " View" } },
            { key = "<leader>x", opts = { desc = " Diagnostics" } },
        }) do
            wk.register({ [menu.key] = { name = menu.opts.desc } }, { mode = menu.opts.mode or "n" })
        end

        -- Give descriptions to 0.10+ default mappings.
        wk.register({
            -- Ignore junk
            ["<2-LeftMouse>"] = { "which_key_ignore" },
            ["<C-L>"] = { "which_key_ignore" },
            ["<C-W>d"] = { "Open Float" },
            ["<SNR>"] = { "which_key_ignore" },
            --
            -- vim-matchup
            ["z%"] = { "which_key_ignore" },
            --
            K = { "Documentation  " },
        })
    end,
    event = "LazyFile",
    init = function()
        vim.o.timeout = true
        vim.o.timeoutlen = 500
    end,
    opts = {
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
        -- add operators that will trigger motion and text object completion
        -- to enable all native operators, set the preset / operators plugin above
        operators = {},
        key_labels = {
            -- override the label used to display some keys. It doesn't effect WK in any other way.
            -- For example:
            ["<space>"] = "Space",
            ["<cr>"] = "Return",
            ["<tab>"] = "Tab",
        },
        motions = {
            count = true,
        },
        icons = {
            breadcrumb = "»", -- symbol used in the command line area that shows your active key combo
            separator = "➜", -- symbol used between a key and it's label
            group = "", -- symbol prepended to a group
        },
        popup_mappings = {
            scroll_down = "<c-d>", -- binding to scroll down inside the pop-up
            scroll_up = "<c-u>", -- binding to scroll up inside the pop-up
        },
        window = {
            border = vim.g.border,
            position = "bottom", -- bottom, top
            margin = { 1, 0, 1, 0 }, -- extra window margin [top, right, bottom, left]. When between 0 and 1, will be treated as a percentage of the screen size.
            padding = { 1, 2, 2, 2 }, -- extra window padding [top, right, bottom, left]
            winblend = 0, -- value between 0-100 0 for fully opaque and 100 for fully transparent
            zindex = 1000, -- positive value to position WhichKey above other floating windows.
        },
        layout = {
            height = { min = 4, max = 25 }, -- min and max height of the columns
            width = { min = 20, max = 50 }, -- min and max width of the columns
            spacing = 3, -- spacing between columns
            align = "left", -- align columns left, center or right
        },
        ignore_missing = false, -- enable this to hide mappings for which you didn't specify a label
        hidden = {
            "<silent>",
            "<cmd>",
            "<Cmd>",
            "<CR>",
            "<Nop>",
            "^:",
            "^ ",
            "^call ",
            "^lua ",
        },
        show_help = true, -- show a help message in the command line for using WhichKey
        show_keys = true, -- show the currently pressed key and its label as a message in the command line
        triggers = "auto", -- automatically setup triggers
        -- triggers = {"<leader>"} -- or specify a list manually
        -- List of triggers, where WhichKey should not wait for timeoutlen and show immediately
        triggers_nowait = {
            -- registers
            '"',
            "<c-r>",
            -- spelling
            "z=",
        },
        triggers_blacklist = {
            -- List of mode / prefixes that should never be hooked by WhichKey
            -- This is mostly relevant for key-maps that start with a native binding
            i = { "j", "k" },
            v = { "j", "k" },
        },
        disable = {
            buftypes = require("config.defaults").ignored.buffer_types,
            filetypes = require("config.defaults").ignored.file_types,
        },
    },
}
