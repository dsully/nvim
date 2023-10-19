local M = {
    symbols = {
        buffer = " [Buffer]",
        crates = " [󱘗 Crates]",
        luasnip = "󰢱 [LuaSnip]",
        nvim_lsp = " [LSP]",
    },
    menu = {},
}

-- Only show matches in strings and comments.
local is_string_like = function()
    local context = require("cmp.config.context")

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

return {
    {
        "hrsh7th/nvim-cmp",
        cmd = "CmpStatus",
        config = function(_, opts)
            if opts and opts.sources then
                for _, source in ipairs(opts.sources) do
                    source.group_index = source.group_index or 1
                end
            end

            require("cmp").setup(opts)
        end,
        opts = function()
            local cmp = require("cmp")
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

            -- Hide copilot suggestions if the completion window is open.
            cmp.event:on("menu_opened", function()
                vim.api.nvim_buf_set_var(0, "copilot_suggestion_hidden", true)
            end)

            cmp.event:on("menu_closed", function()
                vim.api.nvim_buf_set_var(0, "copilot_suggestion_hidden", false)
            end)

            return {
                experimental = {
                    ghost_text = true,
                },
                formatting = {
                    fields = { "kind", "abbr", "menu" },
                    format = function(entry, vim_item)
                        --
                        -- Give path completions a different set of icons.
                        if string.match(entry.source.name, "path") then
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

                        kind.kind = string.format(" %s ", M.menu[entry.source.name] or strings[1] or "")

                        -- Remove duplicate entries.
                        kind.dup = ({
                            buffer = 0,
                            dictionary = 1,
                            luasnip = 1,
                            nvim_lsp = 1,
                            path = 1,
                        })[entry.source.name] or 0

                        -- Trim leading space
                        kind.abbr = string.gsub(kind.abbr, "^%s+", "")

                        if entry.source.name ~= "copilot" then
                            kind.menu = string.format("  %s: %s", M.symbols[entry.source.name] or "", strings[2] or "")
                        end

                        return kind
                    end,
                },
                mapping = cmp.mapping({
                    ["<C-a>"] = cmp.mapping.abort(),
                    ["<C-Space>"] = cmp.mapping.complete(),
                    ["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
                    ["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),
                    ["<Up>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),
                    ["<Down>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),

                    -- https://github.com/hrsh7th/nvim-cmp/wiki/Example-mappings#safely-select-entries-with-cr
                    ["<CR>"] = cmp.mapping({
                        i = function(fallback)
                            if cmp.visible() then
                                cmp.confirm({ behavior = cmp.ConfirmBehavior.Insert, select = true })
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

                        if cmp.visible() and has_words_before() then
                            cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
                        elseif luasnip.expand_or_locally_jumpable() then
                            luasnip.expand_or_jump()
                        elseif neogen.jumpable() then
                            neogen.jump_next()
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

                            local priorities = vim.g.defaults.cmp.priorities
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
                    },
                    -- Keep priority weight at 2 for much closer matches to appear above Copilot.
                    -- Set to 1 to make Copilot always appear on top.
                    priority_weight = 2,
                },
                sources = cmp.config.sources({
                    {
                        name = "luasnip",
                        entry_filter = function()
                            return not is_string_like()
                        end,
                    },
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

                            -- Don't return snippets or "Text" from LSP completion.
                            if kind == types.Snippet or kind == types.Text then
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
                    },
                }, {
                    {
                        name = "buffer",
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
                    completion = {
                        col_offset = -3,
                        side_padding = 0,
                    },
                    documentation = cmp.config.window.bordered({
                        border = vim.g.border,
                    }),
                },
            }
        end,
        dependencies = {
            { "hrsh7th/cmp-buffer" },
            { "hrsh7th/cmp-nvim-lsp" },
            { "lukas-reineke/cmp-under-comparator" },
            { "onsails/lspkind-nvim" },
            { "saadparwaiz1/cmp_luasnip" },
        },
        event = "InsertEnter",
        version = false,
    },
    {
        "nvim-cmp",
        dependencies = "FelipeLema/cmp-async-path",
        event = "InsertEnter",
        opts = function(_, opts)
            table.insert(opts.sources, { name = "async_path" })
            table.insert(M.symbols, { async_path = " [Path]" })
        end,
    },
    {
        "nvim-cmp",
        dependencies = "bydlw98/cmp-env",
        event = "InsertEnter",
        opts = function(_, opts)
            table.insert(opts.sources, { name = "env" })
            table.insert(M.symbols, { env = " [ENV]" })
        end,
    },
    {
        "nvim-cmp",
        dependencies = "fazibear/cmp-nerdfonts",
        event = "InsertEnter",
        opts = function(_, opts)
            table.insert(opts.sources, {
                name = "nerdfonts",
                entry_filter = is_text,
                keyword_length = 3,
                keyword_pattern = [[nf\-.*]],
            })
            table.insert(M.symbols, { nerdfonts = "󰊄 [Font]" })
        end,
    },

    {
        "nvim-cmp",
        dependencies = "hrsh7th/cmp-calc",
        event = "InsertEnter",
        opts = function(_, opts)
            table.insert(opts.sources, { name = "calc" })
            table.insert(M.symbols, { calc = "󰃬 [Calc]" })
            table.insert(M.menu, { calc = "󰃬" })
        end,
    },

    {
        "nvim-cmp",
        dependencies = {
            "FelipeLema/cmp-async-path",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-cmdline",
            "hrsh7th/cmp-nvim-lsp-document-symbol",
        },
        event = { "CmdlineEnter", "InsertEnter" },
        opts = function(_, opts)
            local cmp = require("cmp")

            table.insert(M.symbols, { cmdline = "󰘳 [Command]" })
            table.insert(M.symbols, { nvim_lsp_document_symbol = "󰎕 [Symbol]" })
            table.insert(M.symbols, { path = " [Path]" })

            local formatting = {
                format = function(_, item)
                    item.kind = ""
                    item.menu = ""
                    item.dup = 0
                    return item
                end,
            }

            -- Completions for search mode.
            cmp.setup.cmdline({ "/", "?" }, {
                formatting = formatting,
                mapping = cmp.mapping.preset.cmdline(),
                sources = cmp.config.sources({
                    { name = "nvim_lsp_document_symbol", group_index = 1 },
                    { name = "buffer", group_index = 2 },
                }),
            })

            -- Completions for : command mode
            cmp.setup.cmdline(":", {
                formatting = formatting,
                mapping = cmp.mapping.preset.cmdline(),
                sources = cmp.config.sources({
                    { name = "async_path" },
                    -- https://github.com/hrsh7th/nvim-cmp/issues/1511
                    { name = "cmdline", keyword_length = 4, keyword_pattern = [=[[^[:blank:]\!]*]=], option = { ignore_cmds = {} } },
                }),
            })
        end,
    },
    {
        "nvim-cmp",
        dependencies = "mtoohey31/cmp-fish",
        ft = "fish",
        event = "InsertEnter",
        opts = function(_, opts)
            table.insert(opts.sources, {
                name = "fish",
                entry_filter = function()
                    return not is_string_like()
                end,
            })

            table.insert(M.symbols, { fish = "󰈺 [Fish]" })
            table.insert(M.menu, { fish = "󰌋" })
        end,
    },
    {
        "nvim-cmp",
        dependencies = "uga-rosa/cmp-dictionary",
        cond = function()
            return vim.fn.executable("wn") == 1 -- Needs wordnet + tcl-tk
        end,
        ft = { "gitcommit", "markdown", "text" },
        event = "InsertEnter",
        opts = function(_, opts)
            local dict = require("cmp_dictionary")

            dict.setup({
                first_case_insensitive = true,
                document = true,
            })

            dict.switcher({
                spelllang = {
                    en = "/usr/share/dict/words",
                },
            })

            table.insert(M.symbols, { dictionary = "󰂽 [Dict]" })

            require("cmp").setup.filetype({ "gitcommit", "markdown", "text" }, {
                sources = {
                    name = "dictionary",
                    group_index = 2,
                    keyword_length = 2,
                    max_item_count = 5,
                },
            })
        end,
    },
    {
        "nvim-cmp",
        dependencies = { { "zbirenbaum/copilot-cmp", disable = true } },
        opts = function(_, opts)
            if package.loaded["copilot_cmp"] then
                table.insert(opts.sources, {
                    name = "copilot",
                    entry_filter = function()
                        return not is_string_like() and not require("luasnip").in_snippet()
                    end,
                })

                table.insert(M.symbols, { copilot = " [Copilot]" })

                if opts.formatters == nil then
                    opts.formatters = {}
                end

                table.insert(opts.formatters, {
                    insert_text = require("copilot_cmp.format").remove_existing,
                })
            end
        end,
    },
}
