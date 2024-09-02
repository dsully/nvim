return {
    {
        "yioneko/nvim-cmp",
        branch = "perf",
        cmd = "CmpStatus",
        dependencies = {
            "SergioRibera/cmp-dotenv",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-cmdline",
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-path",
            "onsails/lspkind-nvim",
            "zjp-CN/nvim-cmp-lsp-rs",
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
        event = ev.InsertEnter,
        config = function()
            local cmp = require("cmp")
            local types = require("cmp.types.lsp")
            local helpers = require("helpers.cmp")

            local copilot = require("copilot.suggestion")

            local cmp_rs = require("cmp_lsp_rs")

            local lspkind = require("lspkind").cmp_format({
                maxwidth = 50,
                mode = "symbol",
                menu = nil,
                symbol_map = defaults.cmp.symbols,
            })

            -- Better visibility check than cmp.visible().
            local function is_visible(_)
                return cmp.core.view:visible() or vim.fn.pumvisible() == 1
            end

            -- Inside a snippet, use backspace to remove the placeholder.
            vim.keymap.set("s", "<BS>", "<C-O>s")

            -- Remove Copilot ghost text when the cmp menu is opened.
            cmp.event:on("menu_opened", function()
                if package.loaded["copilot"] then
                    require("copilot.suggestion").dismiss()
                    vim.api.nvim_buf_set_var(0, "copilot_suggestion_hidden", true)
                end
            end)

            cmp.event:on("menu_closed", function()
                vim.api.nvim_buf_set_var(0, "copilot_suggestion_hidden", false)
            end)

            ---@type cmp.ConfigSchema
            local opts = {
                completion = {
                    autocomplete = {
                        cmp.TriggerEvent.InsertEnter,
                        cmp.TriggerEvent.TextChanged,
                    },
                },
                formatting = {
                    expandable_indicator = true,
                    fields = { "kind", "abbr", "menu" },
                    ---@param entry cmp.Entry
                    ---@param vim_item vim.CompletedItem
                    ---@return vim.CompletedItem
                    format = function(entry, vim_item)
                        --
                        -- Give path completions a different set of icons.
                        if entry.source.name == "path" then
                            local icon, hl_group = require("mini.icons").get("file", entry:get_completion_item().label)

                            if icon then
                                vim_item.kind = string.format(" %s ", icon)
                                vim_item.kind_hl_group = hl_group
                                return vim_item
                            end
                        end

                        local lsp_menu = defaults.cmp.menu.nvim_lsp

                        -- Rust documentation
                        local filetype = entry.context.filetype
                        local detail = entry.completion_item.labelDetails and entry.completion_item.labelDetails.detail
                        local description = entry.completion_item.labelDetails and entry.completion_item.labelDetails.description

                        if detail then
                            local pattern = ""

                            if filetype == "rust" then
                                pattern = " %((use .+)%)"

                                entry.completion_item.detail = detail:gsub(pattern, "%1")
                            end

                            lsp_menu = detail:gsub(pattern, "%1"):sub(1, 40)
                        elseif description then
                            lsp_menu = description:sub(1, 40)
                        end

                        vim_item.menu = (vim.tbl_extend("force", defaults.cmp.menu, { nvim_lsp = lsp_menu }))[entry.source.name]

                        return lspkind(entry, vim_item)
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
                    ["<CR>"] = helpers.confirm(),
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
                    disallow_fullfuzzy_matching = true,
                    disallow_fuzzy_matching = true,
                    disallow_partial_fuzzy_matching = true,
                    disallow_partial_matching = false,
                    disallow_prefix_unmatching = true,
                    disallow_symbol_nonprefix_matching = true,
                },
                performance = {
                    debounce = 0, -- default is 60ms
                    throttle = 0, -- default is 30ms
                    max_view_entries = 100,
                    async_budget = 1,
                    confirm_resolve_timeout = 80,
                    fetching_timeout = 500,
                },
                preselect = cmp.PreselectMode.Item,
                sorting = {
                    comparators = {
                        cmp.config.compare.exact,
                        cmp.config.compare.score, -- based on :  score = score + ((#sources - (source_index - 1)) * sorting.priority_weight)
                        cmp_rs.comparators.inherent_import_inscope,
                        cmp_rs.comparators.sort_by_label_but_underscore_last,
                        cmp_rs.comparators.sort_by_kind,
                        cmp_rs.comparators.sort_by_label_but_underscore_nil,
                        cmp_rs.comparators.sort_underscore,
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
                        ---@param entry cmp.Entry
                        ---@param ctx cmp.Context
                        entry_filter = function(entry, ctx)
                            local kind = entry:get_kind()
                            local line = ctx.cursor_line

                            -- Don't complete LSP symbols in comments or strings.
                            if helpers.is_string_like() then
                                return false
                            end

                            -- Don't return "Text" types from LSP completion.
                            if vim.tbl_contains({ types.CompletionItemKind.Text }, kind) then
                                return false
                            end

                            -- Better Rust sorting.
                            if ctx.filetype == "rust" and cmp_rs.filter_out.rust_filter_out_methods_to_be_imported(entry) then
                                return true
                            end

                            if string.match(line, "^%s+%w+$") then
                                return kind == types.CompletionItemKind.Function or kind == types.CompletionItemKind.Variable
                            end

                            return true
                        end,
                        keyword_length = 2,
                        priority = 7,
                    },
                    {
                        name = "lazydev",
                        group_index = 0, -- set group index to 0 to skip loading LuaLS completions
                    },
                    {
                        name = "dotenv",
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
                        border = defaults.ui.border.name,
                    }),
                },
            }

            for _, source in ipairs(opts.sources) do
                if source.name == "buffer" then
                    source.option = vim.tbl_deep_extend("keep", { get_bufnrs = helpers.get_bufnrs }, source.option or {})
                end
            end

            cmp.setup(opts)

            cmp.setup.filetype({ "bash", "fish", "sh", "zsh" }, {
                sources = cmp.config.sources({
                    { name = "nvim_lsp" },
                    { name = "snippets" },
                    { name = "path" },
                    { name = "dotenv" },
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
            ev.on(ev.CmdWinEnter, cmp.close)
        end,
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
    {
        -- Use [ and ] to move between various things.
        "echasnovski/mini.bracketed",
        event = ev.LazyFile,
        opts = {
            file = { suffix = "" },
            indent = { suffix = "" },
            jump = { suffix = "" },
            oldfile = { suffix = "" },
            treesitter = { suffix = "" },
            undo = { suffix = "" },
            yank = { suffix = "" },
        },
    },
    {
        "echasnovski/mini.bufremove",
        event = ev.LazyFile,
        opts = {
            silent = true,
        },
    },
    {
        "echasnovski/mini.hipatterns",
        event = ev.LazyFile,
        opts = function()
            return {
                highlighters = {
                    hex_color = require("mini.hipatterns").gen_highlighter.hex_color(),
                },
            }
        end,
    },
    {
        "echasnovski/mini.indentscope",
        event = ev.LazyFile,
        init = function()
            ev.on(ev.FileType, function()
                vim.b.miniindentscope_disable = true
            end, {
                pattern = defaults.ignored.file_types,
            })
        end,
        opts = function()
            return {
                draw = {
                    animation = require("mini.indentscope").gen_animation.none(),
                },
                symbol = "│",
                options = { try_as_border = true },
            }
        end,
    },
    {
        "echasnovski/mini.pairs",
        config = function(_, opts)
            local pairs = require("mini.pairs")

            keys.toggle.map("<space>tp", {
                name = "Mini Pairs",
                get = function()
                    return not vim.g.minipairs_disable
                end,
                set = function(state)
                    vim.g.minipairs_disable = not state
                end,
            })

            pairs.setup(opts)

            local open = pairs.open

            ---@diagnostic disable-next-line: duplicate-set-field
            pairs.open = function(pair, neigh_pattern)
                if vim.fn.getcmdline() ~= "" then
                    return open(pair, neigh_pattern)
                end

                local o, c = pair:sub(1, 1), pair:sub(2, 2)
                local line = vim.api.nvim_get_current_line()
                local cursor = vim.api.nvim_win_get_cursor(0)
                local next = line:sub(cursor[2] + 1, cursor[2] + 1)
                local before = line:sub(1, cursor[2])

                if opts.markdown and o == "`" and vim.bo.filetype == "markdown" and before:match("^%s*``") then
                    return "`\n```" .. vim.api.nvim_replace_termcodes("<up>", true, true, true)
                end

                if opts.skip_next and next ~= "" and next:match(opts.skip_next) then
                    return o
                end

                if opts.skip_ts and #opts.skip_ts > 0 then
                    local ok, captures = pcall(vim.treesitter.get_captures_at_pos, 0, cursor[1] - 1, math.max(cursor[2] - 1, 0))

                    for _, capture in ipairs(ok and captures or {}) do
                        if vim.tbl_contains(opts.skip_ts, capture.capture) then
                            return o
                        end
                    end
                end

                if opts.skip_unbalanced and next == c and c ~= o then
                    local _, count_open = line:gsub(vim.pesc(pair:sub(1, 1)), "")
                    local _, count_close = line:gsub(vim.pesc(pair:sub(2, 2)), "")

                    if count_close > count_open then
                        return o
                    end
                end

                return open(pair, neigh_pattern)
            end
        end,
        event = ev.VeryLazy,
        opts = {
            -- Deal with markdown code blocks better.
            markdown = true,

            -- Skip autopair when next character is one of these
            skip_next = [=[[%w%%%'%[%"%.%`%$]]=],

            -- Skip autopair when the cursor is inside these treesitter nodes
            skip_ts = { "comment", "string" },

            -- Skip autopair when next character is closing pair and there are more closing pairs than opening pairs.
            skip_unbalanced = true,
        },
    },
    {
        -- Add/delete/replace surroundings (brackets, quotes, etc.)
        --
        -- saiw) - Surround Add Inner Word [)]Parenthesis
        -- sd'   - Surround Delete [']quotes
        -- sr)'  - Surround Replace [)] [']
        -- sff`  - Surround Find part of surrounding function call (`f`).
        -- sh}   - Surround Highlight [}]
        --
        -- vim.keymap.set({ "n", "x" }, "s", "<Nop>")
        "echasnovski/mini.surround",
        optional = true,
        opts = {
            mappings = {
                add = "gza", -- Add surrounding in Normal and Visual modes
                delete = "gzd", -- Delete surrounding
                find = "gzf", -- Find surrounding (to the right)
                find_left = "gzF", -- Find surrounding (to the left)
                highlight = "gzh", -- Highlight surrounding
                replace = "gzr", -- Replace surrounding
                update_n_lines = "gzn", -- Update `n_lines`
            },
        },
        keys = {
            { "gz", "", desc = "+surround" },
        },
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
        event = { "BufReadPost Cargo.toml" },
        init = function()
            ev.on(ev.BufReadPost, function()
                require("cmp").setup.buffer({ sources = { { name = "crates" } } })
            end, {
                group = ev.group("CmpSourceCargo", true),
                pattern = "Cargo.toml",
            })
        end,
        opts = {
            completion = {
                cmp = {
                    enabled = true,
                },
                crates = {
                    enabled = true,
                },
            },
            lsp = {
                actions = true,
                completion = true,
                enabled = true,
                hover = true,
            },
            popup = {
                autofocus = true,
                border = defaults.ui.border.name,
            },
        },
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
            ev.on_load("which-key.nvim", function()
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
    {
        "folke/ts-comments.nvim",
        event = ev.VeryLazy,
        opts = {},
    },
}
