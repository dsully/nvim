return {
    {
        "supermaven-inc/supermaven-nvim",
        cmd = {
            "SupermavenUseFree",
            "SupermavenUsePro",
        },
        config = function(_, opts)
            --
            ev.on_load("blink.cmp", function()
                vim.schedule(function()
                    require("blink-compat")
                    require("supermaven-nvim").setup(opts)
                end)
            end)
        end,
        event = ev.InsertEnter,
        opts = {
            keymaps = {
                -- Handled by blink
                accept_suggestion = nil,
            },
            disable_inline_completion = true,
            ignore_filetypes = defaults.ignored.file_types,
        },
        { "saghen/blink.compat" },
        {
            "Saghen/blink.cmp",
            dependencies = { "blink.compat", "supermaven-nvim" },
            optional = true,
            opts = {
                sources = {
                    default = { "supermaven" },
                    providers = {
                        supermaven = {
                            name = "supermaven",
                            async = true,
                            module = "blink.compat.source",
                            score_offset = 100,
                            transform_items = function(_, items)
                                local kind = require("blink.cmp.types").CompletionItemKind
                                local kind_idx = #kind + 1

                                kind[kind_idx] = "Supermaven"

                                for _, item in ipairs(items) do
                                    item.kind = kind_idx
                                end

                                return items
                            end,
                        },
                    },
                },
            },
        },
        {
            "folke/noice.nvim",
            optional = true,
            opts = {
                routes = {
                    {
                        filter = {
                            event = "msg_show",
                            any = {
                                { find = "Starting Supermaven" },
                                { find = "Supermaven Free Tier" },
                            },
                        },
                        skip = true,
                    },
                },
            },
        },
    },
}
