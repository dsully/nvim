return {
    {
        "willothy/nvim-cokeline",
        config = function()
            local icons = defaults.icons

            local mappings = require("cokeline.mappings")
            local map = require("helpers.keys").map

            for i = 1, 9 do
                -- stylua: ignore
                map("<leader>" .. i, function() mappings.by_index('focus', i) end, "which_key_ignore")

                -- Allow Option-N in terminals.
                -- stylua: ignore
                map(string.format("<M-%d>", i), function() mappings.by_index("focus", i) end, "which_key_ignore")
            end

            ---@type Component[]
            local components = {
                space = {
                    text = " ",
                    truncation = { priority = 1 },
                },

                separator = {
                    ---@param buffer Buffer
                    text = function(buffer)
                        return buffer.index == 1 and " " or " " .. icons.separators.bar.left
                    end,
                    bg = "TabLineFill",
                    truncation = { priority = 1 },
                },

                devicon = {
                    ---@param buffer Buffer
                    text = function(buffer)
                        return buffer.devicon.icon
                    end,
                    ---@param buffer Buffer
                    fg = function(buffer)
                        return buffer.devicon.color
                    end,
                    italic = function(_)
                        return mappings.is_picking_focus() or mappings.is_picking_close()
                    end,
                    bold = function(_)
                        return mappings.is_picking_focus() or mappings.is_picking_close()
                    end,
                    truncation = { priority = 1 },
                },

                idx = {
                    ---@param buffer Buffer
                    text = function(buffer)
                        return buffer.index .. ": "
                    end,
                    truncation = { priority = 1 },
                },

                unique_prefix = {
                    ---@param buffer Buffer
                    text = function(buffer)
                        return buffer.unique_prefix
                    end,
                    fg = "Comment",
                    style = "italic",
                    truncation = {
                        priority = 3,
                        direction = "left",
                    },
                },

                filename = {
                    ---@param buffer Buffer
                    text = function(buffer)
                        return buffer.filename
                    end,
                    ---@param buffer Buffer
                    bold = function(buffer)
                        return buffer.is_focused
                    end,
                    ---@param buffer Buffer
                    underline = function(buffer)
                        return buffer.is_hovered and not buffer.is_focused
                    end,
                    ---@param buffer Buffer
                    fg = function(buffer)
                        --
                        -- Don't show diagnostics for non-project buffers.
                        if not buffer.path:find(tostring(vim.uv.cwd()), 1, true) then
                            return
                        end

                        if buffer.diagnostics.errors ~= 0 then
                            return "DiagnosticError"
                        elseif buffer.diagnostics.warnings ~= 0 then
                            return "DiagnosticWarn"
                        elseif buffer.diagnostics.infos ~= 0 then
                            return "DiagnosticInfo"
                        end
                    end,
                    truncation = {
                        priority = 2,
                        direction = "left",
                    },
                },

                close_or_unsaved = {
                    ---@param buffer Buffer
                    text = function(buffer)
                        if buffer.is_hovered then
                            return buffer.is_modified and icons.misc.modified or icons.actions.close_round
                        else
                            return buffer.is_modified and icons.misc.modified or icons.actions.close
                        end
                    end,
                    bold = true,
                    delete_buffer_on_left_click = true,
                    ---@param buffer Buffer
                    fg = function(buffer)
                        return buffer.is_modified and "DiagnosticOk" or nil
                    end,
                    truncation = { priority = 1 },
                },
            }

            require("cokeline").setup({
                components = {
                    components.separator,
                    components.space,
                    components.devicon,
                    components.space,
                    components.idx,
                    components.unique_prefix,
                    components.filename,
                    components.space,
                    components.close_or_unsaved,
                    components.space,
                },
            })
        end,
        event = ev.LazyFile,
        keys = {
            {
                "<leader>bd",
                function()
                    local current = require("cokeline.buffers").get_current()

                    if current then
                        current:delete()
                    end
                end,
                desc = "Delete Buffer",
            },
        },
    },
    {
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
    },
    {
        "folke/noice.nvim",
        cmd = { "Noice", "NoiceDismiss" },
        event = ev.VeryLazy,
        init = function()
            hl.apply({
                { NoiceFormatProgressDone = { bg = colors.black.dim, fg = colors.white.bright } },
                { NoiceFormatProgressTodo = { bg = colors.black.dim, fg = colors.white.bright } },
                { NoiceLspProgressClient = { fg = colors.blue.base } },
                { NoiceLspProgressSpinner = { fg = colors.cyan.bright } },
                { NoiceLspProgressTitle = { fg = colors.white.bright } },
                { NoiceVirtualText = { fg = colors.blue.base } },
            })
        end,
        -- stylua: ignore
        keys = {
            { "<leader>fN", function() vim.cmd.Noice("pick") end, desc = "Noice" },
        },
        opts = {
            cmdline = {
                format = {
                    git = { pattern = { "^:Gitsigns%s+", "^:Neogit%s+", "^:GitLink%s+" }, icon = " ", lang = "vim", title = " git " },
                    input = { icon = " ", lang = "text", view = "cmdline_popup", title = "" },
                    read = { pattern = "^:%s*r!", icon = "$", lang = "bash" },
                    session = { pattern = { "^:Session%s+" }, icon = " ", lang = "vim", title = " session " },
                    substitute = { pattern = "^:%%?s/", icon = " ", ft = "regex", title = "" },
                },
            },
            lsp = {
                override = {
                    ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
                    ["vim.lsp.util.stylize_markdown"] = true,
                    ["cmp.entry.get_documentation"] = false,
                },
                progress = {
                    enabled = true,
                },
                signature = {
                    auto_open = { enabled = false },
                },
            },
            messages = { enabled = true, view = "mini", view_warn = "mini" },
            notify = { enabled = true },
            popupmenu = {
                enabled = true,
                backend = "nui",
                kind_icons = true,
            },
            presets = {
                bottom_search = true, -- use a classic bottom cmdline for search
                command_palette = false, -- position the cmdline and popupmenu together
                long_message_to_split = true, -- long messages will be sent to a split
                lsp_doc_border = false,
            },
            ---@type NoiceRouteConfig[]
            routes = {
                {
                    filter = {
                        any = {
                            -- Yank / undo noise
                            { find = "%d+ more line", event = "msg_show" },
                            { find = "%d+ line less", event = "msg_show" },
                            { find = "%d+ fewer lines", event = "msg_show" },

                            { find = "^%d+ change[s]?; before #%d+" },
                            { find = "^%d+ change[s]?; after #%d+" },
                            { find = "^%-%-No lines in buffer%-%-$" },

                            -- Ignored swap file.
                            { find = "W325:" },

                            -- Unneeded info on search patterns
                            { find = "^[/?].", event = "msg_show" },

                            -- When "Noice pick" doesn't have any entries.
                            { find = "No message found for entry" },

                            -- When I'm offline, and Copilot wants to connect.
                            { find = "getaddrinfo", event = "msg_show" },

                            -- Ignore deprecated messages from plugins.
                            { find = "vim.lsp.get_active_clients", event = "msg_show" },

                            -- Ignore useless messages
                            { find = "method textDocument/codeLens is not supported" },
                            { find = "Invalid offset" },
                            { find = "Invalid buffer id" },
                            { find = "Found a swap file by the name" },
                            { find = "An error happened while handling a ui event" }, -- Coming from noice.
                            { find = "multiple different client offset_encodings detected" },
                            { find = "offset_encoding is required" },
                            { find = "No information available", event = "notify" },

                            -- Semantic Tokens failure in the neovim runtime.
                            { find = "index out of range" },

                            -- Only show progress on multiple of 5 percent.
                            { find = "[^05]/", event = "lsp", kind = "progress" },

                            -- lua-ls is noisy.
                            { find = "Diagnosing", event = "lsp", kind = "progress" },
                            { find = "code_action", event = "lsp" },
                            {
                                event = "lsp",
                                kind = "progress",
                                cond = function(message)
                                    return vim.tbl_contains(defaults.ignored.progress, vim.tbl_get(message.opts, "progress", "client"))
                                end,
                            },
                            { find = "cargo clippy", event = "lsp", kind = "progress" },
                            {
                                event = "lsp",
                                cond = function(message)
                                    local content = message:content()
                                    local skipped = {
                                        ["unknown command"] = true,
                                        ["Ruff encountered a problem"] = true,
                                    }

                                    return vim.bo[vim.api.nvim_get_current_buf()].filetype == "python" and skipped[content] or false
                                end,
                            },
                        },
                    },
                    opts = { skip = true },
                },

                -- Redirect to pop-up when message is long
                {
                    filter = {
                        any = {
                            { min_height = 10 },
                            { find = "Treesitter" },
                        },
                    },
                    view = "popup",
                },

                -- Redirect to mini view.
                {
                    filter = {
                        any = {
                            -- "Not an editor command"
                            { find = "^E492:", event = "msg_show" },

                            -- Write/deletion messages
                            { find = "%d+B written$", event = "msg_show" },
                            { find = "%d+L, %d+B$", event = "msg_show" },
                            { find = "%-%-No lines in buffer%-%-", event = "msg_show" },

                            -- Yank messages
                            { find = "%d+ lines yanked", event = "msg_show" },

                            -- Unneeded info on search patterns
                            { find = "^E486: Pattern not found", event = "msg_show" },

                            -- Word added to spellfile via `zg`
                            { find = "^Word .*%.add$", event = "msg_show" },

                            -- Diagnostics
                            { find = "No more valid diagnostics to move to", event = "msg_show" },
                            { find = "No code actions available" },

                            -- Route nvim-treesitter to the mini view.
                            { find = "^%[nvim%-treesitter%]", event = "msg_show" },
                            { find = "All parsers are up%-to%-date", event = "msg_show" },

                            -- Route chezmoi updates
                            { find = "chezmoi:", event = "notify" },
                        },
                    },
                    view = "mini",
                },

                -- Warnings & Errors
                {
                    filter = {
                        any = {
                            { warning = true },
                            { event = "msg_show", find = "^Warn" },
                            { event = "msg_show", find = "^W%d+:" },
                            { event = "msg_show", find = "^No hunks$" },
                        },
                    },
                    opts = { title = "Warning", level = vim.log.levels.WARN, merge = false, replace = false },
                    view = "notify",
                },
                {
                    opts = { title = "" },
                    filter = { kind = { "emsg", "echo", "echomsg" } },
                    view = "notify",
                },
                {
                    filter = {
                        any = {
                            { error = true },
                            { event = "msg_show", find = "^Error" },
                            { event = "msg_show", find = "^E%d+:" },
                        },
                    },
                    opts = { title = "Error", replace = true, merge = true, level = vim.log.levels.ERROR },
                    view = "notify",
                },
            },
            ---@type NoiceConfigViews
            ---@diagnostic disable-next-line: missing-fields
            views = {
                mini = {
                    format = { "{title} ", "{message}" }, -- leave out "{level}"
                    zindex = 10,
                },
                notify = {
                    -- https://github.com/folke/noice.nvim/discussions/490
                    replace = true,
                },
                popupmenu = {
                    relative = "editor",
                    position = {
                        row = 9,
                        col = "50%",
                    },
                    size = {
                        width = 60,
                        height = 10,
                    },
                    border = {
                        style = defaults.ui.border.name,
                        padding = { 0, 1 },
                    },
                },
            },
        },
    },
    {
        "echasnovski/mini.icons",
        init = function()
            hl.apply({
                { MiniIconsAzure = { fg = colors.blue.bright } },
                { MiniIconsBlue = { fg = colors.blue.base } },
                { MiniIconsCyan = { fg = colors.cyan.base } },
                { MiniIconsGreen = { fg = colors.green.base } },
                { MiniIconsGrey = { fg = colors.gray.bright } },
                { MiniIconsOrange = { fg = colors.orange.base } },
                { MiniIconsPurple = { fg = colors.magenta.base } },
                { MiniIconsRed = { fg = colors.red.base } },
                { MiniIconsYellow = { fg = colors.yellow.base } },
            })

            package.preload["nvim-web-devicons"] = function()
                require("mini.icons").mock_nvim_web_devicons()
                return package.loaded["nvim-web-devicons"]
            end
        end,
        -- Can't be lazy so the nvim-web-devicons run time patching can happen early.
        lazy = false,
        opts = {
            style = "glyph",
            default = {
                extension = { glyph = " " },
                file = { glyph = " ", color = "#6F839E" },
                filetype = { glyph = " " },
            },
            filetype = {
                brewfile = { glyph = "🍺" },
            },
            file = {
                ["init.lua"] = { glyph = "󰢱 ", hl = "MiniIconsAzure" },
                ["package.json"] = { glyph = " ", hl = "MiniIconsGreen" },
                ["tsconfig.build.json"] = { glyph = " ", hl = "MiniIconsAzure" },
                ["tsconfig.json"] = { glyph = " ", hl = "MiniIconsAzure" },
                [".chezmoiignore"] = { glyph = " ", hl = "MiniIconsGrey" },
                [".chezmoiremove"] = { glyph = " ", hl = "MiniIconsGrey" },
                [".chezmoiroot"] = { glyph = " ", hl = "MiniIconsGrey" },
                [".chezmoiversion"] = { glyph = " ", hl = "MiniIconsGrey" },

                [".pre-commit-config.yaml"] = { glyph = "󰜘", color = "#eda73d" },
                [".pre-commit-hooks.yaml"] = { glyph = "󰜘", color = "#eda73d" },
                [".python-version"] = { glyph = "󰌠 ", color = "#ffe873" },
                [".ruff.toml"] = { glyph = "󱐋", color = "#fbc11a" },
                [".shellcheckrc"] = { glyph = " ", color = "#7ACECE" },
                [".yamllint"] = { glyph = "", color = "#fbc02d" },
                ["cargo.toml"] = { glyph = "󰏗 ", color = "#C27E42" },
                ["changelog.md"] = { glyph = "󰄴 ", color = "#99BE77" },
                ["go.mod"] = { glyph = " ", color = "#00ADD8" },
                ["go.sum"] = { glyph = " ", color = "#ec407a" },
                ["hosts"] = { glyph = " ", color = "#bbbbbb" },
                ["post-commit"] = { glyph = " ", color = "#f56b67" },
                ["post-receive"] = { glyph = " ", color = "#f56b67" },
                ["pre-commit"] = { glyph = " ", color = "#f56b67" },
                ["pre-push"] = { glyph = " ", color = "#f56b67" },
                ["pre-receive"] = { glyph = " ", color = "#f56b67" },
                ["pyproject.toml"] = { glyph = " ", color = "#4B8DDE" },
                ["readme.md"] = { glyph = "󰍔 ", color = "#69a3df" },
                ["requirements.txt"] = { glyph = " ", color = "#3572A5" },
                ["robots.txt"] = { glyph = "󰚩 " },
                ["ruff.toml"] = { glyph = "󱐋", color = "#fbc11a" },
                ["setup.py"] = { glyph = " ", color = "#4B8DDE" },
                ["sonar-project.properties"] = { glyph = "󰼮 ", color = "#CB2029" },
                ["tox.ini"] = { glyph = " ", color = "#b5c761" },
                ["yamllint.yaml"] = { glyph = "", color = "#fbc02d" },
            },
            extension = {
                cert = { glyph = "󰄤 ", color = "#3BD9DD" },
                crt = { glyph = "󰄤 " },
                env = { glyph = "󰙪 " },
                lock = { glyph = " ", color = "#eb4034" },
                log = { glyph = "󱞎 ", color = "#afb42b" },
                makefile = { glyph = " ", color = "#F54842" },
                out = { glyph = " " },
                properties = { glyph = " ", color = "#3970B4" },
                tmpl = { glyph = "󰈙 ", color = "#3970E4" },
            },
            lsp = defaults.icons.lsp,
        },
        virtual = true,
    },
    {
        "juansalvatore/git-dashboard-nvim",
        opts = {
            basepoints = { "master", "main" },
            branch = { "master", "main" },
            centered = false,
            colors = {
                branch_highlight = colors.yellow.base,
                dashboard_title = colors.cyan.bright,
                days_and_months_labels = colors.cyan.bright,
                empty_square_highlight = colors.cyan.bright,
                filled_square_highlights = { "#002c39", "#094d5b", "#387180", "#6098a7", colors.cyan.bright, "#c0faff" },
            },
            day_label_gap = "\t",
            hide_cursor = false,
            show_current_branch = true,
            use_git_username_as_author = true,
        },
    },
    {
        "goolord/alpha-nvim",
        config = function(_, dashboard)
            -- Close Lazy and re-open when the dashboard is ready
            if vim.o.filetype == "lazy" then
                vim.cmd.close()

                ev.on(ev.User, require("lazy").show, {
                    desc = "Close Lazy UI on dashboard load.",
                    pattern = "AlphaReady",
                    once = true,
                })
            end

            ev.on(ev.FileType, function()
                vim.opt_local.laststatus = 0
            end, {
                desc = "Hide tab line and status lines on startup screen.",
                once = true,
                pattern = "alpha",
            })

            ev.on(ev.BufUnload, function()
                vim.opt_local.laststatus = 3
            end, {
                buffer = 0,
                desc = "Re-enable status line.",
                once = true,
            })

            require("alpha").setup(dashboard.opts)

            ev.on(ev.User, function()
                local stats = require("lazy").stats()
                local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)

                dashboard.section.footer.val = "⚡ Loaded " .. stats.loaded .. "/" .. stats.count .. " plugins in " .. ms .. "ms"

                vim.cmd.AlphaRedraw()
            end, {
                desc = "Dashboard Footer Update",
                pattern = "LazyVimStarted",
            })
        end,
        cond = function()
            return vim.fn.argc() == 0
        end,
        event = ev.VimEnter,
        init = function()
            hl.apply({
                { AlphaHeader = { fg = colors.blue.bright } },
                { AlphaFooter = { fg = colors.blue.base } },
            })
        end,
        opts = function()
            ---@param c string
            local cmd = function(c)
                return string.format("<cmd>%s<cr>", c)
            end

            local startify = require("alpha.themes.theta")
            local dashboard = require("alpha.themes.dashboard")

            local heatmap = {
                type = "text",
                val = require("git-dashboard-nvim").heatmap(),
                opts = {
                    position = "center",
                },
            }

            local function button(lhs, txt, rhs, opts)
                lhs = lhs:gsub("%s", ""):gsub("SPC", "<leader>")

                local default_opts = {
                    position = "center",
                    shortcut = "[" .. lhs .. "] ",
                    cursor = 1,
                    width = 52,
                    align_shortcut = "right",
                    hl_shortcut = { { "Keyword", 0, 1 }, { "Function", 1, #lhs + 1 }, { "Keyword", #lhs + 1, #lhs + 2 } },
                    shrink_margin = false,
                    keymap = { "n", lhs, rhs, { noremap = true, silent = true, nowait = true } },
                }

                opts = vim.tbl_deep_extend("force", default_opts, opts or {})

                return {
                    type = "button",
                    val = string.format(" %-1s  %s", opts.icon or "", txt),
                    on_press = function()
                        keys.feed(rhs .. "<Ignore>", "t")
                    end,
                    opts = opts,
                }
            end

            local buttons = {
                type = "group",
                val = {
                    {
                        type = "text",
                        val = string.rep("─", 50),
                        opts = {
                            hl = "FloatBorder",
                            position = "center",
                        },
                    },
                    { type = "padding", val = 1 },
                    button("l", "Load Session        ", cmd("SessionLoad"), { icon = "󰁯 ", hl = { { "String", 1, 2 }, { "Normal", 3, 52 } } }),
                    button("n", "New File            ", cmd("ene <BAR> startinsert"), { icon = " ", hl = { { "Normal", 1, 2 }, { "Normal", 3, 52 } } }),
                    button("f", "Find File           ", cmd("FzfLua files"), { icon = "󰱼 ", hl = { { "Normal", 1, 2 }, { "Normal", 3, 52 } } }),
                    button("g", "Find Text           ", cmd("FzfLua live_grep"), { icon = " ", hl = { { "Normal", 1, 2 }, { "Normal", 3, 52 } } }),
                    button("p", "Profile Plugins     ", cmd("Lazy profile"), { icon = "󰁯 ", hl = { { "@comment.todo", 1, 2 }, { "Normal", 3, 52 } } }),
                    button("u", "Update Plugins      ", cmd("Lazy sync"), { icon = " ", hl = { { "Keyword", 1, 2 }, { "Normal", 3, 52 } } }),
                    button("q", "Quit Neovim         ", cmd("qa!"), { icon = " ", hl = { { "@text.strong", 1, 2 }, { "Normal", 3, 52 } } }),
                    {
                        type = "text",
                        val = string.rep("─", 50),
                        opts = {
                            hl = "FloatBorder",
                            position = "center",
                        },
                    },
                },
            }

            local mru = {
                type = "group",
                val = {
                    {
                        type = "text",
                        val = "[ Recent files ]",
                        opts = {
                            hl = "Function",
                            position = "center",
                        },
                    },
                    { type = "padding", val = 1 },
                    {
                        type = "group",
                        val = function()
                            return { startify.mru(1, vim.uv.cwd(), 7) }
                        end,
                    },
                    { type = "padding", val = 1 },
                },
            }

            dashboard.config.layout = {
                -- { type = "padding", val = vim.fn.max({ 2, vim.fn.floor(vim.fn.winheight(0) * 0.2) }) },
                { type = "padding", val = 2 },
                heatmap,
                mru,
                buttons,
                { type = "padding", val = 1 },
                dashboard.section.footer,
            }

            return dashboard
        end,
        priority = 5, -- Load after session manager.
    },
}
