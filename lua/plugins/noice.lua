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
        NoiceVirtualText = { fg = colors.blue.base },
    },
    -- stylua: ignore
    keys = {
        { "<leader>fN", function() vim.cmd.Noice("pick") end, desc = "Noice" },
    },
    ---@type NoiceConfig
    opts = {
        cmdline = {
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
            },
            signature = {
                auto_open = { enabled = false },
            },
        },
        messages = {
            enabled = true,
        },
        notify = {
            enabled = true,
            view = "notify",
            view_warn = "notify",
            view_error = "notify",
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
                        { event = "notify", max_height = 1 },

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
