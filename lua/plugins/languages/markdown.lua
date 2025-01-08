---@type LazySpec[]
return {
    {
        "MeanderingProgrammer/render-markdown.nvim",
        config = function(_, opts)
            --
            require("render-markdown").setup(opts)

            hl.apply({
                { RenderMarkdownCode = { bg = colors.black.base } },
            })

            require("snacks")
                .toggle({
                    name = "Markdown",
                    get = function()
                        return require("render-markdown.state").enabled
                    end,
                    set = function(enabled)
                        local m = require("render-markdown")
                        if enabled then
                            m.enable()
                        else
                            m.disable()
                        end
                    end,
                })
                :map("<space>tm")
        end,
        ft = { "codecompanion", "markdown", "snacks_notif", "vimwiki" },
        ---@module 'render-markdown'
        ---@type render.md.UserConfig
        opts = {
            checkbox = {
                checked = {
                    scope_highlight = "@markup.strikethrough",
                },
            },
            code = {
                border = "none",
                language_pad = 2,
                left_pad = 2,
                min_width = 45,
                right_pad = 2,
                sign = false,
                width = "block",
            },
            heading = {
                position = "inline",
                sign = false,
            },
            link = {
                custom = {
                    python = { pattern = "%.py$", icon = "󰌠 " },
                },
            },
        },
    },
    {
        "Saghen/blink.cmp",
        optional = true,
        opts = {
            sources = {
                default = { "markdown" },
                providers = {
                    markdown = {
                        name = "RenderMarkdown",
                        module = "render-markdown.integ.blink",
                        fallbacks = { "lsp" },
                    },
                },
            },
        },
    },
}
