---@param source string
---@return boolean
local is_ai_source = function(source)
    return vim.tbl_contains(vim.tbl_keys(defaults.ai), source:lower())
end

---@type LazySpec[]
return {
    {
        "Saghen/blink.cmp",
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
            appearance = {
                kind_icons = defaults.icons.completion_items,
                nerd_font_variant = "mono",
            },
            cmdline = {
                completion = {
                    menu = {
                        auto_show = function()
                            return vim.fn.getcmdtype() == ":" or vim.fn.getcmdtype() == "@"
                        end,
                    },
                },
                keymap = {
                    preset = "enter",
                    -- TODO: Get this behaviour for <tab>:
                    -- 1. If no menu then open it.
                    -- 2. If menu:
                    --   1. If there are multiple options: select the next one.
                    --   2. If there is only one entry: select it and confirm the selection
                    ["<Tab>"] = { "show", "select_next", "select_and_accept" },
                },
            },
            completion = {
                accept = {
                    auto_brackets = {
                        enabled = true,
                    },
                },
                ---@type blink.cmp.CompletionDocumentationConfig
                documentation = {
                    auto_show = true,
                    auto_show_delay_ms = 100,
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
                menu = {
                    -- Which directions to show the window, falling back to the next direction when there's not enough space
                    direction_priority = { "n", "s" },
                    --- @type blink.cmp.Draw
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
                default = { "lsp", "path", "snippets", "env" },
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
                -- Ignore
                per_filetype = {
                    codecompanion = {
                        "codecompanion",
                    },
                    gitcommit = {
                        "conventional_commits",
                    },
                    snacks_input = {},
                    toml = {
                        "crates",
                        "lsp",
                        "path",
                    },
                    lua = {
                        "lazydev",
                        "lsp",
                        "path",
                        -- "snippets",
                    },
                },
                providers = {
                    buffer = {
                        max_items = 4,
                        min_keyword_length = 4,
                        score_offset = -3,
                    },
                    conventional_commits = {
                        name = "Conventional Commits",
                        module = "blink-cmp-conventional-commits",
                        enabled = function()
                            return vim.bo.filetype == "gitcommit"
                        end,
                    },
                    env = {
                        name = "Env",
                        module = "blink-cmp-env",
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
            "completion.menu.draw.treesitter",
            "sources.default",
            "sources.per_filetype",
        },
        -- Get the current released version for the pre-compiled Rust fuzzy finder binary.
        version = "*",
    },
    { "Kaiser-Yang/blink-cmp-git" },
    { "bydlw98/blink-cmp-env" },
    { "disrupted/blink-cmp-conventional-commits" },
    { "saghen/blink.compat", opts = { impersonate_nvim_cmp = true } },
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
            editSnippetPopup = {
                border = defaults.ui.border.name,
            },
            jsonFormatter = "jq",
            snippetDir = vim.fn.stdpath("config") .. "/snippets",
        },
    },
}
