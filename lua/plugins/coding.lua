local defaults = require("config.defaults")

-- Only show matches in strings and comments.
local is_string_like = function()
    local context = require("cmp.config.context")

    return context.in_treesitter_capture("comment")
        or context.in_treesitter_capture("string")
        or context.in_syntax_group("Comment")
        or context.in_syntax_group("String")
end

---@type LazySpec[]
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
            local types = require("cmp.types")

            local lspkind = require("lspkind").cmp_format({
                maxwidth = 50,
                mode = "symbol",
                menu = nil,
                symbol_map = {
                    Copilot = "",
                    Snippet = "",
                    calc = "󰃬",
                    fish = "󰌋",
                },
            })

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

            ---@type table<integer, integer>
            local modified_priority = {
                [types.lsp.CompletionItemKind.Variable] = types.lsp.CompletionItemKind.Method,
                [types.lsp.CompletionItemKind.Snippet] = 0, -- top
                [types.lsp.CompletionItemKind.Keyword] = 0, -- top
                [types.lsp.CompletionItemKind.Text] = 100, -- bottom
            }

            ---@param kind integer: Kind of completion entry
            local function modified_kind(kind)
                return modified_priority[kind] or kind
            end

            return {
                completion = {
                    keyword_length = 4,
                },
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

                        vim_item.menu = ""
                        return lspkind(entry, vim_item)
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

                        if cmp.visible() and has_words_before() then
                            cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
                        elseif luasnip.expand_or_locally_jumpable() then
                            luasnip.expand_or_jump()
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
                        -- function(entry1, entry2)
                        --     if entry1.source.name ~= "nvim_lsp" then
                        --         if entry2.source.name == "nvim_lsp" then
                        --             return false
                        --         else
                        --             return nil
                        --         end
                        --     end
                        --
                        --     local kind1 = types[entry1:get_kind()]
                        --     local kind2 = types[entry2:get_kind()]
                        --
                        --     local priorities = defaults.cmp.priorities
                        --     local priority1 = priorities[kind1] or 0
                        --     local priority2 = priorities[kind2] or 0
                        --
                        --     if priority1 == priority2 then
                        --         return nil
                        --     end
                        --
                        --     return priority1 > priority2
                        -- end,
                        cmp.config.compare.offset,
                        cmp.config.compare.exact,
                        function(entry1, entry2) -- sort by length ignoring "=~"
                            local len1 = string.len(string.gsub(entry1.completion_item.label, "[=~()_]", ""))
                            local len2 = string.len(string.gsub(entry2.completion_item.label, "[=~()_]", ""))
                            if len1 ~= len2 then
                                return len1 - len2 < 0
                            end
                        end,
                        cmp.config.compare.recently_used,
                        function(entry1, entry2) -- sort by compare kind (Variable, Function etc)
                            local kind1 = modified_kind(entry1:get_kind())
                            local kind2 = modified_kind(entry2:get_kind())
                            if kind1 ~= kind2 then
                                return kind1 - kind2 < 0
                            end
                        end,
                        function(entry1, entry2) -- score by lsp, if available
                            local t1 = entry1.completion_item.sortText
                            local t2 = entry2.completion_item.sortText
                            if t1 ~= nil and t2 ~= nil and t1 ~= t2 then
                                return t1 < t2
                            end
                        end,
                        cmp.config.compare.score,
                        -- cmp.config.compare.sort_text,
                        -- cmp.config.compare.locality,
                        -- cmp.config.compare.length,
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
                            -- if kind == types.lsp.Snippet or kind == types.lsp.Text then
                            --     return false
                            -- end

                            if char_before_cursor == "." and char_after_dot:match("[a-zA-Z]") then
                                return vim.tbl_contains({
                                    types.lsp.CompletionItemKind.Method,
                                    types.lsp.CompletionItemKind.Field,
                                    types.lsp.CompletionItemKind.Property,
                                }, kind)
                            end
                            --
                            if string.match(line, "^%s+%w+$") then
                                return kind == types.lsp.CompletionItemKind.Function or kind == types.lsp.CompletionItemKind.Variable
                            end

                            return true
                        end,
                    },
                }, {
                    {
                        name = "buffer",
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
            table.insert(defaults.cmp.symbols, { async_path = " [Path]" })
        end,
    },
    {
        "nvim-cmp",
        dependencies = "bydlw98/cmp-env",
        event = "InsertEnter",
        opts = function(_, opts)
            table.insert(opts.sources, { name = "env" })
            table.insert(defaults.cmp.symbols, { env = " [ENV]" })
        end,
    },
    {
        "nvim-cmp",
        dependencies = "hrsh7th/cmp-calc",
        event = "InsertEnter",
        opts = function(_, opts)
            table.insert(opts.sources, { name = "calc" })
            table.insert(defaults.cmp.symbols, { calc = "󰃬 [Calc]" })
            table.insert(defaults.cmp.menu, { calc = "󰃬" })
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

            table.insert(defaults.cmp.symbols, { cmdline = "󰘳 [Command]" })
            table.insert(defaults.cmp.symbols, { nvim_lsp_document_symbol = "󰎕 [Symbol]" })
            table.insert(defaults.cmp.symbols, { path = " [Path]" })

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
                    { name = "cmdline", keyword_pattern = [=[[^[:blank:]\!]*]=], option = { ignore_cmds = {} } },
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

            table.insert(defaults.cmp.symbols, { fish = "󰈺 [Fish]" })
            table.insert(defaults.cmp.menu, { fish = "󰌋" })
        end,
    },
    {
        "nvim-cmp",
        dependencies = { { "zbirenbaum/copilot-cmp", enabled = false } },
        opts = function(_, opts)
            if package.loaded["copilot_cmp"] then
                local cmp = require("cmp")

                -- Hide copilot suggestions if the completion window is open.
                cmp.event:on("menu_opened", function()
                    vim.api.nvim_buf_set_var(0, "copilot_suggestion_hidden", true)
                end)

                cmp.event:on("menu_closed", function()
                    vim.api.nvim_buf_set_var(0, "copilot_suggestion_hidden", false)
                end)

                table.insert(opts.sources, {
                    name = "copilot",
                    entry_filter = function()
                        return not is_string_like() and not require("luasnip").in_snippet()
                    end,
                })

                table.insert(defaults.cmp.symbols, { copilot = " [Copilot]" })

                if opts.formatters == nil then
                    opts.formatters = {}
                end

                table.insert(opts.formatters, {
                    insert_text = require("copilot_cmp.format").remove_existing,
                })
            end
        end,
    },
    {
        "L3MON4D3/LuaSnip",
        cmd = { "LuaSnipEdit" },
        config = function()
            local ls = require("luasnip")
            local types = require("luasnip.util.types")

            -- documentation for snippet format inside examples:
            -- https://github.com/L3MON4D3/LuaSnip/blob/master/Examples/snippets.lua

            ls.config.set_config({
                keep_roots = true,
                link_roots = true,
                link_children = true,
                -- Do not jump to snippet if I'm outside of it
                -- https://github.com/L3MON4D3/LuaSnip/issues/78
                region_check_events = "CursorMoved",
                delete_check_events = "TextChanged",
                enable_autosnippets = true,
                ext_opts = {
                    [types.choiceNode] = {
                        active = {
                            virt_text = { { "", "Operator" } },
                            hl_mode = "combine",
                        },
                    },
                    [types.insertNode] = {
                        active = {
                            virt_text = { { "", "Type" } },
                            hl_mode = "combine",
                        },
                    },
                },
                -- Use treesitter for getting the current filetype. This allows correctly resolving
                -- the current filetype in eg. a markdown-code block or `vim.cmd()`.
                ft_func = require("luasnip.extras.filetype_functions").from_cursor,
            })

            -- Snippets are stored in separate files.
            require("luasnip.loaders.from_lua").load({ paths = vim.api.nvim_get_runtime_file("lua/snippets", false)[1] })

            -- Create a command to edit the snippet file associated with the current
            vim.api.nvim_create_user_command("LuaSnipEdit", function()
                require("telescope")
                require("luasnip.loaders").edit_snippet_files()
            end, {})

            vim.keymap.set({ "i" }, "<C-k>", function()
                if ls.expand_or_jumpable() then
                    ls.expand_or_jump()
                end
            end, { silent = true, desc = "Expand or jump to next snippet node" })

            vim.keymap.set({ "i", "s" }, "<C-l>", function()
                ls.jump(1)
            end, { silent = true, desc = "Jump to next snippet node" })

            vim.keymap.set({ "i", "s" }, "<C-j>", function()
                ls.jump(-1)
            end, { silent = true, desc = "Jump to previous snippet node" })

            vim.keymap.set({ "i", "s" }, "<C-e>", function()
                if ls.choice_active() then
                    ls.change_choice(1)
                end
            end, { silent = true, desc = "Select previous choice in snippet choice nodes" })

            vim.keymap.set({ "i", "n" }, "<C-s>", function()
                ls.unlink_current()
            end, { silent = true, desc = "Clear snippet jumps" })
        end,
        dependencies = {
            {
                "rafamadriz/friendly-snippets",
                config = function()
                    require("luasnip.loaders.from_vscode").lazy_load()
                    -- require('luasnip/loaders/from_vscode').lazy_load({ paths = { vim.fn.stdpath('config') .. '/misc/snippets' } })
                end,
            },
        },
    },
    {
        "echasnovski/mini.ai",
        config = function()
            local ai = require("mini.ai")

            local create_keymap = function(capture, start, down)
                local rhs = function()
                    local parser = vim.treesitter.get_parser()
                    local query = vim.treesitter.query.get(vim.bo.filetype, "textobjects")

                    if not parser then
                        return vim.notify("No treesitter parser for the current buffer", vim.log.levels.ERROR)
                    end

                    if not query then
                        return vim.notify("No textobjects query for the current buffer", vim.log.levels.ERROR)
                    end

                    local cursor = vim.api.nvim_win_get_cursor(0)
                    local locs = {}
                    for _, tree in ipairs(parser:trees()) do
                        --
                        ---@diagnostic disable-next-line: missing-parameter
                        for capture_id, node, _ in query:iter_captures(tree:root(), 0) do
                            if query.captures[capture_id] == capture then
                                local range = { node:range() } ---@type number[]
                                local row = (start and range[1] or range[3]) + 1
                                local col = (start and range[2] or range[4]) + 1
                                if down and row > cursor[1] or not down and row < cursor[1] then
                                    table.insert(locs, { row, col })
                                end
                            end
                        end
                    end
                    return pcall(vim.api.nvim_win_set_cursor, 0, down and locs[1] or locs[#locs])
                end

                local c = capture:sub(1, 1):lower()
                local lhs = (down and "]" or "[") .. (start and c or c:upper())
                local desc = (down and "next " or "previous ") .. (start and "start" or "end") .. " of " .. capture:gsub("%..*", "")

                if start and c == "c" then
                    -- Preserve builtin key map to navigate diff chunks
                    vim.keymap.set("n", lhs, function()
                        if vim.wo.diff then
                            return lhs
                        end
                        vim.schedule(function()
                            rhs()
                        end)
                        return "<ignore>"
                    end, { expr = true, desc = "mini.ai: goto " .. desc .. "/change" })
                else
                    vim.keymap.set("n", lhs, rhs, { desc = "mini.ai: goto " .. desc })
                end
            end

            -- Create the keymap permutations.
            for _, capture in ipairs({ "function.outer", "class.outer" }) do
                for _, start in ipairs({ true, false }) do
                    for _, down in ipairs({ true, false }) do
                        create_keymap(capture, start, down)
                    end
                end
            end

            ai.setup({
                n_lines = 500,
                custom_textobjects = {
                    c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }, {}),
                    f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }, {}),
                    l = ai.gen_spec.treesitter({
                        a = { "@block.outer", "@conditional.outer", "@loop.outer" },
                        i = { "@block.inner", "@conditional.inner", "@loop.inner" },
                    }, {}),
                    ["/"] = ai.gen_spec.treesitter({ a = "@comment.outer", i = "@comment.inner" }, {}),
                },
            })
        end,
        dependencies = {
            {
                -- no need to load the plugin, since we only need its queries
                "nvim-treesitter/nvim-treesitter-textobjects",
                init = function()
                    require("lazy.core.loader").disable_rtp_plugin("nvim-treesitter-textobjects")
                end,
            },
        },
        event = "VeryLazy",
        enabled = false,
        keys = {
            { "[f", desc = "mini.ai: goto previous function" },
            { "]f", desc = "mini.ai: goto next function" },
            { "a", mode = { "x", "o" } },
            { "i", mode = { "x", "o" } },
        },
        opts = function()
            local ai = require("mini.ai")

            return {
                n_lines = 500,
                custom_textobjects = {
                    l = ai.gen_spec.treesitter({
                        a = { "@block.outer", "@conditional.outer", "@loop.outer" },
                        i = { "@block.inner", "@conditional.inner", "@loop.inner" },--[[  ]]
                    }, {}),
                    f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }, {}),
                    c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }, {}),
                    a = ai.gen_spec.treesitter({ a = "@parameter.outer", i = "@parameter.inner" }, {}),
                    k = ai.gen_spec.treesitter({ a = "@comment.outer", i = "@comment.outer" }, {}),
                },
            }
        end,
    },
    {
        "echasnovski/mini.comment",
        keys = {
            { "gc", mode = { "n", "x" }, desc = "Comment Line(s)" },
            { "gcc", mode = { "n", "x" }, desc = "Uncomment Line(s)" },
        },
        opts = {},
    },
    {
        "echasnovski/mini.pairs",
        enabled = false,
        event = "InsertEnter",
        opts = {
            mappings = {
                -- https://gitspartv.github.io/lua-patterns/?pattern=%5B%5E%25a%5C%5C%3C%26%5D.
                ["("] = { action = "open", pair = "()", neigh_pattern = "[^\\][]%s)}']" },
                ["["] = { action = "open", pair = "[]", neigh_pattern = "[^\\][]%s)}']" },
                ["{"] = { action = "open", pair = "{}", neigh_pattern = "[^\\][]%s)}']" },

                ["<"] = { action = "open", pair = "<>", neigh_pattern = "[^\\][%s]" },
                [">"] = { action = "close", pair = "<>", neigh_pattern = "[^\\]." },

                -- ['"'] = { action = "closeopen", pair = '""', neigh_pattern = "[^\\][]%s)}'\"]", register = { cr = false } },
                -- ["'"] = { action = "closeopen", pair = "''", neigh_pattern = "[^%a\\][]%s)}'\"]", register = { cr = false } },
                -- ["`"] = { action = "closeopen", pair = "``", neigh_pattern = "[^\\][]%s)}'\"]", register = { cr = false } },

                ["`"] = { action = "closeopen", pair = "``", neigh_pattern = "[^%S][^%S]", register = { cr = false } },
            },
        },
    },
    {
        "echasnovski/mini.surround",
        config = function()
            require("mini.surround").setup({
                custom_surroundings = {
                    -- Use tree-sitter to search for function call
                    f = {
                        input = require("mini.surround").gen_spec.input.treesitter({ outer = "@call.outer", inner = "@call.inner" }, {}),
                    },
                    ["("] = { output = { left = "(", right = ")" } },
                    [")"] = { output = { left = "(", right = ")" } },
                    ["["] = { output = { left = "[", right = "]" } },
                    ["]"] = { output = { left = "[", right = "]" } },
                },
                mappings = {
                    add = "gza", -- Add surrounding in Normal and Visual modes
                    delete = "gzd", -- Delete surrounding
                    find = "gzf", -- Find surrounding (to the right)
                    find_left = "gzF", -- Find surrounding (to the left)
                    highlight = "gzh", -- Highlight surrounding
                    replace = "gzr", -- Replace surrounding
                    update_n_lines = "gzn", -- Update `n_lines`
                },
            })
        end,
        event = { "BufRead", "BufNewFile" },
        keys = { { "gz", desc = "+ Surround" } },
    },
    {
        "ThePrimeagen/refactoring.nvim",
        dependencies = {
            { "nvim-lua/plenary.nvim" },
            { "nvim-treesitter/nvim-treesitter" },
        },
        keys = {
            {
                "<leader>cR",
                function()
                    require("refactoring").select_refactor({})
                end,
                desc = "  Refactor",
                mode = { "n", "x" },
                noremap = true,
                silent = true,
                expr = false,
            },
        },
        opts = {},
    },
    {
        "monaqa/dial.nvim",
        config = function()
            local augend = require("dial.augend")

            -- Replace string case conversions with https://github.com/johmsalas/text-case.nvim ?
            local function to_capital(str)
                return str:gsub("^%l", string.upper)
            end

            local function to_pascal(str)
                return str:gsub("%W*(%w+)", to_capital)
            end

            local function to_snake(str)
                return str:gsub("%f[^%l]%u", "_%1"):gsub("%f[^%a]%d", "_%1"):gsub("%f[^%d]%a", "_%1"):gsub("(%u)(%u%l)", "%1_%2"):lower()
            end

            local function to_camel(str)
                return to_pascal(str):gsub("^%u", string.lower)
            end

            require("dial.config").augends:register_group({
                default = {
                    augend.integer.alias.decimal,
                    augend.integer.alias.hex,
                    augend.integer.alias.octal,
                    augend.integer.alias.binary,
                    augend.hexcolor.new({}),
                    augend.constant.alias.alpha,
                    augend.constant.alias.Alpha,
                    augend.paren.alias.quote,
                    augend.paren.alias.lua_str_literal,
                    augend.paren.alias.rust_str_literal,
                    augend.paren.alias.brackets,
                    augend.semver.alias.semver,
                    augend.date.alias["%-m/%-d"],
                    augend.date.alias["%H:%M"],
                    augend.date.alias["%H:%M:%S"],
                    augend.date.alias["%Y-%m-%d"],
                    augend.date.alias["%Y/%m/%d"],
                    augend.date.alias["%m/%d"],
                    augend.constant.new({
                        elements = { "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday" },
                    }),
                    augend.constant.new({
                        elements = {
                            "January",
                            "February",
                            "March",
                            "April",
                            "May",
                            "June",
                            "July",
                            "August",
                            "September",
                            "October",
                            "November",
                            "December",
                        },
                    }),
                    augend.constant.new({ elements = { "North", "East", "South", "West" } }),
                    augend.constant.new({ elements = { "TRUE", "FALSE" } }),
                    augend.constant.new({ elements = { "True", "False" } }),
                    augend.constant.new({ elements = { "true", "false" } }),
                    augend.constant.new({ elements = { "and", "or" } }),
                    augend.constant.new({ elements = { "And", "Or" } }),
                    augend.constant.new({ elements = { "AND", "OR" } }),
                    augend.constant.new({ elements = { "define", "undef" } }),
                    augend.constant.new({ elements = { "float64", "float32" } }),
                    augend.constant.new({ elements = { "h1", "h2", "h3", "h4", "h5", "h6" } }),
                    augend.constant.new({ elements = { "int", "int64", "int32" } }),
                    augend.constant.new({ elements = { "on", "off" } }),
                    augend.constant.new({ elements = { "On", "Off" } }),
                    augend.constant.new({ elements = { "ON", "OFF" } }),
                    augend.constant.new({ elements = { "pick", "reword", "edit", "squash", "fixup", "exec" } }),
                    augend.constant.new({ elements = { "Up", "Down", "Left", "Right" } }),
                    augend.constant.new({ elements = { "up", "down", "left", "right" } }),
                    augend.constant.new({ elements = { "yes", "no" } }),
                    augend.constant.new({ elements = { "Yes", "No" } }),
                    augend.constant.new({ elements = { "YES", "NO" } }),
                    augend.constant.new({ elements = { "&&", "||" }, word = false }),
                    augend.constant.new({ elements = { ">", "<" }, word = false }),
                    augend.constant.new({ elements = { "==", "!=" }, word = false }),
                    augend.constant.new({ elements = { "===", "!==" }, word = false }),
                    augend.constant.new({ elements = { ">=", "<=" }, word = false }),
                    augend.constant.new({ elements = { "++", "--" }, word = false }),
                    augend.user.new({
                        find = require("dial.augend.common").find_pattern("%u+"),
                        add = function(text, _, _)
                            return { text = text:lower(), cursor = #text }
                        end,
                    }),
                    augend.user.new({
                        find = require("dial.augend.common").find_pattern("%l+"),
                        add = function(text, _, _)
                            return { text = text:upper(), cursor = #text }
                        end,
                    }),
                    -- Cycle through camel, pascal & snake case.
                    augend.user.new({
                        find = require("dial.augend.common").find_pattern("[%a_]+"),
                        add = function(text, _, _)
                            if to_camel(text) == text then
                                text = to_snake(text)
                            elseif to_snake(text) == text then
                                text = to_pascal(text)
                            elseif to_pascal(text) == text then
                                text = to_camel(text)
                            end

                            return { text = text, cursor = #text }
                        end,
                    }),
                },
            })
        end,
        -- stylua: ignore
        keys = {
            { "<C-k>", function() return require("dial.map").inc_normal() end, desc = "Increment Pattern", expr = true },
            { "<C-j>", function() return require("dial.map").dec_normal() end, desc = "Decrement Pattern", expr = true },
        },
    },
    {
        "aznhe21/actions-preview.nvim",
        opts = {
            backend = { "nui" },
            diff = {
                algorithm = "patience",
                ignore_whitespace = true,
            },
        },
    },
    {
        "smjonas/inc-rename.nvim",
        cmd = "IncRename",
        config = true,
    },
    {
        "chrisgrieser/nvim-rulebook",
        -- stylua: ignore
        keys = {
            { "<leader>ri", function() require("rulebook").ignoreRule() end, desc = "  Ignore Rule" },
            { "<leader>rl", function() require("rulebook").lookupRule() end, desc = "  Look up Rule" },
        },
    },
    -- Load Lua plugin files without needing to have them in the LSP workspace.
    { "mrjones2014/lua-gf.nvim", ft = "lua" },
    {
        "Saecki/crates.nvim",
        event = { "BufRead Cargo.toml" },
        opts = {
            lsp = {
                actions = true,
                completion = true,
                enabled = true,
                on_attach = require("plugins.lsp.common").on_attach,
            },
            on_attach = function(bufnr)
                local crates = require("crates")

                vim.keymap.set("n", "K", function()
                    if crates.popup_available() then
                        crates.show_popup()
                    else
                        vim.lsp.buf.hover()
                    end
                end, {
                    buffer = bufnr,
                    desc = "Show Crate Documentation",
                })

                vim.keymap.set("n", "<leader>cu", crates.upgrade_crate, { buffer = bufnr, desc = "Upgrade crate." })
                vim.keymap.set("n", "<leader>cU", crates.upgrade_all_crates, { buffer = bufnr, desc = "Upgrade all crates." })

                vim.api.nvim_create_autocmd("InsertEnter", {
                    callback = function()
                        table.insert(defaults.cmp.symbols, #defaults.cmp.symbols + 1, { async_path = " [Path]" })
                        table.insert(defaults.cmp.symbols, #defaults.cmp.symbols + 1, { crates = " [󱘗 Crates]" })

                        require("crates.src.cmp").setup()
                    end,
                })
            end,
            popup = {
                autofocus = true,
                border = vim.g.border,
            },
            src = {
                cmp = { enabled = false },
            },
        },
    },
}
