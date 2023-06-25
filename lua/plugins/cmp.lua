local priorities = {
    Field = 11,
    Property = 11,
    Constant = 10,
    Enum = 10,
    EnumMember = 10,
    Event = 10,
    Function = 10,
    Method = 10,
    Operator = 10,
    Reference = 10,
    Struct = 10,
    Variable = 12,
    File = 8,
    Folder = 8,
    Class = 5,
    Color = 5,
    Module = 5,
    Keyword = 2,
    Constructor = 1,
    Interface = 1,
    Snippet = 0,
    Text = 1,
    TypeParameter = 1,
    Unit = 1,
    Value = 1,
}

local symbol_map = {
    cmp = {
        async_path = " [Path]",
        buffer = " [Buffer]",
        cmdline = "󰘳 [Command]",
        copilot = " [Copilot]",
        crates = " [📦 Crates]",
        dictionary = "󰂽 [Dictionary]",
        fish = "󰈺 [Fish]",
        git = "󰊢 [Git]",
        gh_issues = "[ GH]",
        jira_issues = "[ JIRA]",
        luasnip = "󰢱 [LuaSnip]",
        nvim_lsp = "󰈸 [LSP]",
        nvim_lsp_document_symbol = "󰎕 [LSP Symbol]",
        nvim_lsp_signature_help = " [LSP Help]",
        path = " [Path]",
        spell = " [Spelling]",
    },
    lsp = {
        Text = " ",
        Method = "󰆧 ",
        Function = "󰊕",
        Constructor = " ",
        Field = "󰠴 ",
        Variable = " ",
        Class = "󰌗 ",
        Interface = "󰜰",
        Module = "󰅩 ",
        Property = "󰖷",
        Unit = " ",
        Value = "󰎠 ",
        Enum = "󰕘",
        Keyword = "󰌋 ",
        Snippet = " ",
        Color = "󰏘 ",
        File = "󰈔",
        Reference = "󰈝",
        Folder = "󰉋 ",
        EnumMember = " ",
        Constant = "󰞂",
        Struct = "󰟦",
        Event = "",
        Operator = "󰃬",
        TypeParameter = "󰊄",
        Copilot = " ",
    },
}

