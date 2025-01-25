---@type LazySpec[]
return {
    {
        "zbirenbaum/copilot.lua",
        init = function()
            --
            ev.on_load("blink.cmp", function()
                ev.on(ev.User, function()
                    require("copilot.suggestion").dismiss()
                    vim.b.copilot_suggestion_hidden = true
                end, {
                    pattern = "BlinkCmpMenuOpen",
                })

                ev.on(ev.User, function()
                    vim.b.copilot_suggestion_hidden = false
                end, {
                    pattern = "BlinkCmpMenuClose",
                })
            end)
        end,
        opts = {
            filetypes = {
                ["*"] = false, -- Disable for all other filetypes and ignore default `filetypes`
                bash = true,
                c = true,
                cpp = true,
                fish = true,
                go = true,
                html = true,
                java = true,
                javascript = true,
                just = true,
                lua = true,
                python = true,
                rust = true,
                sh = true,
                typescript = true,
                zsh = true,
            },
            -- Per: https://github.com/zbirenbaum/copilot-cmp#install
            panel = {
                enabled = false,
                auto_refresh = true,
            },
            suggestion = {
                enabled = false,
                auto_trigger = true,
                keymap = {
                    accept = "<C-y>",
                    accept_word = false,
                    accept_line = false,
                    next = "<C-n>",
                    prev = "<C-p>",
                    dismiss = "<Esc>",
                },
            },
        },
    },
    -- { "giuxtaposition/blink-cmp-copilot" },
    { "fang2hou/blink-copilot" },
    {
        "Saghen/blink.cmp",
        optional = true,
        opts = {
            completion = { menu = { draw = { treesitter = { "copilot" } } } },
            sources = {
                default = { "copilot" },
                per_filetype = {
                    lua = {
                        "copilot",
                    },
                },
                providers = {
                    copilot = {
                        name = "Copilot",
                        async = true,
                        module = "blink-copilot",
                        score_offset = 100,
                    },
                },
            },
        },
    },
}
