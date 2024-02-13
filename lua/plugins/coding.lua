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
        dependencies = {
            "FelipeLema/cmp-async-path",
            "hrsh7th/cmp-calc",
            "hrsh7th/cmp-cmdline",
            "hrsh7th/cmp-nvim-lsp",
            "onsails/lspkind-nvim",
            {
                "garymjr/nvim-snippets",
                opts = {
                    friendly_snippets = true,
                },
                dependencies = {
                    "rafamadriz/friendly-snippets",
                    lazy = false,
                },
            },
        },
        event = "LazyFile",
        config = function()
            local cmp = require("cmp")
            local types = require("cmp.types.lsp")

            local copilot = require("copilot.suggestion")
            local treesitter = require("nvim-treesitter.indent")

            local lspkind = require("lspkind").cmp_format({
                maxwidth = 50,
                mode = "symbol",
                menu = nil,
                symbol_map = defaults.cmp.symbols,
            })

            ---@type table<integer, integer>
            local modified_priority = {
                [types.CompletionItemKind.Snippet] = 0, -- top
                [types.CompletionItemKind.Keyword] = 0, -- top
                [types.CompletionItemKind.Text] = 100, -- bottom
            }

            ---@param kind integer: Kind of completion entry
            local function modified_kind(kind)
                return modified_priority[kind] or kind
            end

            -- Inside a snippet, use backspace to remove the placeholder.
            vim.keymap.set("s", "<BS>", "<C-O>s")

            cmp.setup({
                completion = {
                    keyword_length = 3,
                },
                experimental = {
                    ghost_text = false,
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

                        if defaults.cmp.kind[entry.source.name] then
                            vim_item.kind = defaults.cmp.kind[entry.source.name]
                        else
                            vim_item = lspkind(entry, vim_item)
                        end

                        return vim_item
                    end,
                },
                mapping = cmp.mapping({
                    ["<C-e>"] = cmp.mapping(function()
                        if vim.snippet.active() then
                            vim.snippet.exit()
                        elseif cmp.visible() then
                            cmp.abort()
                        elseif copilot.is_visible() then
                            copilot.dismiss()
                        end
                    end, { "i", "c" }),
                    --
                    -- Bring up the completion menu manually.
                    ["<C-Space>"] = cmp.mapping.complete(),
                    ["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
                    ["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),
                    ["<Up>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),
                    ["<Down>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),

                    -- https://github.com/hrsh7th/nvim-cmp/wiki/Example-mappings#safely-select-entries-with-cr
                    ["<CR>"] = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Insert, select = true }),
                    ["<C-CR>"] = cmp.mapping(function(fallback)
                        cmp.abort()
                        fallback()
                    end),
                    ["<Tab>"] = cmp.mapping(function(fallback)
                        --
                        -- Terminal
                        if vim.api.nvim_get_mode().mode == "t" then
                            fallback()
                            return
                        end

                        if vim.api.nvim_get_mode().mode == "s" then
                            vim.snippet.jump(1)
                            return
                        end

                        local row, col = unpack(vim.api.nvim_win_get_cursor(0))
                        local line = vim.api.nvim_buf_get_lines(0, row - 1, row, true)[1]
                        local ok, indent = pcall(treesitter.get_indent, row)

                        if not ok then
                            indent = 0
                        end

                        -- https://www.reddit.com/r/neovim/comments/1817q4a/how_to_replicate_vscode_copilot_ghost_text/
                        -- https://github.com/willothy/nvim-config/blob/main/lua/configs/editor/cmp.lua
                        --
                        if cmp.visible() then
                            cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
                        elseif vim.snippet.jumpable(1) then
                            vim.snippet.jump(1)
                        elseif col < indent and line:sub(1, col):gsub("^%s+", "") == "" then
                            --
                            -- Smart indent like VSCode - indent to the correct level when pressing tab at the beginning of a line.
                            vim.api.nvim_buf_set_lines(0, row - 1, row, true, {
                                string.rep(" ", indent or 0) .. line:sub(col),
                            })

                            vim.api.nvim_win_set_cursor(0, { row, math.max(0, indent) })

                            vim.lsp.inlay_hint.on_refresh(nil, nil, {
                                client_id = vim.lsp.get_clients({ bufnr = vim.api.nvim_get_current_buf() })[1].id,
                                bufnr = vim.api.nvim_get_current_buf(),
                            }, nil)
                        elseif col >= indent and col ~= 0 then
                            require("tabout").tabout()
                        else
                            fallback()
                        end
                    end),
                    ["<S-Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_prev_item()
                        elseif vim.snippet.jumpable(1) then
                            vim.snippet.jump(1)
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
                performance = {
                    max_view_entries = 100,
                },
                preselect = cmp.PreselectMode.Item,
                snippet = {
                    expand = function(args)
                        vim.snippet.expand(args.body)
                    end,
                },
                sorting = {
                    comparators = {
                        cmp.config.compare.offset,
                        cmp.config.compare.exact,
                        cmp.config.compare.scopes,
                        function(entry1, entry2) -- sort by length ignoring "=~"
                            local len1 = string.len(string.gsub(entry1.completion_item.label, "[=~()_]", ""))
                            local len2 = string.len(string.gsub(entry2.completion_item.label, "[=~()_]", ""))
                            if len1 ~= len2 then
                                return len1 - len2 < 0
                            end
                        end,
                        function(entry1, entry2) -- sort by compare kind (Variable, Function etc)
                            local kind1 = modified_kind(entry1:get_kind())
                            local kind2 = modified_kind(entry2:get_kind())
                            if kind1 ~= kind2 then
                                return kind1 - kind2 < 0
                            end
                        end,
                        cmp.config.compare.sort_text,
                        cmp.config.compare.score,
                        cmp.config.compare.order,
                    },
                },
                sources = cmp.config.sources({
                    {
                        name = "snippets",
                        max_item_count = 3,
                    },
                    {
                        name = "nvim_lsp",
                        -- https://github.com/hrsh7th/nvim-cmp/pull/1067
                        --
                        entry_filter = function(entry, ctx)
                            local kind = entry:get_kind()
                            local line = ctx.cursor_line
                            local col = ctx.cursor.col
                            local char_before_cursor = string.sub(line, col - 1, col - 1)

                            -- Don't complete LSP symbols in comments or strings.
                            if is_string_like() then
                                return false
                            end

                            -- Don't return "Text" types from LSP completion.
                            if vim.tbl_contains({
                                types.CompletionItemKind.Text,
                            }, kind) then
                                return false
                            end

                            if char_before_cursor == "." then
                                return vim.tbl_contains({
                                    types.CompletionItemKind.Method,
                                    types.CompletionItemKind.Field,
                                    types.CompletionItemKind.Property,
                                }, kind)
                            end

                            if string.match(line, "^%s+%w+$") then
                                return kind == types.CompletionItemKind.Function or kind == types.CompletionItemKind.Variable
                            end

                            return true
                        end,
                    },
                    { name = "calc" },
                    { name = "async_path" },
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

            cmp.setup.filetype({ "bash", "sh", "zsh" }, {
                sources = cmp.config.sources({
                    { name = "nvim_lsp" },
                    { name = "snippets" },
                    { name = "async_path" },
                    { name = "env" },
                    { name = "buffer" },
                }),
            })

            -- Completions for : command mode
            cmp.setup.cmdline(":", {
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
        "chrisgrieser/nvim-scissors",
        cmd = { "ScissorsAddNewSnippet", "ScissorsEditSnippet" },
        keys = {
            { "<leader>sa", vim.cmd.ScissorsAddNewSnippet, desc = "Add new snippet" },
            { "<leader>se", vim.cmd.ScissorsEditSnippet, desc = "Add edit snippet" },
        },
        opts = {
            editSnippetPopup = {
                border = vim.g.border,
            },
            jsonFormatter = "jq",
            snippetDir = vim.fn.stdpath("config") .. "/snippets",
        },
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
        "hrsh7th/nvim-insx",
        config = function()
            local insx = require("insx")
            local esc = insx.helper.regex.esc

            local endwise = require("insx.recipe.endwise")
            local jump = require("insx.recipe.jump_next")
            local pair = require("insx.recipe.auto_pair")
            local delete = require("insx.recipe.delete_pair")
            local fast_break = require("insx.recipe.fast_break")

            -- Wrap next token: `(|)function(...)` -> `)` -> `(function(...)|)`
            local fast_wrap = require("insx.recipe.fast_wrap")

            -- https://gitspartv.github.io/lua-patterns/
            for open, close in pairs({
                ["("] = ")",
                ["["] = "]",
                ["{"] = "}",
                ["<"] = ">",
            }) do
                insx.add(close, jump({ jump_pat = { [[\%#]] .. esc(close) .. [[\zs]] } }))
                insx.add(open, pair.strings({ open = open, close = close }))

                insx.add("<BS>", delete({ open_pat = esc(open), close_pat = esc(close) }))
                insx.add("<CR>", fast_break({ open_pat = esc(open), close_pat = esc(close), html_attrs = true, arguments = true }))
                insx.add("<C-]>", fast_wrap({ close = close }))
            end

            for _, quote in ipairs({ '"', "`" }) do
                -- Jump_out
                insx.add(quote, jump({ jump_pat = { [[\\\@<!\%#]] .. esc(quote) .. [[\zs]] } }))

                insx.add(
                    quote,
                    insx.with(pair({ open = quote, close = quote }), {
                        insx.with.in_string(false),
                        insx.with.in_comment(false),
                        -- insx.with.nomatch([[\%#\W]]), -- Don't match if there is a non-word character after the cursor.
                        insx.with.nomatch([[[.-]\%#]]), -- Don't match if there is a dot or dash before the cursor.
                        insx.with.undopoint(false),
                    })
                )

                insx.add(
                    "<BS>",
                    insx.with(delete.strings({ open_pat = esc(quote), close_pat = esc(quote) }), {
                        insx.with.in_string(false),
                        insx.with.in_comment(false),
                        insx.with.nomatch(([[\\%s\%%#]]):format(esc(quote))),
                    })
                )

                insx.add("<C-]>", insx.with(fast_wrap({ close = quote }), { insx.with.undopoint(false) }))
            end

            insx.add("'", jump({ jump_pat = { [[\\\@<!\%#]] .. esc("'") .. [[\zs]] } }))

            insx.add(
                "'",
                insx.with(pair.strings({ open = "'", close = "'", ignore_pat = { [[\%#\w]], [[\a\%#]] } }), {
                    insx.with.in_string(false),
                    insx.with.in_comment(false),
                    insx.with.nomatch([[\%#\w]]),
                    insx.with.nomatch([[\a\%#]]),

                    -- Don't pair '' in a Rust lifetime position.
                    insx.with.nomatch([[&\%#]]),
                    insx.with.nomatch([[\h\w*<.*\%#]]),

                    insx.with.undopoint(false),
                    insx.with.priority(0),
                })
            )

            insx.add(
                "<BS>",
                insx.with(delete.strings({ open_pat = esc("'"), close_pat = esc("'") }), {
                    insx.with.in_string(false),
                    insx.with.in_comment(false),
                    insx.with.nomatch(([[\\%s\%%#]]):format(esc("'"))),
                })
            )

            -- Auto HTML tags.
            insx.add(
                ">",
                insx.with(
                    require("insx.recipe.substitute")({
                        pattern = [[<\(\w\+\).\{-}\%#]],
                        replace = [[\0>\%#</\1>]],
                    }),
                    {
                        insx.with.filetype({ "html" }),
                        insx.with.priority(1),
                    }
                )
            )
            -- Delete HTML tags.
            insx.add(
                "<BS>",
                insx.with(
                    require("insx.recipe.substitute")({
                        pattern = [[<\(\w\+\).\{-}>\%#</.\{-}>]],
                        replace = [[\%#]],
                    }),
                    {
                        insx.with.filetype({ "html" }),
                        insx.with.priority(1),
                    }
                )
            )

            insx.add(
                "<CR>",
                insx.with(fast_break({ open_pat = [[```\w*]], close_pat = "```", indent = 0 }), {
                    insx.with.filetype({ "markdown", "typst" }),
                    insx.with.priority(1),
                })
            )

            insx.add("<CR>", fast_break({ open_pat = insx.helper.search.Tag.Open, close_pat = insx.helper.search.Tag.Close }))

            -- Python triple quotes.
            insx.add([["]], {
                enabled = function(ctx)
                    return ctx.match([["\%#"]]) and ctx.filetype == "python"
                end,
                action = function(ctx)
                    if ctx.match([["""\%#"""]]) then
                        return
                    end
                    ctx.send([[""<Left>]])
                    ctx.send([[""<Left>]])
                end,
                priority = 1,
            })

            insx.add(
                "<CR>",
                insx.with(fast_break({ open_pat = [["""\w*]], close_pat = [["""]], indent = 0 }), {
                    insx.with.filetype({ "python" }),
                    insx.with.priority(1),
                })
            )

            -- Rust lifetime and <> behavior.
            insx.add(
                "<",
                insx.with(pair({ open = "<", close = ">" }), {
                    insx.with.filetype({ "rust" }),
                    insx.with.in_string(false),
                    insx.with.in_comment(false),
                    insx.with.match([[[\a:].\%#]]),
                    insx.with.undopoint(false),
                    insx.with.priority(1),
                })
            )

            -- Add additional end-wise matches.
            endwise.builtin["fish"] = {
                endwise.simple([[\<begin\>.*]], "end"),
                endwise.simple([[\<for\>.*]], "end"),
                endwise.simple([[\<function\>.*]], "end"),
                endwise.simple([[\<if\>.*]], "end"),
                endwise.simple([[\<switch\>.*]], "end"),
                endwise.simple([[\<while\>.*]], "end"),
            }

            endwise.builtin["sh"] = {
                endwise.simple([[\<case\>.*\<in\>]], "esac"),
                endwise.simple([[\<if\>.*\<then\>]], "fi"),
                endwise.simple([[\<while\>.*\<do\>]], "done"),
            }

            insx.add("<CR>", endwise(endwise.builtin))

            insx.add("<Tab>", {
                ---@param ctx insx.Context
                action = function(ctx)
                    local row, col = ctx.row(), ctx.col()

                    if vim.snippet.jumpable(1) then
                        ctx.send(":lua vim.snippet.jump(1)")
                    else
                        if vim.iter({ [["]], "'", "]", "}", ")", "`", "$" }):find(ctx.after():sub(1, 1)) ~= nil then
                            ctx.move(row, col + 1)
                        else
                            ctx.send("<Tab>")
                        end
                    end
                end,
            })
        end,
        event = "InsertEnter",
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
                hover = true,
            },
            on_attach = function()
                require("cmp").setup.buffer({
                    sources = {
                        { name = "async_path" },
                        { name = "buffer" },
                        { name = "nvim_lsp" },
                    },
                })
            end,
            popup = {
                autofocus = true,
                border = vim.g.border,
            },
        },
    },
    {
        "mtoohey31/cmp-fish",
        config = function()
            require("cmp").setup.buffer({
                sources = {
                    { name = "fish" },
                    { name = "snippets" },
                    { name = "async_path" },
                    { name = "env" },
                    { name = "calc" },
                    { name = "buffer" },
                },
            })
        end,
        dependencies = {
            "FelipeLema/cmp-async-path",
            "bydlw98/cmp-env",
            "hrsh7th/cmp-buffer",
        },
        ft = "fish",
    },
    {
        "hrsh7th/cmp-buffer",
        config = function()
            require("cmp").setup.buffer({
                sources = {
                    { name = "nvim_lsp" },
                    { name = "snippets" },
                    { name = "async_path" },
                    { name = "env" },
                    { name = "calc" },
                    { name = "buffer" },
                },
            })
        end,
        dependencies = {
            "FelipeLema/cmp-async-path",
            "bydlw98/cmp-env",
            "hrsh7th/cmp-buffer",
        },
        ft = { "bash", "sh", "zsh" },
    },
    {
        "vrslev/cmp-pypi",
        config = function()
            require("cmp").setup.buffer({
                sources = {
                    { name = "pypi" },
                    { name = "buffer" },
                },
            })
        end,
        dependencies = "hrsh7th/cmp-buffer",
        event = { "BufRead pyproject.toml" },
    },
    {
        "MeanderingProgrammer/py-requirements.nvim",
        config = function()
            local requirements = require("py-requirements")

            vim.keymap.set("n", "<leader>ru", requirements.upgrade, { buffer = true, desc = "Requirements: Upgrade" })
            vim.keymap.set("n", "<leader>rU", requirements.upgrade_all, { buffer = true, desc = "Requirements: Upgrade All" })
            vim.keymap.set("n", "K", requirements.show_description, { buffer = true, desc = "Requirements: Show package description" })

            requirements.setup({
                enable_cmp = true,
                float_opts = { border = vim.g.border },
            })

            require("cmp").setup.buffer({
                sources = {
                    { name = "py-requirements" },
                    { name = "buffer" },
                },
            })
        end,
        dependencies = "hrsh7th/cmp-buffer",
        ft = "requirements",
    },
}
