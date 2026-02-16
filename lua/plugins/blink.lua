---@param source string
---@return boolean
local is_ai_source = function(source)
    return vim.tbl_contains(vim.tbl_keys(defaults.ai.sources), source:lower())
end

ev.on(ev.User, function(ev)
    if ev.data.item.kind == require("blink.cmp.types").CompletionItemKind.path then
        vim.defer_fn(require("blink.cmp").show, 1)
    end
end, {
    desc = "Keep completing path on <Tab>",
    pattern = "BlinkCmpAccept",
})

---@type LazySpec[]
return {
    {
        "Saghen/blink.cmp",
        build = "cargo build --release",
        cmd = {
            "BlinkCmp",
        },
        event = { ev.CmdlineEnter, ev.InsertEnter },
        highlights = {
            BlinkCmpGhostText = { link = hl.Comment },
        },
        keys = {
            -- Inside a snippet, use backspace to remove the placeholder.
            { "<bs>", "<C-O>s", desc = "Remove Snippet Placeholder", mode = "s" },
        },

        ---@type blink.cmp.Config
        opts = {
            ---@type blink.cmp.AppearanceConfig
            appearance = {
                kind_icons = defaults.icons.completion_items,
                nerd_font_variant = "mono",
            },
            ---@type blink.cmp.ModeConfig
            cmdline = {
                completion = {
                    ghost_text = { enabled = false },
                    list = { selection = { preselect = false, auto_insert = false } },
                    menu = {
                        auto_show = function()
                            return vim.fn.getcmdtype() == ":" or vim.fn.getcmdtype() == "@"
                        end,
                    },
                },
                ---@type blink.cmp.KeymapConfig
                keymap = {
                    preset = "cmdline",
                    ["<CR>"] = { "accept", "fallback" },
                    ["<Tab>"] = { "show_and_insert", "select_next" },
                    ["<S-Tab>"] = { "show_and_insert", "select_prev" },
                    ["<Up>"] = { "select_prev", "fallback" },
                    ["<Down>"] = { "select_next", "fallback" },
                },
            },
            completion = {
                accept = {
                    auto_brackets = {
                        enabled = false,
                    },
                },
                ---@type blink.cmp.CompletionDocumentationConfig
                documentation = {
                    auto_show = true,
                },
                ghost_text = {
                    enabled = true,
                },
                list = {
                    selection = {
                        auto_insert = false,
                        preselect = false,
                    },
                },
                ---@type blink.cmp.CompletionMenuConfig
                menu = {
                    ---@type blink.cmp.WindowBorder
                    border = "none",

                    -- Which directions to show the window, falling back to the next direction when there's not enough space
                    direction_priority = { "n", "s" },
                    ---@type blink.cmp.Draw
                    draw = {
                        align_to = "cursor",
                        columns = {
                            { "kind_icon" },
                            { "label", gap = 1 },
                        },
                        -- Definitions for possible components to render. Each component defines:
                        --   ellipsis: whether to add an ellipsis when truncating the text
                        --   width: control the min, max and fill behavior of the component
                        --   text function: will be called for each item
                        --   highlight function: will be called only when the line appears on screen
                        components = {
                            kind_icon = {
                                ---@param ctx blink.cmp.DrawItemContext
                                highlight = function(ctx)
                                    return is_ai_source(ctx.item.source_name) and "MiniIconsBlue" or select(2, require("mini.icons").get("lsp", ctx.kind))
                                end,
                                ---@param ctx blink.cmp.DrawItemContext
                                text = function(ctx)
                                    -- Don't display an icon for cmdline.
                                    if vim.api.nvim_get_mode().mode == "c" then
                                        return ""
                                    end

                                    return defaults.icons.completion_items[ctx.item.source_name] or defaults.icons.completion_items[ctx.kind]
                                end,
                            },
                            kind = {
                                ---@param ctx blink.cmp.DrawItemContext
                                highlight = function(ctx)
                                    return is_ai_source(ctx.item.source_name) and "BlinkCmpKindSnippet" or "BlinkCmpKind" .. ctx.kind
                                end,
                                ---@param ctx blink.cmp.DrawItemContext
                                text = function(ctx)
                                    return is_ai_source(ctx.item.source_name) and ctx.item.source_name or ctx.kind
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
                                    fill = false,
                                },
                            },
                        },
                        treesitter = { "lsp" },
                    },
                    -- Keep the cursor X lines away from the top/bottom of the window
                    scrolloff = 4,
                },
                trigger = {
                    show_on_backspace = true,
                    show_on_backspace_in_keyword = true,
                },
            },
            fuzzy = {
                implementation = "rust",
                prebuilt_binaries = {
                    download = true,
                },
            },
            ---@type blink.cmp.KeymapConfig
            keymap = {
                preset = "enter",
                ["<Tab>"] = {
                    "select_next",
                    "snippet_forward",
                    "fallback",
                },
                ["<S-Tab>"] = {
                    "select_prev",
                    "snippet_backward",
                    "fallback",
                },
                ["<C-j>"] = { "select_next", "fallback" },
                ["<C-k>"] = { "select_prev", "fallback" },
                ["<C-y>"] = { "select_and_accept" },
                ["<A-d>"] = {
                    function()
                        -- Inspect the current completion item for debugging
                        vim.print(require("blink.cmp.completion.list").get_selected_item())
                        return true
                    end,
                },
            },
            ---@type blink.cmp.SnippetsConfig
            snippets = {
                preset = "default",
            },
            ---@type blink.cmp.SourceConfig
            sources = {
                default = { "lsp", "path", "env" },
                min_keyword_length = function(ctx)
                    if ctx.trigger.kind == "trigger_character" then
                        return 0
                    elseif ctx.trigger.kind == "manual" then
                        return 0
                    elseif ctx.mode == "cmdline" and string.find(ctx.line, " ") == nil then
                        return 3
                    else
                        return 2
                    end
                end,
                per_filetype = {
                    codecompanion = {
                        "codecompanion",
                    },
                    lua = {
                        "lsp",
                        "path",
                    },
                    snacks_input = {},
                    toml = {
                        "lsp",
                        "path",
                    },
                },
                providers = {
                    buffer = {
                        max_items = 4,
                        min_keyword_length = 4,
                        score_offset = -3,
                    },
                    env = {
                        name = "Env",
                        module = "blink-cmp-env",
                        enabled = function()
                            return vim.tbl_contains({ "bash", "fish", "zsh" }, vim.o.filetype)
                        end,
                    },
                    lsp = {
                        name = "LSP",
                        timeout_ms = 400,
                    },
                    nerdfont = {
                        module = "blink-nerdfont",
                        name = "Nerd Fonts",
                        score_offset = 15,
                        opts = { insert = true },
                        should_show_items = function()
                            return vim.tbl_contains({ "gitcommit", "markdown", "txt" }, vim.o.filetype)
                        end,
                    },
                    path = {
                        name = "Path",
                        -- Do not use `buffer` as fallback
                        fallbacks = {},
                        opts = {
                            get_cwd = nvim.file.cwd,
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
                            ---@diagnostic disable-next-line: inject-field
                            item.score_offset = (item.score_offset or 0) - 3
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
                            local data = item.data --[[@as RustData]]

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
        },
        opts_extend = {
            "completion.menu.draw.treesitter",
            "sources.default",
            "sources.per_filetype",
        },
    },
    { "bydlw98/blink-cmp-env" },
    { "MahanRahmati/blink-nerdfont.nvim" },
    { "xzbdmw/colorful-menu.nvim" },
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
            jsonFormatter = "jq",
            snippetDir = vim.fn.stdpath("config") .. "/snippets",
        },
    },
    {
        "Saghen/blink.indent",
        ft = {
            "python",
            "yaml",
            "yaml.*",
        },
        highlights = {
            BlinkIndent = { fg = colors.blue.bright },
        },
        opts = function()
            Snacks.toggle({
                name = "Indent",
                get = function()
                    return not require("blink.indent").is_enabled()
                end,
                set = function()
                    require("blink.indent").enable(not require("blink.indent").is_enabled())
                end,
            }):map("<space>tI")

            --- @type blink.indent.Config
            return {
                blocked = {
                    buftypes = defaults.ignored.buffer_types,
                    filetypes = defaults.ignored.file_types,
                },
                static = {
                    enabled = false,
                },
                scope = {
                    enabled = true,
                    char = "│",
                    priority = 1024,
                    highlights = { "BlinkIndent" },
                    underline = {
                        enabled = false,
                    },
                },
            }
        end,
    },
}
