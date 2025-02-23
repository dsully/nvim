---@type LazySpec[]
return {
    "MunifTanjim/nougat.nvim",
    config = function()
        local bar = require("nougat.bar")
        local core = require("nougat.core")
        local item = require("nougat.item")
        local sep = require("nougat.separator")
        local statusline = bar("statusline")

        local icons = defaults.icons

        local ai = require("plugins.ai.codecompanion.status")

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
        } --[[@as nougat_nut_mode_config]])

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
        } --[[@as nougat.nut.buf.diagnostic_count_config]])

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
                return not vim.g.gitsigns_head or ai:open()
            end,
            hl = {
                bg = colors.black.base,
                fg = colors.white.base,
            },
            prefix = "  ",
            sep_left = sep.left_lower_triangle_solid(true),
            suffix = " ",
        } --[[@as nougat.nut.git.branch_config?]])

        local hl_search = item({
            content = function()
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

        local codecompanion = item({
            content = function()
                return ai:update()
            end,
            hidden = function()
                return not ai.processing
            end,
            prefix = " " .. defaults.icons.misc.ai .. " ",
            suffix = " ",
            hl = {
                bg = colors.black.base,
                fg = colors.white.base,
            },
        })

        local schema = item({
            ---@param ctx nougat_bar_ctx
            content = function(_, ctx)
                return ("%s%s"):format(defaults.icons.misc.table, require("schema-companion.context").get_buffer_schema(ctx.bufnr).name):sub(0, 128)
            end,
            ---@param ctx nougat_bar_ctx
            hidden = function(_, ctx)
                if vim.tbl_contains({ "yaml", "helm" }, vim.api.nvim_get_option_value("filetype", { buf = ctx.bufnr })) then
                    return require("schema-companion.context").get_buffer_schema(ctx.bufnr).name == "none"
                end

                return true
            end,
            prefix = " ",
            suffix = " ",
            hl = {
                bg = colors.black.base,
                fg = colors.white.base,
            },
            sep_left = sep.left_lower_triangle_solid(true),
        })

        local wordcount = require("nougat.nut.buf.wordcount").create({
            config = {
                format = function(count)
                    return string.format("%d Word%s", count, count > 1 and "s" or "")
                end,
            },
            ---@param ctx nougat_bar_ctx
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
            hidden = function()
                return ai:open()
            end,
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
            { white_left_triangle(schema), schema },
            { white_left_triangle(codecompanion), codecompanion },
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
    event = ev.UIEnter,
}
