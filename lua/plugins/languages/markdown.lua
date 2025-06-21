---@type LazySpec[]
return {
    {
        "MeanderingProgrammer/render-markdown.nvim",
        ft = {
            "codecompanion",
            "markdown",
            "snacks_notif",
            "vimwiki",
        },
        highlights = {
            RenderMarkdownCode = { bg = colors.black.base },
        },
        ---@module "render-markdown"
        ---@type render.md.UserConfig
        opts = {
            ---@type render.md.UserCode
            code = {
                border = "none",
                language_pad = 2,
                left_pad = 2,
                min_width = 45,
                right_pad = 2,
                sign = false,
                width = "block",
            },
            completions = {
                lsp = {
                    enabled = false,
                },
            },
            -- Disable by default. Use <space>tm to toggle on.
            enabled = false,
            heading = {
                position = "inline",
                sign = false,
            },
            latex = { enabled = false },
            link = {
                custom = {
                    discord = { pattern = "discord%.com", icon = "󰙯 " },
                    file = { pattern = "^file:", icon = " ", highlight = "RenderMarkdownFileLink" },
                    github = { pattern = "github%.com", icon = "󰊤 " },
                    neovim = { pattern = "neovim%.io", icon = " " },
                    python = { pattern = "%.py$", icon = "󰌠'" },
                    reddit = { pattern = "reddit%.com", icon = "󰑍 " },
                    slack = { pattern = "^http[s]?://%a+.slack.com", icon = "󰒱 ", highlight = "RenderMarkdownLink" },
                    stackoverflow = { pattern = "stackoverflow%.com", icon = "󰓌 " },
                    web = { pattern = "^http", icon = "󰖟 " },
                    youtube = { pattern = "youtube%.com", icon = "󰗃 " },
                },
            },
            on = {
                attach = function()
                    --
                    Snacks.toggle({
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
                    } --[[@as snacks.toggle.Opts]]):map("<space>tm")
                end,
            },
            overrides = {
                filetype = {
                    codecompanion = {
                        enabled = true,
                        anti_conceal = {
                            enabled = false,
                        },
                        heading = {
                            backgrounds = {},
                            icons = { "", "󰭹 ", "󱙺 ", "", "", "" },
                        },
                        html = {
                            tag = {
                                buf = {
                                    icon = " ",
                                    highlight = "Comment",
                                },
                                file = {
                                    icon = "󰨸 ",
                                    highlight = "Comment",
                                },
                                help = {
                                    icon = " ",
                                    highlight = "Comment",
                                },
                                image = {
                                    icon = "󰥶 ",
                                    highlight = "Comment",
                                },
                                symbols = {
                                    icon = " ",
                                    highlight = "Comment",
                                },
                                tool = {
                                    icon = " ",
                                    highlight = "Comment",
                                },
                                url = {
                                    icon = "󰌹 ",
                                    highlight = "Comment",
                                },
                            },
                        },
                        render_modes = true,
                    },
                },
            },
            sign = {
                enabled = false, -- Turn off in the status column
            },
            -- https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/319
            win_options = {
                concealcursor = {
                    rendered = "nvic",
                },
            },
        },
    },
}
