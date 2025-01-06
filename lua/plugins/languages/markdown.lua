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
        keys = {
            {
                "<space>tc",
                function()
                    local char = defaults.icons.misc.check
                    local current_line = vim.api.nvim_get_current_line()

                    local _, _, current_state = string.find(current_line, "%[([ " .. char .. string.upper(char) .. "])%]")

                    if current_state then
                        local new_state = current_state == " " and char or " "
                        local new_line = string.gsub(current_line, "%[.-%]", "[" .. new_state .. "]")

                        vim.api.nvim_set_current_line(new_line)
                    end
                end,
                desc = "Checkbox",
                { noremap = true, silent = true },
            },
        },
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
    {
        "dsully/markview.nvim",
        cond = false,
        branch = "treesitter-compat",
        ft = { "markdown", "vimwiki" },
        keys = {
            {
                "<space>tc",
                function()
                    local char = defaults.icons.misc.check
                    local current_line = vim.api.nvim_get_current_line()

                    local _, _, current_state = string.find(current_line, "%[([ " .. char .. string.upper(char) .. "])%]")

                    if current_state then
                        local new_state = current_state == " " and char or " "
                        local new_line = string.gsub(current_line, "%[.-%]", "[" .. new_state .. "]")

                        vim.api.nvim_set_current_line(new_line)
                    end
                end,
                desc = "Checkbox",
                { noremap = true, silent = true },
            },
        },
        opts = function()
            require("snacks")
                .toggle({
                    name = "Markdown",
                    get = function()
                        return require("markview").state.enable
                    end,
                    set = function()
                        vim.cmd.Markview("toggleAll")
                    end,
                })
                :map("<space>tm")

            local presets = require("markview.presets")

            return {
                buf_ignore = defaults.ignored.buffer_types,
                checkboxes = presets.checkboxes.nerd,
                code_blocks = {
                    icons = "mini",
                },
                headings = presets.headings.glow,
                horizontal_rules = presets.horizontal_rules.thick,
                hybrid_modes = { "n" },
                tables = {
                    --stylua: ignore
                    text = {
                        top       = { "┌", "─", "┐", "┬" },
                        header    = { "│", "│", "│" },
                        separator = { "├", "┼", "┤", "─" },
                        row       = { "│", "│", "│" },
                        bottom    = { "└", "─", "┘", "┴" },
                    },
                },
            }
        end,
    },
}
