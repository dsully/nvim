---@return boolean
local function has_words_before()
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

---@param source string
---@return boolean
local is_ai_source = function(source)
    return vim.tbl_contains({ "copilot", "supermaven" }, source:lower())
end

---@type LazySpec[]
return {
    {
        "Saghen/blink.cmp",
        build = "cargo build --release",
        event = ev.InsertEnter,
        init = function()
            hl.apply({
                { BlinkCmpGhostText = { link = hl.Comment } },
            })

            -- HACK: Workaround for the non-configurable snippet navigation mappings.
            -- From https://github.com/neovim/neovim/issues/30198#issuecomment-2326075321.
            -- (And yeah this is my fault).
            local snippet_expand = vim.snippet.expand

            ---@diagnostic disable-next-line: duplicate-set-field
            vim.snippet.expand = function(...)
                local tab_map = vim.fn.maparg("<Tab>", "i", false, true)
                local stab_map = vim.fn.maparg("<S-Tab>", "i", false, true)
                snippet_expand(...)

                vim.schedule(function()
                    tab_map.buffer, stab_map.buffer = 1, 1
                    vim.fn.mapset("i", false, tab_map)
                    vim.fn.mapset("i", false, stab_map)
                end)
            end
        end,
        keys = {
            -- Clear search and stop snippet on escape
            {
                "<esc>",
                function()
                    vim.cmd.nohlsearch()

                    if vim.snippet then
                        vim.snippet.stop()
                    end

                    return "<esc>" ---@diagnostic disable-line: redundant-return-value
                end,
                desc = "Escape and Clear hlsearch",
                expr = true,
                mode = { "c", "i", "n", "s" },
            },
            -- Inside a snippet, use backspace to remove the placeholder.
            { "<bs>", "<C-O>s", desc = "Remove Snippet Placeholder", mode = "s" },
        },
        ---@type blink.cmp.Config
        opts = {
            appearance = {
                kind_icons = defaults.icons.completion_items,
                nerd_font_variant = "mono",
            },
            completion = {
                documentation = {
                    window = {
                        border = defaults.ui.border.name,
                    },
                },
                ghost_text = {
                    enabled = true,
                },
                list = {
                    selection = {
                        ---@param ctx blink.cmp.Context
                        auto_insert = function(ctx)
                            return ctx.mode ~= "cmdline"
                        end,
                        ---@param ctx blink.cmp.Context
                        preselect = function(ctx)
                            return ctx.mode ~= "cmdline" and not require("blink.cmp").snippet_active({ direction = 1 })
                        end,
                    },
                },
                menu = {
                    -- Don't auto-show the completion menu in commandline mode.
                    ---@param ctx blink.cmp.Context
                    auto_show = function(ctx)
                        return ctx.mode ~= "cmdline" or not vim.tbl_contains({ "/", "?" }, vim.fn.getcmdtype())
                    end,
                    -- Which directions to show the window, falling back to the next direction when there's not enough space
                    direction_priority = { "n" },
                    --- @type blink.cmp.Draw
                    draw = {
                        columns = {
                            { "kind_icon" },
                            { "label", "kind", gap = 1 },
                        },
                        -- Definitions for possible components to render. Each component defines:
                        --   ellipsis: whether to add an ellipsis when truncating the text
                        --   width: control the min, max and fill behavior of the component
                        --   text function: will be called for each item
                        --   highlight function: will be called only when the line appears on screen
                        components = {
                            kind_icon = {
                                ellipsis = true,
                                ---@param ctx blink.cmp.DrawItemContext
                                text = function(ctx)
                                    return is_ai_source(ctx.item.source_name) and defaults.icons.completion_items[ctx.item.source_name]
                                        or defaults.icons.completion_items[ctx.kind]
                                end,
                                ---@param ctx blink.cmp.DrawItemContext
                                highlight = function(ctx)
                                    return is_ai_source(ctx.item.source_name) and "MiniIconsBlue" or select(2, require("mini.icons").get("lsp", ctx.kind))
                                end,
                                width = {
                                    fill = true,
                                },
                            },
                            kind = {
                                ellipsis = false,
                                width = {
                                    fill = true,
                                },
                                ---@param ctx blink.cmp.DrawItemContext
                                text = function(ctx)
                                    return is_ai_source(ctx.item.source_name) and "Code" or ctx.kind
                                end,
                                ---@param ctx blink.cmp.DrawItemContext
                                highlight = function(ctx)
                                    return is_ai_source(ctx.item.source_name) and "BlinkCmpKindSnippet" or "BlinkCmpKind" .. ctx.kind
                                end,
                            },
                            label = {
                                ---@param ctx blink.cmp.DrawItemContext
                                highlight = function(ctx)
                                    return require("colorful-menu").blink_components_highlight(ctx)
                                end,
                                ---@param ctx blink.cmp.DrawItemContext
                                text = function(ctx)
                                    return require("colorful-menu").blink_components_text(ctx)
                                end,
                                width = {
                                    fill = true,
                                    max = 90,
                                },
                            },
                        },
                    },
                    -- Keep the cursor X lines away from the top/bottom of the window
                    scrolloff = 4,
                },
            },
            enabled = function()
                return not vim.tbl_contains(defaults.ignored.file_types, vim.bo.filetype) and vim.bo.buftype ~= "prompt" and vim.b.completion ~= false
            end,
            ---@type blink.cmp.KeymapConfig
            keymap = {
                preset = "enter",
                ["<Tab>"] = {
                    "snippet_forward",
                    "select_next",
                    function(cmp)
                        if has_words_before() then
                            return cmp.show()
                        end
                    end,
                    "fallback",
                },
                ["<S-Tab>"] = {
                    "snippet_backward",
                    "select_prev",
                    "fallback",
                },
                ["<C-j>"] = { "select_next", "fallback" },
                ["<C-k>"] = { "select_prev", "fallback" },
                ["<C-y>"] = { "select_and_accept" },
            },
            snippets = {
                preset = "default",
            },
            sources = {
                default = { "lsp", "path", "snippets" },
                -- Ignore
                per_filetype = {
                    gitcommit = { "buffer" },
                    markdown = { "buffer" },
                    snacks_input = {},
                },
                providers = {
                    buffer = {
                        max_items = 4,
                        min_keyword_length = 4,
                        score_offset = -3,
                    },
                    lsp = {
                        name = "LSP",
                        -- Do not use `buffer` as fallback
                        fallbacks = {},
                        timeout_ms = 400,
                        ---@param ctx blink.cmp.Context
                        ---@param items blink.cmp.CompletionItem[]
                        transform_items = function(ctx, items)
                            --
                            local types = require("blink.cmp.types").CompletionItemKind
                            local is_word_only = string.match(ctx.line, "^%s+%w+$")
                            local ft = vim.bo[ctx.bufnr].filetype

                            -- Sort snippets lower.
                            for _, item in ipairs(items) do
                                if item.kind == types.Snippet then
                                    item.score_offset = item.score_offset - 3
                                end
                            end

                            ---@param item blink.cmp.CompletionItem
                            return vim.tbl_filter(function(item)
                                --
                                if item.kind == types.Text or item.kind == types.Snippet or item.deprecated then
                                    return false
                                end

                                if is_word_only and (item.kind == types.Function or item.kind == types.Variable) then
                                    return false
                                end

                                if ft == "rust" then
                                    ---@type RustData
                                    local data = item.data ---@diagnostic disable-line: assign-type-mismatch

                                    -- Only filter out imported methods.
                                    if data == nil or #data.imports == 0 or item.kind ~= types.Method then
                                        return true
                                    end

                                    for _, to_be_imported in ipairs(data.imports) do
                                        --
                                        -- Can be the crate name or a module name.
                                        for _, unwanted_prefix in ipairs({ "owo_colors" }) do
                                            if vim.startswith(to_be_imported.full_import_path, unwanted_prefix) then
                                                return false
                                            end
                                        end
                                    end
                                end

                                return true
                            end, items)
                        end,
                    },
                    path = {
                        name = "Path",
                        -- Do not use `buffer` as fallback
                        fallbacks = {},
                        opts = {
                            get_cwd = vim.uv.cwd,
                        },
                    },
                    snippets = {
                        name = "Snippets",
                        --- Disable the snippet provider after pressing trigger characters (i.e. ".")
                        ---@param ctx blink.cmp.Context
                        should_show_items = function(ctx)
                            return ctx.trigger.initial_kind ~= "trigger_character"
                        end,
                        opts = {
                            ignored_filetypes = defaults.ignored.file_types,
                        },
                    },
                },
            },
        },
        opts_extend = {
            "sources.default",
        },
    },
    { "saghen/blink.compat" },
    {
        "xzbdmw/colorful-menu.nvim",
        opts = {
            max_width = 90,
        },
    },
    {
        "chrisgrieser/nvim-scissors",
        cmd = {
            "ScissorsAddNewSnippet",
            "ScissorsEditSnippet",
        },
        keys = {
            { "<leader>Sa", vim.cmd.ScissorsAddNewSnippet, desc = "Add new snippet" },
            { "<leader>Se", vim.cmd.ScissorsEditSnippet, desc = "Add edit snippet" },
        },
        opts = {
            editSnippetPopup = {
                border = defaults.ui.border.name,
            },
            jsonFormatter = "jq",
            snippetDir = vim.fn.stdpath("config") .. "/snippets",
        },
    },
}
