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
        async_path = " [Path]",
        buffer = " [Buffer]",
        calc = "󰃬 [Calc]",
        cmdline = "󰘳 [Command]",
        copilot = " [Copilot]",
        crates = " [󱘗 Crates]",
        dictionary = "󰂽 [Dict]",
        fish = "󰈺 [Fish]",
        git = "󰊢 [Git]",
        luasnip = "󰢱 [LuaSnip]",
        nerdfonts = "󰊄 [Font]",
        nvim_lsp = " [LSP]",
        nvim_lsp_document_symbol = "󰎕 [Symbol]",
        path = " [Path]",
    },
    menu_icons = {
        calc = "󰃬",
        fish = "󰌋",
    },
}

return {
    "hrsh7th/nvim-cmp",
    cmd = "CmpStatus",
    config = function()
        local cmp = require("cmp")
        local context = require("cmp.config.context")
        local types = require("cmp.types").lsp.CompletionItemKind

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

        -- Only show matches in strings and comments.
        local is_string_like = function()
            return context.in_treesitter_capture("comment")
                or context.in_treesitter_capture("string")
                or context.in_syntax_group("Comment")
                or context.in_syntax_group("String")
        end

        -- Only show matches in strings and comments or text-like file types.
        local is_text = function()
            local ft = vim.api.nvim_get_option_value("filetype", { buf = 0 })

            if vim.tbl_contains({ "gitcommit", "markdown", "text" }, ft) then
                return true
            end

            return is_string_like()
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
                fields = { "kind", "abbr", "menu" },
                format = function(entry, vim_item)
                    --
                    -- Give path completions a different set of icons.
                    if vim.tbl_contains({ "async_path", "path" }, entry.source.name) then
                        local icon, hl_group = require("nvim-web-devicons").get_icon(entry:get_completion_item().label)

                        if icon then
                            vim_item.kind = string.format(" %s ", icon)
                            vim_item.kind_hl_group = hl_group
                            return vim_item
                        end
                    end

                    local kind = require("lspkind").cmp_format({
                        maxwidth = 50,
                        mode = "symbol_text",
                        symbol_map = {
                            Copilot = "",
                            Snippet = "",
                        },
                    })(entry, vim_item)

                    local strings = vim.split(kind.kind, "%s", { trimempty = true })

                    kind.kind = string.format(" %s ", symbol_map.menu_icons[entry.source.name] or strings[1] or "")

                    if entry.source.name ~= "copilot" then
                        kind.menu = string.format("  %s: %s", symbol_map.cmp[entry.source.name] or "", strings[2] or "")
                    end

                    return kind
                end,
            },
        }

        cmp.setup({
            experimental = {
                ghost_text = true,
            },
            formatting = format.normal,
            mapping = cmp.mapping.preset.insert({
                ["<C-c>"] = cmp.mapping.abort(),
                ["<C-Space>"] = cmp.mapping.complete(),
                ["<C-j>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
                ["<C-k>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),
                --
                -- https://github.com/hrsh7th/nvim-cmp/wiki/Example-mappings#safely-select-entries-with-cr
                ["<CR>"] = cmp.mapping({
                    i = function(fallback)
                        if cmp.visible() and cmp.get_active_entry() then
                            cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false })
                        else
                            fallback()
                        end
                    end,
                    s = cmp.mapping.confirm({ select = true }),
                    -- c = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true }),
                }),
                --
                -- https://github.com/hrsh7th/nvim-cmp/wiki/Example-mappings#super-tab-like-mapping
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
                disallow_fuzzy_matching = false,
                disallow_fullfuzzy_matching = true,
                disallow_partial_fuzzy_matching = true,
                disallow_partial_matching = true,
                disallow_prefix_unmatching = false,
            },
            performance = {
                max_view_entries = 100,
            },
            preselect = cmp.PreselectMode.Item,
            snippet = {
                expand = function(args)
                    require("luasnip").lsp_expand(args.body)
                end,
            },
            sorting = {
                comparators = {
                    function(entry1, entry2)
                        if entry1.source.name ~= "nvim_lsp" then
                            if entry2.source.name == "nvim_lsp" then
                                return false
                            else
                                return nil
                            end
                        end

                        local kind1 = types[entry1:get_kind()]
                        local kind2 = types[entry2:get_kind()]

                        local priority1 = priorities[kind1] or 0
                        local priority2 = priorities[kind2] or 0

                        if priority1 == priority2 then
                            return nil
                        end

                        return priority1 > priority2
                    end,
                    cmp.config.compare.offset,
                    cmp.config.compare.exact,
                    cmp.config.compare.score,
                    cmp.config.compare.recently_used,
                    cmp.config.compare.sort_text,
                    cmp.config.compare.locality,
                    cmp.config.compare.length,
                    cmp.config.compare.order,
                    require("copilot_cmp.comparators").prioritize,
                    require("copilot_cmp.comparators").score,
                },
                -- Keep priority weight at 2 for much closer matches to appear above Copilot.
                -- Set to 1 to make Copilot always appear on top.
                priority_weight = 2,
            },
            sources = cmp.config.sources({
                {
                    name = "nvim_lsp",
                    -- https://github.com/hrsh7th/nvim-cmp/pull/1067
                    --
                    entry_filter = function(entry, ctx)
                        local kind = entry:get_kind()
                        local line = ctx.cursor.line
                        local col = ctx.cursor.col
                        local char_before_cursor = string.sub(line, col - 1, col - 1)
                        local char_after_dot = string.sub(line, col, col)

                        -- Don't complete LSP symbols in comments or strings.
                        if is_string_like() then
                            return false
                        end

                        -- Don't return snippets from LSP completion.
                        if kind == types.Snippet then
                            return false
                        end

                        if char_before_cursor == "." and char_after_dot:match("[a-zA-Z]") then
                            return vim.tbl_contains({ types.Method, types.Field, types.Property }, kind)
                        end

                        if string.match(line, "^%s+%w+$") then
                            return kind == types.Function or kind == types.lsp.CompletionItemKind.Variable
                        end

                        return true
                    end,
                    group_index = 1,
                    priority = 120,
                },
                {
                    name = "luasnip",
                    entry_filter = function()
                        return not is_string_like()
                    end,
                    group_index = 1,
                    priority = 100,
                },
                {
                    name = "async_path",
                    group_index = 1,
                    priority = 90,
                },
                {
                    name = "calc",
                    group_index = 2,
                    priority = 80,
                },
                {
                    name = "dictionary",
                    entry_filter = is_text,
                    group_index = 2,
                    keyword_length = 2,
                    max_item_count = 5,
                    priority = 90,
                },
                {
                    name = "env",
                    group_index = 3,
                    priority = 80,
                },
                {
                    name = "fish",
                    entry_filter = function()
                        return not is_string_like()
                    end,
                    group_index = 3,
                    priority = 80,
                },
                {
                    name = "buffer",
                    group_index = 10,
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
                    priority = 50,
                },
                {
                    name = "nerdfonts",
                    entry_filter = is_text,
                    group_index = 20,
                    priority = 40,
                    keyword_length = 5,
                },
                {
                    name = "copilot",
                    entry_filter = function()
                        return not is_string_like()
                    end,
                    group_index = 30,
                    priority = 70,
                },
            }),
            view = {
                entries = "custom", -- "native | wildmenu"
            },
            window = {
                completion = {
                    col_offset = -3,
                    side_padding = 0,
                },
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
        { "bydlw98/cmp-env" },
        { "fazibear/cmp-nerdfonts" },
        { "hrsh7th/cmp-buffer" },
        { "hrsh7th/cmp-calc" },
        { "hrsh7th/cmp-cmdline" },
        { "hrsh7th/cmp-nvim-lsp" },
        { "hrsh7th/cmp-nvim-lsp-document-symbol" },
        { "hrsh7th/cmp-nvim-lsp-signature-help" },
        { "lukas-reineke/cmp-under-comparator" },
        { "mtoohey31/cmp-fish", ft = "fish", cond = string.find(vim.env.SHELL, "fish") },
        { "onsails/lspkind-nvim" },
        { "petertriho/cmp-git", requires = "nvim-lua/plenary.nvim" },
        { "saadparwaiz1/cmp_luasnip" },
        {
            "uga-rosa/cmp-dictionary",
            config = function()
                local dict = require("cmp_dictionary")

                dict.setup({
                    first_case_insensitive = true,
                    document = vim.fn.executable("wn") == 1, -- Needs wordnet + tcl-tk
                })

                dict.switcher({
                    spelllang = {
                        en = "/usr/share/dict/words",
                    },
                })
            end,
        },
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
