---@type LazySpec[]
return {
    {
        "supermaven-inc/supermaven-nvim",
        cond = defaults.ai.supermaven,
        init = function()
            --
            local ns = nvim.ns("supermaven")

            ev.on_load("blink.cmp", function()
                ev.on(ev.User, function(event)
                    vim.api.nvim_buf_del_extmark(event.buf, ns, 1)

                    local api = require("supermaven-nvim.api")

                    if api.is_running() then
                        api.stop()
                    end
                end, {
                    pattern = "BlinkCmpMenuOpen",
                })

                ev.on(ev.User, function(event)
                    vim.api.nvim_buf_del_extmark(event.buf, ns, 1)

                    local api = require("supermaven-nvim.api")

                    if not api.is_running() then
                        api.start()
                    end
                end, {
                    pattern = "BlinkCmpMenuClose",
                })
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
    },
    {
        "Saghen/blink.cmp",
        optional = true,
        opts = {
            completion = { menu = { draw = { treesitter = { "supermaven" } } } },
            sources = {
                default = { "supermaven" },
                per_filetype = {
                    lua = {
                        "supermaven",
                    },
                },
                providers = {
                    supermaven = {
                        name = "supermaven",
                        async = true,
                        module = "blink.compat.source",
                        score_offset = 100,
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
}
