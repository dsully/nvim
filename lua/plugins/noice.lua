return {
    "folke/noice.nvim",
    dependencies = { "MunifTanjim/nui.nvim" },
    event = "VeryLazy",
    config = function()
        local messages = false
        local mini_row = -2

        if messages then
            mini_row = -1
        end

        ---
        local focused = true
        vim.api.nvim_create_autocmd("FocusGained", {
            callback = function()
                focused = true
            end,
        })
        vim.api.nvim_create_autocmd("FocusLost", {
            callback = function()
                focused = false
            end,
        })

        vim.api.nvim_create_autocmd("FileType", {
            pattern = "markdown",
            callback = function(event)
                vim.schedule(function()
                    require("noice.text.markdown").keys(event.buf)
                end)
            end,
        })

        vim.keymap.set("c", "<S-Enter>", function()
            require("noice").redirect(vim.fn.getcmdline())
        end, { desc = "Redirect Cmdline" })

        vim.keymap.set("n", "<leader>vd", vim.cmd.NoiceDismiss, { desc = "Dismiss Messages" })
        vim.keymap.set("n", "<leader>vm", vim.cmd.Noice, { desc = "View Messages" })

        require("noice").setup({
            cmdline = {
                format = {
                    IncRename = { title = " Rename " },
                    input = { icon = " ", lang = "text", view = "cmdline_popup", title = "" },
                    read = { pattern = "^:%s*r!", icon = "$", lang = "bash" },
                    substitute = { pattern = "^:%%?s/", icon = " ", ft = "regex", title = "" },
                },
            },
            lsp = {
                documentation = {
                    enabled = true,
                    view = "hover",
                },
                hover = {
                    enabled = true,
                    opts = {
                        border = {
                            style = vim.g.border,
                        },
                    },
                },
                override = {
                    ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
                    ["vim.lsp.util.stylize_markdown"] = true,
                    ["cmp.entry.get_documentation"] = true,
                },
                progress = {
                    enabled = true,
                },
                signature = {
                    enabled = true,
                    auto_open = {
                        enabled = true,
                        trigger = true, -- Automatically show signature help when typing a trigger character from the LSP
                        luasnip = true, -- Will open signature help when jumping to LuaSnip insert nodes
                        throttle = 50, -- Debounce lsp signature help request by 50ms
                    },
                },
            },
            messages = {
                enabled = messages, -- enables the Noice messages UI
            },
            notify = {
                enabled = true,
            },
            popupmenu = {
                enabled = true,
                backend = "nui",
            },
            presets = {
                bottom_search = true, -- use a classic bottom cmdline for search
                command_palette = false, -- position the cmdline and popupmenu together
                long_message_to_split = true, -- long messages will be sent to a split
                inc_rename = true, -- enables an input dialog for inc-rename.nvim
                lsp_doc_border = true, -- add a border to hover docs and signature help
            },
            routes = {
                {
                    filter = {
                        any = {
                            { event = "msg_show", find = "%d+L, %d+B" }, -- Disable file write notifications.
                            { event = "msg_show", find = "^E486:" }, -- Pattern not found.
                            { event = "msg_show", find = "^E492:" }, -- Not an editor command.
                            { event = "msg_show", find = "%d+ change" }, -- Editor noisiness.
                            { event = "msg_show", find = "%d+ more line" }, -- Yank / undo noise.
                            { event = "msg_show", find = "%d+ line. less" }, -- Yank / undo noise.
                            { event = "msg_show", find = "bufnr=%d client_id=%d doesn't exists" },
                            { event = "msg_show", find = "%d+ lines yanked" },

                            { event = "msg_show", find = "written" },
                            { event = "msg_show", find = "%d+ lines, %d+ bytes" },
                            { event = "msg_show", kind = "search_count" },
                            { event = "msg_show", find = "search hit" },
                            { event = "msg_show", find = "^Hunk %d+ of %d" },
                            { event = "msg_show", find = "%d+ fewer lines" },
                            { event = "msg_show", find = "%d+ line" },
                            -- { find = "No active Snippet" },
                            -- { find = "No signature help available" },
                            -- { find = "Running provider" },
                            -- { find = "The coroutine failed with this message" },
                            -- { find = "^<$" },
                        },
                    },
                    opts = { skip = true },
                },
                {
                    -- Search messages.
                    filter = { find = "^[/?]" },
                    opts = { skip = true },
                    view = "cmdline",
                },
                {
                    filter = {
                        any = {
                            -- Only show progress on multiple of 5 percent.
                            { event = "lsp", find = "[^05]/" },
                            { event = "lsp", find = "code_action" },
                            {
                                event = "lsp",
                                kind = "progress",
                                cond = function(message)
                                    return vim.tbl_contains(require("config.ignored").progress, vim.tbl_get(message.opts, "progress", "client"))
                                end,
                            },
                            { event = "lsp", kind = "progress", find = "cargo clippy" },
                        },
                    },
                    opts = { skip = true },
                },
                {
                    filter = {
                        cond = function()
                            return not focused
                        end,
                    },
                    opts = { stop = false },
                    view = "notify_send",
                },
                {
                    filter = { error = true },
                    opts = { title = "Error", replace = true, merge = true, level = "error" },
                    view = "notify",
                },
            },
            views = {
                mini = {
                    position = {
                        row = mini_row,
                    },
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
        })
    end,
}
