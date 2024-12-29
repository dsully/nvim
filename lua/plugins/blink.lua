-- CompletionItem.data that rust-analyzer returns.
---@class RustCompletionImport
---@field full_import_path string
---@field imported_name string

---@class RustCompletionResolveData
---@field imports RustCompletionImport[]
---@field position lsp.TextDocumentPositionParams

---@alias RustData RustCompletionResolveData | nil

local function has_words_before()
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

---@param source string
---@return boolean
local is_ai_source = function(source)
    return vim.tbl_contains({ "copilot", "supermaven" }, source:lower())
end
return {
    { "giuxtaposition/blink-cmp-copilot" },
    {
        "Saghen/blink.cmp",
        build = "cargo build --release",
        config = function(_, opts)
            require("blink.cmp").setup(opts)

            -- Remove Copilot ghost text when the cmp menu is opened.
            ev.on_load("copilot", function()
                vim.schedule(function()
                    local cmp = require("blink.cmp")

                    cmp.on_open(function()
                        require("copilot.suggestion").dismiss()
                        vim.api.nvim_buf_set_var(0, "copilot_suggestion_hidden", true)
                    end)

                    cmp.on_close(function()
                        vim.api.nvim_buf_set_var(0, "copilot_suggestion_hidden", false)
                    end)
                end)
            end)
        end,
        init = function()
            hl.apply({
                { BlinkCmpGhostText = { link = "Comment" } },
                { BlinkCmpMenu = { link = "Pmenu" } },
                { BlinkCmpMenuBorder = { link = "Pmenu" } },
                { BlinkCmpMenuSelection = { link = "PmenuSel" } },

                { BlinkCmpDoc = { bg = colors.black.dim, fg = colors.white.base } },
                { BlinkCmpDocBorder = { bg = colors.black.dim, fg = colors.gray.bright } },
                { BlinkCmpDocCursorLine = { link = "Visual" } },

                { BlinkCmpSignatureHelp = { bg = colors.black.base, fg = colors.white.base } },
                { BlinkCmpSignatureHelpBorder = { bg = colors.black.base, fg = colors.gray.bright } },
                { BlinkCmpSignatureHelpActiveParameter = { link = "LspSignatureActiveParameter" } },

                { BlinkCmpLabel = { fg = colors.white.bright } },
                { BlinkCmpLabelDeprecated = { fg = colors.gray.base, strikethrough = true } },
                { BlinkCmpLabelMatch = { bold = true, fg = colors.blue.base } },

                { BlinkCmpKind = { fg = colors.white.bright } },
                { BlinkCmpKindClass = { fg = colors.yellow.base } },
                { BlinkCmpKindColor = { link = "BlinkCmpKind" } },
                { BlinkCmpKindConstant = { fg = colors.orange.base } },
                { BlinkCmpKindConstructor = { fg = colors.yellow.base } },
                { BlinkCmpKindEnum = { fg = colors.yellow.base } },
                { BlinkCmpKindEnumMember = { fg = colors.cyan.base } },
                { BlinkCmpKindEvent = { fg = colors.magenta.base } },
                { BlinkCmpKindField = { fg = colors.blue.base } },
                { BlinkCmpKindFile = { link = "BlinkCmpKind" } },
                { BlinkCmpKindFolder = { link = "BlinkCmpKind" } },
                { BlinkCmpKindFunction = { fg = colors.magenta.base } },
                { BlinkCmpKindInterface = { fg = colors.yellow.base } },
                { BlinkCmpKindKeyword = { fg = colors.magenta.base } },
                { BlinkCmpKindMethod = { fg = colors.magenta.base } },
                { BlinkCmpKindModule = { fg = colors.blue.base } },
                { BlinkCmpKindOperator = { fg = colors.magenta.base } },
                { BlinkCmpKindProperty = { fg = colors.blue.base } },
                { BlinkCmpKindReference = { fg = colors.magenta.base } },
                { BlinkCmpKindSnippet = { fg = colors.white.base } },
                { BlinkCmpKindStruct = { fg = colors.yellow.base } },
                { BlinkCmpKindText = { link = "BlinkCmpKind" } },
                { BlinkCmpKindTypeParameter = { fg = colors.yellow.base } },
                { BlinkCmpKindUnit = { fg = colors.magenta.base } },
                { BlinkCmpKindValue = { fg = colors.blue.base } },
                { BlinkCmpKindVariable = { fg = colors.blue.base } },
            })
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

                    return "<esc>"
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
                kind_icons = defaults.icons.lsp,
                nerd_font_variant = "mono",
            },
            completion = {
                accept = {
                    auto_brackets = {
                        enabled = false,
                    },
                },
                documentation = {
                    window = {
                        border = defaults.ui.border.name,
                    },
                },
                ghost_text = {
                    enabled = true,
                },
                list = {
                    selection = function(ctx)
                        return ctx.mode == "cmdline" and "auto_insert" or "manual"
                    end,
                },
                menu = {
                    -- Don't auto-show the completion menu in commandline mode.
                    auto_show = function(ctx)
                        return ctx.mode ~= "cmdline" or not vim.tbl_contains({ "/", "?" }, vim.fn.getcmdtype())
                    end,
                    --- @type blink.cmp.Draw
                    draw = {
                        treesitter = { "lsp" },
                        columns = {
                            { "kind_icon", gap = 2 },
                            { "label", gap = 2 },
                            { "kind", gap = 2 },
                        },
                        --
                        -- Definitions for possible components to render. Each component defines:
                        --   ellipsis: whether to add an ellipsis when truncating the text
                        --   width: control the min, max and fill behavior of the component
                        --   text function: will be called for each item
                        --   highlight function: will be called only when the line appears on screen
                        components = {
                            kind_icon = {
                                ellipsis = true,
                                text = function(ctx)
                                    return select(1, require("mini.icons").get("lsp", ctx.kind))
                                end,
                                highlight = function(ctx)
                                    return select(2, require("mini.icons").get("lsp", ctx.kind))
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
                                text = function(ctx)
                                    return is_ai_source(ctx.item.source_name) and "Code" or ctx.kind
                                end,
                                highlight = function(ctx)
                                    return is_ai_source(ctx.item.source_name) and "BlinkCmpKindSnippet" or "BlinkCmpKind" .. ctx.kind
                                end,
                            },
                            label = {
                                width = {
                                    fill = true,
                                    max = 90,
                                },
                                --- @param ctx blink.cmp.DrawItemContext
                                text = function(ctx)
                                    --
                                    local ft = vim.bo.filetype

                                    if ft == "rust" then
                                        return require("helpers.completion").rust_format(ctx)
                                    end

                                    return ctx.label .. ctx.label_detail
                                end,
                                highlight = function(ctx)
                                    -- Label and label details
                                    local highlights = {
                                        { 0, #ctx.label, group = ctx.deprecated and "BlinkCmpLabelDeprecated" or "BlinkCmpLabel" },
                                    }

                                    if ctx.label_detail then
                                        table.insert(highlights, { #ctx.label, #ctx.label + #ctx.label_detail, group = "BlinkCmpLabelDetail" })
                                    end

                                    -- characters matched on the label by the fuzzy matcher
                                    for _, idx in ipairs(ctx.label_matched_indices) do
                                        table.insert(highlights, { idx, idx + 1, group = "BlinkCmpLabelMatch" })
                                    end

                                    return highlights
                                end,
                            },
                            source_name = {
                                width = {
                                    max = 30,
                                },
                                text = function(ctx)
                                    return ctx.source_name
                                end,
                                highlight = "BlinkCmpSource",
                            },
                        },
                    },
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
            sources = {
                -- Disable cmdline for now.
                cmdline = {},
                default = function()
                    local success, node = pcall(vim.treesitter.get_node)

                    if success and node and vim.tbl_contains({ "comment", "line_comment", "block_comment" }, node:type()) then
                        return {}
                    end

                    local copilot = package.loaded["copilot.suggestion"]
                    local is_visible = copilot and copilot.is_visible()

                    if vim.b.copilot_suggestion_auto_trigger or is_visible then
                        return {}
                    end

                    return {
                        "lazydev",
                        "lsp",
                        "path",
                        "snippets",
                        "copilot",
                        "codecompanion",
                    }
                end,
                -- Disable completion for markdown.
                min_keyword_length = function()
                    return vim.bo.filetype == "markdown" and 2 or 0
                end,
                -- Ignore
                per_filetype = {
                    gitcommit = {},
                    snacks_input = {},
                },
                providers = {
                    buffer = {
                        max_items = 4,
                        min_keyword_length = 4,
                        opts = {
                            -- Show completions from all buffers used within the last x minutes
                            get_bufnrs = function()
                                local mins = 15
                                local open_buffers = vim.fn.getbufinfo({ buflisted = 1, bufloaded = 1 })

                                local recent_buffers = vim.iter(open_buffers)
                                    :filter(function(buf)
                                        local recently_used = os.time() - buf.lastused < (60 * mins)
                                        return recently_used and vim.bo[buf.bufnr].buftype == ""
                                    end)
                                    :map(function(buf)
                                        return buf.bufnr
                                    end)
                                    :totable()

                                return recent_buffers
                            end,
                        },
                        score_offset = -3,
                    },
                    codecompanion = {
                        name = "CodeCompanion",
                        async = true,
                        module = "codecompanion.providers.completion.blink",
                        score_offset = 100,
                    },
                    copilot = {
                        name = "Copilot",
                        async = true,
                        module = "blink-cmp-copilot",
                        score_offset = 100,
                        async = true,
                    },
                    lazydev = {
                        name = "LazyDev",
                        module = "lazydev.integrations.blink",
                        -- Make lazydev completions top priority
                        score_offset = 100,
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
    },
    {
        "rafamadriz/friendly-snippets",
        lazy = false,
    },
    {
        "chrisgrieser/nvim-scissors",
        cmd = { "ScissorsAddNewSnippet", "ScissorsEditSnippet" },
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
