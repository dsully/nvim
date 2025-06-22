---@type LazySpec
return {
    "folke/noice.nvim",
    cmd = {
        "Noice",
        "NoiceDismiss",
    },
    event = ev.VeryLazy,
    highlights = {
        NoiceFormatProgressDone = { bg = colors.black.dim, fg = colors.white.bright },
        NoiceFormatProgressTodo = { bg = colors.black.dim, fg = colors.white.bright },
        NoiceLspProgressClient = { fg = colors.blue.base },
        NoiceLspProgressSpinner = { fg = colors.cyan.bright },
        NoiceLspProgressTitle = { fg = colors.white.bright },
        NoiceSplit = { bg = colors.bg, fg = colors.white.dim },
        NoiceVirtualText = { bg = colors.bg, fg = colors.blue.base },
    },
    -- stylua: ignore
    keys = {
        { "<leader>fN", function() vim.cmd.Noice("pick") end, desc = "Noice" },
    },
    ---@module "noice"
    ---@type NoiceConfig
    opts = {
        cmdline = {
            enabled = vim.g.noice,
            format = {
                git = { pattern = { "^:Gitsigns%s+", "^:Neogit%s+", "^:GitLink%s+" }, icon = " ", lang = "vim", title = " git " },
                input = { icon = " ", lang = "text", view = "cmdline_popup", title = "" },
                read = { pattern = "^:%s*r!", icon = "$", lang = "bash" },
                session = { pattern = { "^:Session%s+" }, icon = " ", lang = "vim", title = " session " },
                substitute = { pattern = "^:%%?s/", icon = " ", ft = "regex", title = "" },
                error = {
                    conceal = false,
                    pattern = "^:vim%.",
                    icon = "",
                    icon_hl_group = "Error",
                    lang = "",
                },
            },
        },
        lsp = {
            hover = {
                enabled = true,
                silent = false, -- set to true to not show a message if hover is not available
                ---@type NoiceViewOptions
                opts = {
                    border = {
                        style = defaults.ui.border.name,
                    },
                    position = { row = 2, col = 2 },
                },
            },
            override = {
                ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
                ["vim.lsp.util.stylize_markdown"] = true,
                ["cmp.entry.get_documentation"] = false,
            },
            progress = {
                enabled = true,
                -- Don't show the language server client (eg: rust-analyzer)
                --- @type NoiceFormat|string
                format = {
                    {
                        "{progress} ",
                        key = "progress.percentage",
                        contents = {
                            { "{data.progress.message} " },
                        },
                    },
                    "({data.progress.percentage}%) ",
                    { "{spinner} ", hl_group = "NoiceLspProgressSpinner" },
                    { "{data.progress.title} ", hl_group = "NoiceLspProgressTitle" },
                },
                --- @type NoiceFormat|string
                format_done = {
                    { "✔ ", hl_group = "NoiceLspProgressSpinner" },
                    { "{data.progress.title} ", hl_group = "NoiceLspProgressTitle" },
                },
            },
            signature = {
                auto_open = { enabled = false },
            },
        },
        messages = {
            enabled = vim.g.noice,
        },
        notify = {
            enabled = true,
        },
        popupmenu = {
            enabled = true,
            backend = "nui",
            kind_icons = true,
        },
        ---@type NoicePresets
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

                        -- Noisy render-markdown
                        { find = "Conversion failed at step" },

                        -- Only show progress on multiple of 5 percent.
                        { find = "[^05]/", event = "lsp", kind = "progress" },

                        {
                            event = "lsp",
                            kind = "progress",
                            cond = function(message)
                                return vim.tbl_contains(defaults.ignored.progress, vim.tbl_get(message.opts, "progress", "client"))
                            end,
                        },
                        { find = "cargo clippy", event = "lsp", kind = "progress" },
                    },
                },
                opts = { skip = true },
            },

            -- Redirect to pop-up when message is long
            {
                filter = {
                    any = {
                        { find = "Treesitter" },
                        -- Show cmdline output for :nmap <key> and similar.
                        { cmdline = true, find = "nmap", event = "msg_show", kind = { "list_cmd", "echo" } },
                    },
                },
                view = "popup",
            },

            -- Redirect to mini view.
            {
                filter = {
                    any = {
                        -- Send Ctrl-G to the mini view.
                        { find = '" %d+ lines --', event = "msg_show" },

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

                        -- Route chezmoi updates
                        { find = "chezmoi:", event = "notify" },
                    },
                },
                view = "mini",
            },
        },
        signature = {
            enabled = false,
        },
        ---@type NoiceConfigViews
        views = {
            mini = {
                format = { "{title} ", "{message}" }, -- leave out "{level}"
                position = {
                    -- Position it 2 rows from the bottom (1 for statusline, 1 for cmdheight)
                    row = vim.g.noice and -2 or -1,
                },
                zindex = 10,
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
    opts_extend = {
        "routes",
    },
}
