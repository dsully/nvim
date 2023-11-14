return {
    "MunifTanjim/nougat.nvim",
    config = function()
        local bar = require("nougat.bar")
        local core = require("nougat.core")
        local item = require("nougat.item")
        local sep = require("nougat.separator")
        local statusline = bar("statusline")

        local colors = require("config.defaults").colors
        local icons = require("config.defaults").icons

        local word_filetypes = {
            markdown = true,
            text = true,
            vimwiki = true,
        }

        local highlight = {
            inactive = {},
        }

        for _, kind in pairs({ "normal", "visual", "insert", "replace", "commandline", "terminal" }) do
            highlight[kind] = {
                bg = colors.cyan.base,
                fg = colors.black.base,
                bold = true,
            }
        end

        local mode = require("nougat.nut.mode").create({
            prefix = " ",
            suffix = " ",
            sep_right = sep.right_lower_triangle_solid(true),
            config = {
                highlight = highlight,
                text = require("config.defaults").statusline.modes,
            },
        })

        local white_right_lower_triangle = item({
            content = "",
            hl = { bg = colors.white.base },
            sep_right = sep.right_lower_triangle_solid(true),
        })

        local white_left_lower_triangle = item({
            hl = { bg = colors.white.base },
            sep_left = sep.left_lower_triangle_solid(true),
            suffix = " ",
        })

        local diagnostics = require("nougat.nut.buf.diagnostic_count").create({
            prefix = " ",
            suffix = " ",
            hl = { bg = colors.bg0 },
            config = {
                error = { prefix = icons.error, fg = colors.red.base },
                warn = { prefix = icons.warn, fg = colors.yellow.base },
                info = { prefix = icons.info, fg = colors.blue.bright },
                hint = { prefix = icons.hint, fg = colors.blue.bright },
            },
            sep_right = sep.right_lower_triangle_solid(true),
        })

        local filetype_icon = item({
            content = function()
                local dev, _ = require("nvim-web-devicons").get_icon(vim.api.nvim_buf_get_name(0))

                return dev and " " .. dev .. " " or " "
            end,
            hl = { bg = colors.bg0 },
        })

        local filetype_name = item({
            content = vim.bo.filetype,
            hl = { bg = colors.bg0, fg = colors.white.base },
            suffix = " ",
            sep_right = sep.right_lower_triangle_solid(true),
        })

        local git_status = require("nougat.nut.git.branch").create({
            config = { provider = "gitsigns" },
            hl = { bg = colors.bg0, fg = colors.white.base },
            prefix = "  ",
            sep_left = sep.left_lower_triangle_solid(true),
            suffix = " ",
        })

        local hl_search = item({
            content = function()
                local text = require("noice").api.status.search.get()
                local query = vim.F.if_nil(text:match("%/(.-)%s"), text:match("%?(.-)%s"))

                return string.format("󰍉  %s [%s]", query, text:match("%d+%/%d+"))
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
            prefix = " ",
        })

        local wordcount = require("nougat.nut.buf.wordcount").create({
            config = {
                format = function(count)
                    return string.format("%d Word%s", count, count > 1 and "s" or "")
                end,
            },
            hl = { bg = colors.bg0, fg = colors.white.base },
            sep_left = sep.left_lower_triangle_solid(true),
            prefix = " ",
            suffix = " ",
        })

        -- MODE
        statusline:add_item(mode)

        statusline:add_item({
            content = {
                white_right_lower_triangle,
                filetype_icon,
                filetype_name,
            },
            hidden = vim.bo.filetype == nil,
        })

        statusline:add_item({
            content = {
                white_right_lower_triangle,
                diagnostics,
            },
            hidden = require("nougat.nut.buf.diagnostic_count").hidden.if_zero,
        })

        statusline:add_item({
            content = {
                white_right_lower_triangle,
                hl_search,
            },
            hidden = function()
                return not package.loaded["noice"] or not require("noice").api.status.search.has()
            end,
        })

        statusline:add_item({
            content = {
                white_right_lower_triangle,
                navic,
            },
            hidden = function()
                return not package.loaded["nvim-navic"] or not require("nvim-navic").is_available()
            end,
        })

        -----------------------------------------------
        statusline:add_item(require("nougat.nut.spacer").create())
        statusline:add_item(require("nougat.nut.truncation_point").create())
        -----------------------------------------------

        statusline:add_item({
            content = {
                white_left_lower_triangle,
                git_status,
            },
            hidden = function()
                return not vim.g.gitsigns_head
            end,
        })

        statusline:add_item({
            content = {
                white_left_lower_triangle,
                wordcount,
            },
            hidden = function(_, ctx)
                return not word_filetypes[vim.api.nvim_get_option_value("filetype", { buf = ctx.bufnr })]
            end,
        })

        statusline:add_item(white_left_lower_triangle)

        statusline:add_item({
            hl = { bg = colors.bg0, fg = colors.white.base },
            sep_left = sep.left_lower_triangle_solid(true),
            content = table.concat({
                core.group({
                    core.code("l"),
                    "/",
                    core.code("L"),
                }, { align = "right", min_width = 8 }),
                core.group({
                    ":",
                    core.code("v"),
                }, { align = "left", min_width = 4 }),
                core.group({
                    core.code("P"),
                    " ",
                }, { align = "right", min_width = 5 }),
            }),
        })

        local stl_inactive = bar("statusline")

        stl_inactive:add_item(mode)
        stl_inactive:add_item(require("nougat.nut.spacer").create())

        require("nougat.bar.util").set_statusline(function(ctx)
            return ctx.is_focused and statusline or stl_inactive
        end)
    end,
    event = "VeryLazy",
}
