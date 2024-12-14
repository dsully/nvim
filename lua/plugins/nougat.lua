return {
    "MunifTanjim/nougat.nvim",
    config = function()
        local bar = require("nougat.bar")
        local core = require("nougat.core")
        local item = require("nougat.item")
        local sep = require("nougat.separator")
        local statusline = bar("statusline")

        local icons = defaults.icons

        local word_filetypes = {
            markdown = true,
            text = true,
            vimwiki = true,
        }

        local base_style = {
            bg = colors.cyan.base,
            fg = colors.black.base,
            bold = true,
        }

        local highlight = {
            inactive = {},
            normal = base_style,
            visual = base_style,
            insert = base_style,
            replace = base_style,
            commandline = base_style,
            terminal = base_style,
        }

        local mode = require("nougat.nut.mode").create({
            prefix = " ",
            suffix = " ",
            sep_right = sep.right_lower_triangle_solid(true),
            config = {
                highlight = highlight,
                text = defaults.statusline.modes,
            },
        })

        -- Renders a space only when item is rendered.
        local function paired_sep(def)
            return function(paired_item)
                def.hidden = paired_item
                return item(def)
            end
        end

        local white_right_triangle = paired_sep({
            content = "",
            hl = { bg = colors.white.base },
            sep_right = sep.right_lower_triangle_solid(true),
        })

        local white_left_triangle = paired_sep({
            hl = { bg = colors.white.base },
            sep_left = sep.left_lower_triangle_solid(true),
            stuffix = " ",
        })

        local diagnostics = require("nougat.nut.buf.diagnostic_count").create({
            prefix = " ",
            suffix = " ",
            hl = { bg = colors.black.base },
            config = {
                error = { prefix = icons.diagnostics.error, fg = colors.red.base },
                warn = { prefix = icons.diagnostics.warn, fg = colors.yellow.base },
                info = { prefix = icons.diagnostics.info, fg = colors.blue.bright },
                hint = { prefix = icons.diagnostics.hint, fg = colors.blue.bright },
            },
            sep_right = sep.right_lower_triangle_solid(true),
            hidden = require("nougat.nut.buf.diagnostic_count").hidden.if_zero(),
        })

        local filetype_icon = item({
            content = function()
                local devicons = require("mini.icons")

                ---@type string?, string?
                local icon, icon_hl = devicons.get("file", vim.api.nvim_buf_get_name(0))

                if not icon then
                    ---@type string?, string?
                    icon, icon_hl = devicons.get("filetype", vim.bo.filetype)
                end

                local hl_name = "Statusline" .. (icon_hl or "")
                local existing = vim.api.nvim_get_hl(0, { name = icon_hl or "" })

                if existing and existing.fg then
                    vim.api.nvim_set_hl(0, hl_name, {
                        bg = colors.black.base,
                        fg = ("#%06x"):format(existing.fg),
                    })
                end

                return string.format(" %%#%s#%s %%##", hl_name, icon or " ")
            end,
            hl = { bg = colors.black.base },
        })

        local filetype_name = item({
            content = function()
                return vim.bo.filetype
            end,
            hl = {
                bg = colors.black.base,
                fg = colors.white.base,
            },
            suffix = " ",
            sep_right = sep.right_lower_triangle_solid(true),
        })

        local filetype = item({
            content = {
                filetype_icon,
                filetype_name,
            },
            hidden = function()
                return vim.bo.filetype == ""
            end,
            hl = {
                bg = colors.black.base,
                fg = colors.white.base,
            },
        })

        local git_status = require("nougat.nut.git.branch").create({
            config = { provider = "gitsigns" },
            hidden = function()
                return not vim.g.gitsigns_head
            end,
            hl = {
                bg = colors.black.base,
                fg = colors.white.base,
            },
            prefix = "  ",
            sep_left = sep.left_lower_triangle_solid(true),
            suffix = " ",
        })

        local hl_search = item({
            content = function()
                if not package.loaded["noice"] then
                    return ""
                end

                ---@diagnostic disable-next-line: undefined-field
                local text = require("noice").api.status.search.get()
                local query = vim.F.if_nil(text:match("%/(.-)%s"), text:match("%?(.-)%s"))

                return string.format("󰍉  %s [%s]", query, text:match("%d+%/%d+"))
            end,
            hidden = function()
                ---@diagnostic disable-next-line: undefined-field
                return not package.loaded["noice"] or not require("noice").api.status.search.has()
            end,
            hl = { fg = colors.white.base },
            prefix = " ",
            sep_right = sep.right_lower_triangle_solid(true),
            suffix = " ",
        })

        local navic = item({
            content = function()
                return require("nvim-navic").get_location()
            end,
            hidden = function()
                return not package.loaded["nvim-navic"] or not require("nvim-navic").is_available()
            end,
            prefix = " ",
        })

        local wordcount = require("nougat.nut.buf.wordcount").create({
            config = {
                format = function(count)
                    return string.format("%d Word%s", count, count > 1 and "s" or "")
                end,
            },
            hidden = function(_, ctx)
                return not word_filetypes[vim.api.nvim_get_option_value("filetype", { buf = ctx.bufnr })]
            end,
            hl = {
                bg = colors.black.base,
                fg = colors.white.base,
            },
            sep_left = sep.left_lower_triangle_solid(true),
            prefix = " ",
            suffix = " ",
        })

        local counts = item({
            hl = {
                bg = colors.black.base,
                fg = colors.white.base,
            },
            prefix = " ",
            sep_left = sep.left_lower_triangle_solid(true),
            content = table.concat({
                core.group({
                    core.code("l"),
                    "/",
                    core.code("L"),
                    ":",
                    core.code("v"),
                    core.code("P", { min_width = 4 }),
                    "  ",
                }, { align = "right" }),
            }),
        })

        local items = {
            { mode },
            { white_right_triangle(filetype), filetype },
            { white_right_triangle(diagnostics), diagnostics },
            { white_right_triangle(hl_search), hl_search },
            { white_right_triangle(navic), navic },
            { require("nougat.nut.spacer").create() },
            { require("nougat.nut.truncation_point").create() },
            { white_left_triangle(git_status), git_status },
            { white_left_triangle(wordcount), wordcount },
            { white_left_triangle(counts), counts },
        }

        for _, item_pair in ipairs(items) do
            for _, component in ipairs(item_pair) do
                statusline:add_item(component)
            end
        end

        require("nougat").set_statusline(statusline)
    end,
    event = ev.LazyFile,
    init = function()
        if vim.fn.argc(-1) > 0 then
            -- Set an empty statusline until nougat loads
            vim.o.statusline = " "
        else
            -- Hide the statusline on the starter page
            vim.o.laststatus = 0
        end
    end,
}
