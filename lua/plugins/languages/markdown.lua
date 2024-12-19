return {
    {
        "OXY2DEV/markview.nvim",
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
                .toggle({ ---@diagnostic disable-line: missing-fields
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