return {
    "hrsh7th/nvim-cmp",
    cmd = "CmpStatus",
    config = function()
        local cmp = require("cmp")

        -- From: https://github.com/zbirenbaum/copilot-cmp#tab-completion-configuration-highly-recommended
        -- Unlike other completion sources, copilot can use other lines above or below an empty line to provide a completion.
        -- This can cause problematic for individuals that select menu entries with <TAB>. This behavior is configurable via
        -- cmp's config and the following code will make it so that the menu still appears normally, but tab will fallback
        -- to indenting unless a non-whitespace character has actually been typed.
        local has_words_before = function()
            if vim.api.nvim_get_option_value("buftype", { buf = 0 }) == "prompt" then
                return false
            end
            local line, col = unpack(vim.api.nvim_win_get_cursor(0))
            return col ~= 0 and vim.api.nvim_buf_get_text(0, line - 1, 0, line - 1, col, {})[1]:match("^%s*$") == nil
        end

        local format = {
            cmdline = {
                format = function(_, item)
                    item.kind = ""
                    item.menu = ""
                    item.dup = 0
                    return item
                end,
            },
            normal = {
                format = require("lspkind").cmp_format({
                    maxwidth = 50,
                    mode = "symbol_text",
                    -- menu = symbol_map.cmp,
                    symbol_map = symbol_map.lsp,
                }),
            },
        }

        cmp.setup({
            enabled = function()
                local context = require("cmp.config.context")

                if vim.api.nvim_get_option_value("buftype", { buf = 0 }) == "prompt" then
                    return false
                end

                return not (context.in_treesitter_capture("comment") == true or context.in_syntax_group("Comment"))
            end,
            formatting = format.normal,
            mapping = cmp.mapping.preset.insert({
                ["<C-c>"] = cmp.mapping.abort(),
                ["<C-Space>"] = cmp.mapping.complete(),
                ["<C-j>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
                ["<C-k>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),
                ["<CR>"] = cmp.mapping.confirm({ select = true, behavior = cmp.ConfirmBehavior.Insert }),
                ["<Tab>"] = cmp.mapping(function(fallback)
                    local luasnip = require("luasnip")
                    local neogen = require("neogen")

                    if luasnip.expand_or_locally_jumpable() then
                        luasnip.expand_or_jump()
                    elseif neogen.jumpable() then
                        neogen.jump_next()
                    elseif cmp.visible() and has_words_before() then
                        cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
                    else
                        fallback()
                    end
                end),
                ["<S-Tab>"] = cmp.mapping(function(fallback)
                    local luasnip = require("luasnip")

                    if luasnip.jumpable(-1) then
                        luasnip.jump(-1)
                    elseif cmp.visible() and has_words_before() then
                        cmp.select_prev_item()
                    else
                        fallback()
                    end
                end),
            }),
            matching = {
                disallow_fuzzy_matching = true,
                disallow_fullfuzzy_matching = true,
                disallow_partial_fuzzy_matching = true,
                disallow_partial_matching = true,
                disallow_prefix_unmatching = false,
            },
            preselect = cmp.PreselectMode.Item,
            snippet = {
                expand = function(args)
                    require("luasnip").lsp_expand(args.body)
                end,
            },
            sorting = {
                comparators = {
                    require("copilot_cmp.comparators").prioritize,
                    require("copilot_cmp.comparators").score,
                    cmp.config.compare.score,
                    cmp.config.compare.exact,
                    function(entry1, entry2)
                        local types = require("cmp.types").lsp

                        if (entry1.source.name ~= "nvim_lsp") and (entry2.source.name == "nvim_lsp") then
                            return false
                        elseif (entry1.source.name == "nvim_lsp") and (entry2.source.name ~= "nvim_lsp") then
                            return true
                        elseif (entry1.source.name ~= "nvim_lsp") or (entry2.source.name ~= "nvim_lsp") then
                            return nil
                        end

                        local kind1 = types.CompletionItemKind[entry1:get_kind()]
                        local kind2 = types.CompletionItemKind[entry2:get_kind()]

                        local priority1 = priorities[kind1] or 0
                        local priority2 = priorities[kind2] or 0

                        if priority1 == priority2 then
                            return nil
                        end

                        return priority2 < priority1
                    end,
                    cmp.config.compare.recently_used,
                },
                -- Keep priority weight at 2 for much closer matches to appear above Copilot.
                -- Set to 1 to make Copilot always appear on top.
                priority_weight = 1,
            },
            sources = cmp.config.sources({
                { name = "luasnip", group_index = 1 },
                {
                    name = "nvim_lsp",
                    -- https://github.com/hrsh7th/nvim-cmp/pull/1067
                    --
                    -- Don't return snippets from LSP completion.
                    entry_filter = function(entry, _)
                        return not vim.tbl_contains({ "Snippet" }, require("cmp.types").lsp.CompletionItemKind[entry:get_kind()])
                    end,
                    group_index = 1,
                },
                { name = "copilot", group_index = 1 },
                { name = "async_path" },
                {
                    name = "buffer",
                    group_index = 2,
                    keyword_length = 5,
                    option = {
                        -- Complete from visible buffers, as opposed to just the current buffer.
                        get_bufnrs = function()
                            local buffers = {}
                            for _, win in ipairs(vim.api.nvim_list_wins()) do
                                buffers[vim.api.nvim_win_get_buf(win)] = true
                            end
                            return vim.tbl_keys(buffers)
                        end,
                    },
                },
            }),
            view = {
                entries = "custom", -- "native | wildmenu"
            },
            window = {
                documentation = cmp.config.window.bordered({
                    border = vim.g.border,
                }),
            },
        })

        -- Completions for search mode.
        cmp.setup.cmdline({ "/", "?" }, {
            formatting = format.cmdline,
            mapping = cmp.mapping.preset.cmdline(),
            sources = cmp.config.sources({
                { name = "nvim_lsp_document_symbol", group_index = 1 },
                { name = "buffer", group_index = 2 },
            }),
        })

        -- Completions for : command mode
        cmp.setup.cmdline(":", {
            formatting = format.cmdline,
            mapping = cmp.mapping.preset.cmdline(),
            sources = cmp.config.sources({
                { name = "async_path" },
                -- https://github.com/hrsh7th/nvim-cmp/issues/1511
                { name = "cmdline", keyword_length = 4, keyword_pattern = [=[[^[:blank:]\!]*]=], option = { ignore_cmds = {} } },
            }),
        })
    end,
    dependencies = {
        { "FelipeLema/cmp-async-path" },
        { "hrsh7th/cmp-buffer" },
        { "hrsh7th/cmp-cmdline" },
        { "hrsh7th/cmp-nvim-lsp" },
        { "hrsh7th/cmp-nvim-lsp-document-symbol" },
        { "hrsh7th/cmp-nvim-lsp-signature-help" },
        { "lukas-reineke/cmp-under-comparator" },
        { "onsails/lspkind-nvim" },
        { "saadparwaiz1/cmp_luasnip" },
        {
            "zbirenbaum/copilot-cmp",
            dependencies = "copilot.lua",
            opts = function()
                return {
                    formatters = {
                        insert_text = require("copilot_cmp.format").remove_existing,
                    },
                }
            end,
        },
    },
    event = "VeryLazy",
}
