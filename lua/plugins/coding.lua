local defaults = require("config.defaults")

-- Only show matches in strings and comments.
local is_string_like = function()
    local context = require("cmp.config.context")

    return context.in_treesitter_capture("comment")
        or context.in_treesitter_capture("string")
        or context.in_syntax_group("Comment")
        or context.in_syntax_group("String")
end

return {
    {
        "hrsh7th/nvim-cmp",
        cmd = "CmpStatus",
        dependencies = {
            "hrsh7th/cmp-cmdline",
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-path",
            "onsails/lspkind-nvim",
            "ryo33/nvim-cmp-rust",
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

            -- Better visibility check than cmp.visible().
            local function is_visible(_)
                return cmp.core.view:visible() or vim.fn.pumvisible() == 1
            end

            -- Inside a snippet, use backspace to remove the placeholder.
            vim.keymap.set("s", "<BS>", "<C-O>s")

            cmp.setup({
                completion = {
                    autocomplete = {
                        cmp.TriggerEvent.TextChanged,
                        cmp.TriggerEvent.InsertEnter,
                    },
                    keyword_length = 2,
                },
                experimental = {
                    ghost_text = false,
                },
                formatting = {
                    expandable_indicator = true,
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
                            vim.snippet.stop()
                        elseif is_visible(cmp) then
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
                    ["<CR>"] = function(fallback)
                        if is_visible(cmp) then
                            if cmp.confirm({ behavior = cmp.ConfirmBehavior.Insert, select = true }) then
                                return
                            end
                        end
                        return fallback()
                    end,
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

                        if is_visible(cmp) then
                            cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
                        elseif vim.snippet.active({ direction = 1 }) then
                            vim.snippet.jump(1)
                        else
                            fallback()
                        end
                    end),
                    ["<S-Tab>"] = cmp.mapping(function(fallback)
                        if is_visible(cmp) then
                            cmp.select_prev_item()
                        elseif vim.snippet.active({ direction = -1 }) then
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
                sorting = {
                    comparators = {
                        require("cmp-rust").deprioritize_postfix,
                        require("cmp-rust").deprioritize_borrow,
                        require("cmp-rust").deprioritize_deref,
                        require("cmp-rust").deprioritize_common_traits,
                        cmp.config.compare.locality,
                        cmp.config.compare.score, -- based on :  score = score + ((#sources - (source_index - 1)) * sorting.priority_weight)
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
                        cmp.config.compare.order,
                    },
                    priority_weight = 1.0,
                },
                sources = cmp.config.sources({
                    {
                        name = "snippets",
                        max_item_count = 3,
                        priority = 8,
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
                        priority = 7,
                    },
                    {
                        name = "lazydev",
                        group_index = 0, -- set group index to 0 to skip loading LuaLS completions
                    },
                    {
                        name = "path",
                        priority = 4,
                    },
                }),
                view = {
                    entries = {
                        follow_cursor = true,
                        name = "custom", -- "native | wildmenu"
                    },
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
                    { name = "path" },
                    { name = "env" },
                    { name = "buffer" },
                }),
            })

            -- Completions for : command mode
            cmp.setup.cmdline(":", {
                mapping = cmp.mapping.preset.cmdline(),
                sources = cmp.config.sources({
                    { name = "path" },
                    -- https://github.com/hrsh7th/nvim-cmp/issues/1511
                    { name = "cmdline", keyword_pattern = [=[[^[:blank:]\!]*]=], option = { ignore_cmds = {} } },
                }),
            })

            -- https://github.com/hrsh7th/cmp-cmdline/issues/94
            vim.api.nvim_create_autocmd("CmdWinEnter", {
                callback = function()
                    require("cmp").close()
                end,
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
        "echasnovski/mini.nvim",
        config = function()
            local e = require("helpers.event")

            -- Better Around/Inside text-objects
            --
            -- Examples:
            --  - va)  - Visually select [A]round [)]parenthesis
            --  - yinq - Yank Inside [N]ext [']quote
            --  - ci'  - Change Inside [']quote
            --
            -- https://www.reddit.com/r/neovim/comments/10qmicv/help_understanding_miniai_custom_textobjects/
            require("mini.ai").setup({
                n_lines = 500,
                custom_textobjects = {
                    o = require("mini.ai").gen_spec.treesitter({
                        a = { "@block.outer", "@conditional.outer", "@loop.outer" },
                        i = { "@block.inner", "@conditional.inner", "@loop.inner" },
                    }, {}),

                    -- 'vaF' to select around function definition.
                    -- 'diF' to delete inside function definition.
                    f = require("mini.ai").gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }, {}),
                    c = require("mini.ai").gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }, {}),
                },
            })

            -- Use [ and ] to move between various things.
            require("mini.bracketed").setup({
                jump = { suffix = "" },
                oldfile = { suffix = "" },
                treesitter = { suffix = "" },
                undo = { suffix = "" },
                yank = { suffix = "" },
            })

            -- Cleanly remove buffers
            require("mini.bufremove").setup({ silent = true })

            vim.api.nvim_create_user_command("BDelete", function(args)
                require("mini.bufremove").delete(0, args.bang)
            end, { bang = true })

            vim.api.nvim_create_user_command("BWipeout", function(args)
                require("mini.bufremove").wipeout(0, args.bang)
            end, { bang = true })

            -- Show hex colors as colors.
            require("mini.hipatterns").setup({
                highlighters = {
                    hex_color = require("mini.hipatterns").gen_highlighter.hex_color(),
                },
            })

            -- Fancy indent lines.
            e.on(e.FileType, function()
                vim.b.miniindentscope_disable = true
            end, {
                pattern = require("config.defaults").ignored.file_types,
            })

            require("mini.indentscope").setup({
                draw = {
                    animation = require("mini.indentscope").gen_animation.none(),
                },
                symbol = "│",
                options = { try_as_border = true },
            })

            -- Add/delete/replace surroundings (brackets, quotes, etc.)
            --
            -- saiw) - Surround Add Inner Word [)]Parenthesis
            -- sd'   - Surround Delete [']quotes
            -- sr)'  - Surround Replace [)] [']
            -- sff`  - Surround Find part of surrounding function call (`f`).
            -- sh}   - Surround Highlight [}]
            require("mini.surround").setup()

            vim.keymap.set({ "n", "x" }, "s", "<Nop>")
        end,
        event = "LazyFile",
    },
    {
        "hrsh7th/nvim-insx",
        config = function()
            local insx = require("insx")

            local endwise = require("insx.recipe.endwise")
            local pair = require("insx.recipe.auto_pair")
            local fast_break = require("insx.recipe.fast_break")

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
                action = function(ctx)
                    local row, col = ctx.row(), ctx.col()

                    if vim.snippet.active({ direction = 1 }) then
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
                    require("refactoring").select_refactor({ show_success_message = false })
                end,
                desc = "Refactor",
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

            require("dial.config").augends:register_group({
                default = {
                    augend.integer.alias.decimal,
                    augend.integer.alias.hex,
                    augend.integer.alias.octal,
                    augend.integer.alias.binary,
                    augend.hexcolor.new({}),
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
                            return { text = text:lower(), cursor = #text } ---@diagnostic disable-line: redundant-return-value
                        end,
                    }),
                    augend.user.new({
                        find = require("dial.augend.common").find_pattern("%l+"),
                        add = function(text, _, _)
                            return { text = text:upper(), cursor = #text } ---@diagnostic disable-line: redundant-return-value
                        end,
                    }),
                    augend.case.new({
                        types = { "camelCase", "snake_case", "kebab-case", "PascalCase", "SCREAMING_SNAKE_CASE" },
                        cyclic = true,
                    }),
                    -- Markdown headers & check boxes.
                    augend.misc.alias.markdown_header,
                    augend.constant.new({
                        elements = { "- [ ]", "- [x]" },
                        word = false,
                    }),
                },
            })
        end,
        -- stylua: ignore
        keys = {
            { "<C-Up>", function() return require("dial.map").inc_normal() end, desc = "Increment Pattern", expr = true },
            { "<C-Down>", function() return require("dial.map").dec_normal() end, desc = "Decrement Pattern", expr = true },
        },
    },
    {
        "aznhe21/actions-preview.nvim",
        keys = {
            {
                -- Override Neovim default mapping.
                "gra",
                function()
                    require("actions-preview").code_actions({ context = { only = { "quickfix" } } })
                end,
                mode = { "n", "x" },
                desc = "Actions 󰅯",
            },
        },
        opts = {
            backend = { "nui" },
            diff = {
                algorithm = "patience",
                ignore_whitespace = true,
            },
        },
    },
    {
        "chrisgrieser/nvim-rulebook",
        -- stylua: ignore
        keys = {
            { "<leader>ri", function() require("rulebook").ignoreRule() end, desc = "Ignore" },
            { "<leader>rl", function() require("rulebook").lookupRule() end, desc = "Look Up" },
            { "<leader>ry", function() require("rulebook").yankDiagnosticCode() end, desc = "Yank Diagnostic" },
        },
    },
    {
        "Saecki/crates.nvim",
        event = "LazyFile",
        opts = {
            completion = {
                crates = {
                    enabled = true,
                    max_results = 8,
                    min_chars = 3,
                },
                cmp = {
                    enabled = true,
                },
            },
            lsp = {
                actions = true,
                completion = true,
                enabled = true,
                hover = true,
            },
            on_attach = function()
                require("cmp").setup.buffer({
                    sources = {
                        { name = "path" },
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
                    { name = "path" },
                    { name = "env" },
                    { name = "buffer" },
                },
            })
        end,
        dependencies = {
            "bydlw98/cmp-env",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
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
                    { name = "path" },
                    { name = "env" },
                    { name = "buffer" },
                },
            })
        end,
        dependencies = {
            "bydlw98/cmp-env",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
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
    {
        "Zeioth/compiler.nvim",
        cmd = {
            "CompilerOpen",
            "CompilerToggleResults",
            "CompilerRedo",
        },
        dependencies = {
            "stevearc/overseer.nvim",
            cmd = {
                "CompilerOpen",
                "CompilerToggleResults",
                "CompilerRedo",
                "OverseerRun",
                "OverseerToggle",
            },
            opts = {
                task_list = {
                    direction = "bottom",
                    min_height = 25,
                    max_height = 25,
                    -- default_detail = 1,
                    bindings = {
                        ["q"] = vim.cmd.OverseerClose,
                    },
                },
            },
        },
        opts = {},
    },
    {
        "chrisgrieser/nvim-chainsaw",
        init = function()
            require("helpers.event").on_load("which-key.nvim", function()
                vim.schedule(function()
                    -- stylua: ignore
                    local cs = function(fn) return function() require("chainsaw")[fn]() end end

                    require("which-key").add({
                        { "<leader>dl", group = "Log" },
                        { "<leader>dlc", cs("clearLogs"), desc = "Clear" },
                        { "<leader>dla", cs("allLogs"), desc = "All" },
                        { "<leader>dlm", cs("messageLog"), desc = "Message" },
                        { "<leader>dlv", cs("variableLog"), mode = { "n", "v" }, desc = "Variable" },
                        { "<leader>dlo", cs("objectLog"), desc = "Object" },
                        { "<leader>dlt", cs("timeLog"), desc = "Time" },
                        { "<leader>dld", cs("debugLog"), desc = "Debug" },
                        { "<leader>dlr", cs("removeLogs"), desc = "Remove" },
                        { "<leader>dlb", cs("beepLog"), desc = "Beep" },
                    }, { notify = false })
                end)
            end)
        end,
        opts = {},
    },
}
