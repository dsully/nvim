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
        ---@module 'render-markdown'
        ---@type render.md.UserConfig
        opts = {
            checkbox = {
                checked = { -- Replaces '[x]' of 'task_list_marker_checked'
                    icon = "󰄵 ",
                    scope_highlight = "@markup.strikethrough",
                },
                unchecked = { -- Replaces '[ ]' of 'task_list_marker_unchecked'
                    icon = "󰄱 ",
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
            on = {
                ---@param buf integer
                attach = function(buf)
                    --
                    -- Toggle check boxes.
                    keys.bmap("<space>tc", function()
                        local char = defaults.icons.misc.check
                        local current_line = vim.api.nvim_get_current_line()

                        local _, _, current_state = string.find(current_line, "%[([ " .. char .. string.upper(char) .. "])%]")

                        if current_state then
                            local new_state = current_state == " " and char or " "
                            local new_line = string.gsub(current_line, "%[.-%]", "[" .. new_state .. "]")

                            vim.api.nvim_set_current_line(new_line)
                        end
                    end, "Checkbox", buf, "n", { noremap = true, silent = true })

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
            },
            overrides = {
                filetype = {
                    codecompanion = {
                        anti_conceal = {
                            enabled = false,
                        },
                        render_modes = true,
                    },
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
