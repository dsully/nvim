-- CompletionItem.data that rust-analyzer returns.
---@class RustCompletionImport
---@field full_import_path string
---@field imported_name string

---@class RustCompletionResolveData
---@field imports RustCompletionImport[]
---@field position lsp.TextDocumentPositionParams

---@alias RustData RustCompletionResolveData | nil

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
        lazy = false,
        keys = {
            -- Inside a snippet, use backspace to remove the placeholder.
            { "<bs>", "<C-O>s", desc = "Remove Snippet Placeholder", mode = "s" },
            {
                "<C-e>",
                function()
                    local cmp = require("blink.cmp")
                    local copilot = require("copilot")

                    if vim.snippet.active() then
                        vim.snippet.stop()
                    elseif cmp.is_visible() then
                        cmp.hide()
                    elseif copilot.is_visible() then
                        copilot.dismiss()
                    end
                end,
                desc = "Hide Completion",
                mode = { "i", "c" },
            },
        },
        ---@type blink.cmp.Config
        opts = {
            appearance = {
                kind_icons = defaults.icons.lsp,
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
                    selection = "manual",
                },
                menu = {
                    --- @type blink.cmp.Draw
                    draw = {
                        treesitter = { "lsp" },
                        columns = {
                            { "kind_icon", gap = 1 },
                            { "label", "label_description", gap = 2 },
                            { "kind" },
                        },
                        --
                        -- Definitions for possible components to render. Each component defines:
                        --   ellipsis: whether to add an ellipsis when truncating the text
                        --   width: control the min, max and fill behavior of the component
                        --   text function: will be called for each item
                        --   highlight function: will be called only when the line appears on screen
                        components = {
                            kind_icon = {
                                ellipsis = false,
                                text = function(ctx)
                                    local icon = ctx.kind_icon
                                    --
                                    -- Give path completions a different set of icons.
                                    if ctx.item.source_name == "Path" then
                                        local fi, _ = require("mini.icons").get("file", ctx.item.label)

                                        if fi ~= nil then
                                            icon = fi
                                        end
                                    end

                                    if ctx.item.source_name == "Copilot" then
                                        return defaults.icons.misc.copilot
                                    end

                                    return icon .. ctx.icon_gap
                                end,
                                highlight = function(ctx)
                                    --
                                    if ctx.item.source_name == "Path" then
                                        local _, hl = require("mini.icons").get("file", ctx.item.label)

                                        if hl ~= nil then
                                            return hl
                                        end
                                    end

                                    return "BlinkCmpKind" .. ctx.kind
                                end,
                                width = {
                                    fill = true,
                                },
                            },

                            kind = {
                                ellipsis = false,
                                width = { fill = true },
                                text = function(ctx)
                                    if ctx.item.source_name == "Copilot" then
                                        return "Code"
                                    end

                                    return ctx.kind
                                end,
                                highlight = function(ctx)
                                    if ctx.item.source_name == "Copilot" then
                                        return "BlinkCmpKindSnippet"
                                    end

                                    return "BlinkCmpKind" .. ctx.kind
                                end,
                            },

                            label = {
                                width = {
                                    fill = true,
                                    max = 60,
                                },
                                text = function(ctx)
                                    -- Strip the `pub fn` prefix from Rust functions.
                                    -- Strip method & function parameters.
                                    -- if ctx.item.detail ~= nil then
                                    --     ctx.item.detail = ctx.item.detail:gsub("pub fn (.+)", "%1"):gsub("(.+)%(.+%)~", "%1()")
                                    --     ctx.item.detail = ctx.item.detail:gsub("pub async fn (.+)", "%1"):gsub("(.+)%(.+%)~", "%1()")
                                    --     ctx.item.detail = ctx.item.detail:gsub("pub unsafe fn (.+)", "%1"):gsub("(.+)%(.+%)~", "%1()")
                                    -- end

                                    return ctx.label .. ctx.label_detail
                                end,
                                highlight = function(ctx)
                                    -- label and label details
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

                            label_description = {
                                width = {
                                    max = 30,
                                },
                                text = function(ctx)
                                    return ctx.label_description
                                end,
                                highlight = "BlinkCmpLabelDescription",
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
            keymap = {
                preset = "enter",
                ["<Tab>"] = {
                    "select_next",
                    "snippet_forward",
                    "fallback",
                },
                ["<S-Tab>"] = { "select_prev", "fallback" },
                ["<C-j>"] = { "select_next", "fallback" },
                ["<C-k>"] = { "select_prev", "fallback" },
            },
            sources = {
                -- Disable cmdline for now.
                cmdline = {},
                default = function()
                    local node = vim.treesitter.get_node()

                    if node and vim.tbl_contains({ "comment", "line_comment", "block_comment" }, node:type()) then
                        return {}
                    end

                    local copilot = package.loaded["copilot.suggestion"]
                    local is_visible = copilot and copilot.is_visible()

                    if vim.b.copilot_suggestion_auto_trigger or is_visible then
                        return {}
                    end

                    return {
                        "lsp",
                        "path",
                        "snippets",
                        "lazydev",
                        "codecompanion",
                        -- "copilot",
                    }
                end,
                providers = {
                    codecompanion = {
                        name = "CodeCompanion",
                        module = "codecompanion.providers.completion.blink",
                        score_offset = 100,
                        async = true,
                    },
                    copilot = {
                        name = "Copilot",
                        module = "blink-cmp-copilot",
                        score_offset = 100,
                        async = true,
                    },
                    lazydev = {
                        name = "LazyDev",
                        module = "lazydev.integrations.blink",
                    },
                    -- Don't show LuaLS require statements when lazydev has items
                    lsp = {
                        name = "LSP",
                        fallbacks = { "lazydev" },
                    },
                    path = {
                        name = "Path",
                        opts = {
                            get_cwd = vim.uv.cwd,
                        },
                    },
                    snippets = {
                        name = "Snippets",
                        --- Disable the snippet provider after pressing trigger characters (i.e. ".")
                        enabled = function(ctx)
                            return ctx ~= nil and ctx.trigger.kind == vim.lsp.protocol.CompletionTriggerKind.TriggerCharacter
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
                        if item.kind == require("blink.cmp.types").CompletionItemKind.Snippet then
                            item.score_offset = item.score_offset - 3
                        end
                    end

                    ---@param item blink.cmp.CompletionItem
                    return vim.tbl_filter(function(item)
                        --
                        if item.kind == types.Text or item.deprecated then
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
