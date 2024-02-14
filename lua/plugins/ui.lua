local e = require("helpers.event")

return {
    {
        -- "rcarriga/nvim-notify",
        "ls-devs/nvim-notify",
        branch = "fix/fix_index_value",
        -- stylua: ignore
        keys = {
            { "<leader>fn", function() vim.cmd.Telescope("notify") end, desc = "Notifications" },
            { "<leader>nd", function() require("notify").dismiss({ silent = true, pending = true }) end, desc = "Delete all Notifications" },
        },
        opts = {
            background_colour = "#2e3440",
            focusable = false,
            fps = 60,
            max_height = function()
                return math.floor(vim.o.lines * 0.75)
            end,
            -- max_width = 65,
            minimum_width = 65,
            render = "compact",
            timeout = 3000,
        },
    },
    {
        "akinsho/bufferline.nvim",
        config = function(_, opts)
            require("bufferline").setup(opts)

            -- Fix bufferline when restoring a session
            e.on(e.BufAdd, function()
                vim.schedule(function()
                    ---@diagnostic disable-next-line: undefined-global
                    pcall(nvim_bufferline)
                end)
            end)
        end,
        event = "VeryLazy",
        init = function()
            --
            for i = 1, 9 do
                vim.keymap.set("n", "<leader>" .. i, function()
                    require("bufferline").go_to(i, true)
                end, { desc = "which_key_ignore" })

                -- Allow Option-N in Wezterm.
                vim.keymap.set("n", string.format("<M-%d>", i), function()
                    require("bufferline").go_to(i, true)
                end, { desc = "which_key_ignore" })
            end

            -- Go to the last buffer.
            vim.keymap.set("n", "<leader>$", function()
                require("bufferline").go_to(-1, true)
            end, { desc = "which_key_ignore" })

            -- Always show tabs, but only load it if there is more than one.
            e.on({ e.BufAdd, e.TabEnter, e.VimEnter, e.WinEnter }, function()
                if #vim.fn.getbufinfo({ buflisted = 1 }) >= 2 then
                    require("lazy").load({ plugins = { "bufferline.nvim" } })
                end
            end)
        end,
        opts = {
            options = {
                always_show_bufferline = true,
                close_command = function(n)
                    require("mini.bufremove").delete(n, false)
                end,
                numbers = "ordinal",
                diagnostics = "nvim_lsp",
                show_buffer_close_icons = false,
                sort_by = "insert_at_end",
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

            local colors = require("config.defaults").colors
            local icons = require("config.defaults").icons
            local devicons = require("nvim-web-devicons")

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

            -- Renders a space only when item is rendered.
            local function paired_sep(def)
                return function(paired_item)
                    def.hidden = paired_item
                    return item(def)
                end
            end

            local white_right_lower_triangle = paired_sep({
                content = "",
                hl = { bg = colors.white.base },
                sep_right = sep.right_lower_triangle_solid(true),
            })

            local white_left_lower_triangle = paired_sep({
                hl = { bg = colors.white.base },
                sep_left = sep.left_lower_triangle_solid(true),
                stuffix = " ",
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
                hidden = require("nougat.nut.buf.diagnostic_count").hidden.if_zero(),
            })

            local filetype_icon = item({
                content = function()
                    local icon, icon_hl = devicons.get_icon(vim.api.nvim_buf_get_name(0))

                    if not icon then
                        icon, icon_hl = devicons.get_icon_by_filetype(vim.bo.filetype, { default = true })
                    end

                    local hl_name = "Statusline" .. icon_hl

                    vim.api.nvim_set_hl(0, hl_name, {
                        bg = colors.bg0,
                        fg = ("#%06x"):format(vim.api.nvim_get_hl(0, { name = icon_hl }).fg),
                    })

                    return string.format(" %%#%s#%s %%##", hl_name, icon or " ")
                end,
                hl = { bg = colors.bg0 },
            })

            local filetype_name = item({
                content = function()
                    return vim.bo.filetype
                end,
                hl = { bg = colors.bg0, fg = colors.white.base },
                suffix = " ",
                sep_right = sep.right_lower_triangle_solid(true),
            })

            local filetype = item({
                content = {
                    filetype_icon,
                    filetype_name,
                },
                hidden = vim.bo.filetype == nil,
            })

            local git_status = require("nougat.nut.git.branch").create({
                config = { provider = "gitsigns" },
                hidden = function()
                    return not vim.g.gitsigns_head
                end,
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
                hidden = function()
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
                hl = { bg = colors.bg0, fg = colors.white.base },
                sep_left = sep.left_lower_triangle_solid(true),
                prefix = " ",
                suffix = " ",
            })

            local counts = item({
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

            -- MODE
            statusline:add_item(mode)

            statusline:add_item(white_right_lower_triangle(filetype))
            statusline:add_item(filetype)

            statusline:add_item(white_right_lower_triangle(diagnostics))
            statusline:add_item(diagnostics)

            statusline:add_item(white_right_lower_triangle(hl_search))
            statusline:add_item(hl_search)

            statusline:add_item(white_right_lower_triangle(navic))
            statusline:add_item(navic)

            -----------------------------------------------
            statusline:add_item(require("nougat.nut.spacer").create())
            statusline:add_item(require("nougat.nut.truncation_point").create())
            -----------------------------------------------

            statusline:add_item(white_left_lower_triangle(git_status))
            statusline:add_item(git_status)

            statusline:add_item(white_left_lower_triangle(wordcount))
            statusline:add_item(wordcount)

            statusline:add_item(white_left_lower_triangle(counts))
            statusline:add_item(counts)

            local stl_inactive = bar("statusline")

            stl_inactive:add_item(mode)
            stl_inactive:add_item(require("nougat.nut.spacer").create())

            require("nougat").set_statusline(function(ctx)
                return ctx.is_focused and statusline or stl_inactive
            end)
        end,
        event = "VeryLazy",
    },
    {
        "folke/noice.nvim",
        cmd = { "Noice", "NoiceDismiss" },
        dependencies = { "MunifTanjim/nui.nvim" },
        event = "VeryLazy",
        -- stylua: ignore
        keys = {
            -- { "<S-Enter>", function() require("noice").redirect(vim.fn.getcmdline()) end, mode = "c", desc = "Redirect Cmdline" },
            { "<leader>vd", vim.cmd.NoiceDismiss, desc = "Dismiss Messages" },
            { "<leader>vm", vim.cmd.Noice, desc = "View Messages" },
            { "<leader>fN", function() vim.cmd.Noice("telescope") end, desc = "Noice" },
        },
        opts = {
            cmdline = {
                format = {
                    IncRename = { title = " Rename " },
                    input = { icon = " ", lang = "text", view = "cmdline_popup", title = "" },
                    read = { pattern = "^:%s*r!", icon = "$", lang = "bash" },
                    substitute = { pattern = "^:%%?s/", icon = " ", ft = "regex", title = "" },
                    session = { pattern = { "^:Session%s+" }, icon = "", lang = "vim", title = " session " },
                    git = { pattern = { "^:Gitsigns%s+", "^:Neogit%s+", "^:GitLink%s+" }, icon = "", lang = "vim", title = " git " },
                },
            },
            lsp = {
                documentation = { enabled = true },
                hover = { enabled = true },
                override = {
                    ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
                    ["vim.lsp.util.stylize_markdown"] = true,
                    ["cmp.entry.get_documentation"] = true,
                },
                progress = { enabled = true },
                signature = { enabled = false },
            },
            messages = { enabled = true },
            notify = { enabled = true },
            popupmenu = {
                enabled = true,
                backend = "nui",
            },
            presets = {
                bottom_search = true, -- use a classic bottom cmdline for search
                command_palette = false, -- position the cmdline and popupmenu together
                long_message_to_split = true, -- long messages will be sent to a split
                inc_rename = true, -- enables an input dialog for inc-rename.nvim
                lsp_doc_border = true,
            },
            routes = {
                {
                    filter = {
                        any = {
                            -- Yank / undo noise
                            { event = "msg_show", find = "%d+ more line" },
                            { event = "msg_show", find = "%d+ line less" },
                            { event = "msg_show", find = "%d+ fewer lines" },
                            -- { event = "msg_show", find = "%d+ lines yanked" },

                            { find = "^%d+ change[s]?; before #%d+" },
                            { find = "^%d+ change[s]?; after #%d+" },
                            { find = "^%-%-No lines in buffer%-%-$" },

                            -- { event = "msg_show", find = "bufnr=%d client_id=%d doesn't exists" },
                            -- { event = "msg_show", find = "^Hunk %d+ of %d" },

                            -- When I'm offline, and Copilot wants to connect.
                            { event = "msg_show", find = "getaddrinfo" },

                            -- Fix jedi bug https://github.com/pappasam/jedi-language-server/issues/296
                            { event = "msg_show", find = "^}$" },

                            -- Fix lsp signature bug
                            { event = "msg_show", find = "lsp_signature? handler RPC" },
                        },
                    },
                    opts = { skip = true },
                },

                -- Redirect to pop-up when message is long
                { filter = { min_height = 10 }, view = "popup" },

                -- "Not an editor command" to mini
                { filter = { event = "msg_show", find = "^E492:" }, view = "mini" },

                -- Write/deletion messages
                { filter = { event = "msg_show", find = "%d+B written$" }, view = "mini" },
                { filter = { event = "msg_show", find = "%d+L, %d+B$" }, view = "mini" },
                { filter = { event = "msg_show", find = "%-%-No lines in buffer%-%-" }, view = "mini" },

                -- Yank messages
                { filter = { event = "msg_show", find = "%d+ lines yanked" }, view = "mini" },

                -- Unneeded info on search patterns
                { filter = { event = "msg_show", find = "^[/?]." }, skip = true },
                { filter = { event = "msg_show", find = "^E486: Pattern not found" }, view = "mini" },

                -- Word added to spellfile via `zg`
                { filter = { event = "msg_show", find = "^Word .*%.add$" }, view = "mini" },

                -- Diagnostics
                { filter = { event = "msg_show", find = "No more valid diagnostics to move to" }, view = "mini" },

                -- Route nvim-treesitter to the mini view.
                { filter = { event = "msg_show", find = "^%[nvim%-treesitter%]" }, view = "mini" },
                { filter = { event = "notify", find = "All parsers are up%-to%-date" }, view = "mini" },

                {
                    filter = {
                        any = {
                            -- Only show progress on multiple of 5 percent.
                            { event = "lsp", kind = "progress", find = "[^05]/" },
                            -- lua-ls is noisy.
                            { event = "lsp", kind = "progress", find = "Diagnosing" },
                            { event = "lsp", find = "code_action" },
                            {
                                event = "lsp",
                                kind = "progress",
                                cond = function(message)
                                    return vim.tbl_contains(require("config.defaults").ignored.progress, vim.tbl_get(message.opts, "progress", "client"))
                                end,
                            },
                            { event = "lsp", kind = "progress", find = "cargo clippy" },
                        },
                    },
                    opts = { skip = true },
                },
                {
                    filter = { error = true },
                    opts = { title = "Error", replace = true, merge = true, level = "error" },
                    view = "notify",
                },
            },
            views = {
                mini = {
                    format = { "{title} ", "{message}" }, -- leave out "{level}"
                    zindex = 10,
                },
                notify = {
                    -- https://github.com/folke/noice.nvim/discussions/490
                    replace = true,
                    title = "",
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
                        style = vim.g.border,
                        padding = { 0, 1 },
                    },
                },
            },
        },
    },
    {
        "lukas-reineke/indent-blankline.nvim",
        ft = { "yaml" },
        main = "ibl",
        opts = {
            indent = {
                char = "│",
                tab_char = "│",
            },
            scope = { enabled = false },
        },
    },
    {
        "echasnovski/mini.indentscope",
        event = "LazyFile",
        init = function()
            e.on(e.FileType, function()
                vim.b.miniindentscope_disable = true
            end, {
                pattern = require("config.defaults").ignored.file_types,
            })
        end,
        opts = function()
            return {
                draw = {
                    animation = require("mini.indentscope").gen_animation.none(),
                },
                symbol = "│",
                options = { try_as_border = true },
            }
        end,
    },
    {
        -- Show hex colors as colors.
        "echasnovski/mini.hipatterns",
        event = "LazyFile",
        opts = function()
            return {
                highlighters = {
                    hex_color = require("mini.hipatterns").gen_highlighter.hex_color(),
                },
            }
        end,
    },
    {
        "nvim-tree/nvim-web-devicons",
        init = function()
            require("lazy.core.loader").disable_rtp_plugin("nvim-web-devicons")
        end,
        lazy = true,
        opts = {
            default = true,
            override = {
                brewfile = {
                    icon = "🍺",
                    name = "Brewfile",
                },
            },
        },
    },
    {
        "MunifTanjim/nui.nvim",
        lazy = true,
    },
    {
        "goolord/alpha-nvim",
        opts = function()
            local cmd = require("config.defaults").cmd
            local dashboard = require("alpha.themes.dashboard")

            dashboard.section.header.val = {
                [[                                                                       ]],
                [[                                                                     ]],
                [[       ████ ██████           █████      ██                     ]],
                [[      ███████████             █████                             ]],
                [[      █████████ ███████████████████ ███   ███████████   ]],
                [[     █████████  ███    █████████████ █████ ██████████████   ]],
                [[    █████████ ██████████ █████████ █████ █████ ████ █████   ]],
                [[  ███████████ ███    ███ █████████ █████ █████ ████ █████  ]],
                [[ ██████  █████████████████████ ████ █████ █████ ████ ██████ ]],
                [[                                                                       ]],
            }

            dashboard.section.header.opts.hl = "AlphaHeader"
            dashboard.section.footer.opts.hl = "AlphaFooter"

            dashboard.section.buttons.opts.spacing = 0
            dashboard.section.buttons.val = {
                dashboard.button("l", "󰁯  Load Session        ", cmd("SessionLoad")),
                dashboard.button("n", "  New File            ", cmd("ene <BAR> startinsert")),
                dashboard.button("r", "󰈢  Recently Opened     ", cmd("Telescope oldfiles")),
                dashboard.button("f", "󰈞  Find Files          ", cmd("Telescope find_files hidden=true path_display=smart")),
                dashboard.button("g", "  Find Text           ", cmd("Telescope live_grep")),
                dashboard.button("p", "󰓅  Profile Plugins     ", cmd("Lazy profile")),
                dashboard.button("u", "  Update Plugins      ", cmd("Lazy sync")),
                dashboard.button("q", "󰗼  Quit Neovim         ", cmd("qa!")),
            }

            dashboard.config.layout = {
                { type = "padding", val = vim.fn.max({ 2, vim.fn.floor(vim.fn.winheight(0) * 0.2) }) },
                dashboard.section.header,
                { type = "padding", val = 2 },
                {
                    type = "text",
                -- stylua: ignore
                val = {
                    "┌────────────   Today is " .. os.date("%a %d %b") .. " ────────────┐",
                    "│                                                │",
                    "└───══───══───══───  " .. os.date(" %H:%M") .. "  ───══───══───══────┘",
                },
                    opts = { position = "center" },
                },
                { type = "padding", val = 2 },
                dashboard.section.buttons,
                { type = "padding", val = 1 },
                dashboard.section.footer,
            }

            return dashboard
        end,
        config = function(_, dashboard)
            -- Close Lazy and re-open when the dashboard is ready
            if vim.o.filetype == "lazy" then
                vim.cmd.close()
                e.on(e.User, require("lazy").show, {
                    desc = "Close Lazy UI on dashboard load.",
                    pattern = "AlphaReady",
                })
            end

            e.on(e.FileType, function()
                vim.opt_local.laststatus = 0
            end, {
                desc = "Hide tab line and status lines on startup screen.",
                once = true,
                pattern = "alpha",
            })

            e.on(e.BufUnload, function()
                vim.opt_local.laststatus = 3
            end, {
                buffer = 0,
                desc = "Re-enable status line.",
                once = true,
            })

            require("alpha").setup(dashboard.opts)

            e.on(e.User, function()
                local stats = require("lazy").stats()
                local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)

                -- local version = vim.version()
                -- local v = ""
                --
                -- if version ~= nil then
                --     v = string.format("v%s.%s.%s ", version.major, version.minor, version.patch)
                -- end

                dashboard.section.footer.val = "⚡ Neovim loaded " .. stats.loaded .. "/" .. stats.count .. " plugins in " .. ms .. "ms"

                vim.cmd.AlphaRedraw()
            end, {
                desc = "Dashboard Footer Update",
                pattern = "LazyVimStarted",
            })
        end,
        cond = function()
            return vim.fn.argc() == 0
        end,
        event = "VimEnter",
        priority = 5, -- Load after session manager.
    },
    {
        "numToStr/FTerm.nvim",
        --stylua: ignore
        keys = {
            { [[<C-\>]], function() require("FTerm").toggle() end, mode = { "n", "t" }, desc = "Terminal  " },
        },
        opts = {
            hl = "Terminal",
        },
    },
    {
        "kosayoda/nvim-lightbulb",
        event = "LspAttach",
        opts = function()
            return {
                autocmd = {
                    enabled = true,
                },
                ignore = {
                    clients = require("config.defaults").ignored.lsp,
                },
                sign = {
                    enabled = true,
                    text = "󰌶",
                    hl = "LspDiagnosticsDefaultInformation",
                },
            }
        end,
    },
}
