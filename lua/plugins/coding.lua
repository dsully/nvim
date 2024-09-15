return {
    {
        "yioneko/nvim-cmp",
        branch = "perf",
        cmd = "CmpStatus",
        config = function()
            local cmp = require("cmp")
            local helpers = require("helpers.cmp")
            local icons = require("mini.icons")

            local cmp_rs = require("cmp_lsp_rs").comparators
            local copilot = require("copilot.suggestion")

            -- Better visibility check than cmp.visible().
            local function is_visible(_)
                return cmp.core.view:visible() or vim.fn.pumvisible() == 1
            end

            -- Inside a snippet, use backspace to remove the placeholder.
            vim.keymap.set("s", "<BS>", "<C-O>s")

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
                    --
                    -- kind is icon, abbr is completion name, menu is [Function]
                    fields = { "kind", "abbr", "menu" },
                    --
                    ---@param entry cmp.Entry
                    ---@param item vim.CompletedItem
                    ---@return vim.CompletedItem
                    format = function(entry, item)
                        --
                        -- Give path completions a different set of icons.
                        if entry.source.name == "path" then
                            local icon, hl_group = icons.get("file", entry:get_completion_item().label)

                            if icon ~= nil then
                                item.kind = icon
                                item.kind_hl_group = hl_group
                            end

                            return item
                        else
                            local icon, hl_group = icons.get("lsp", item.kind)

                            if icon ~= nil then
                                item.kind = icon
                                item.kind_hl_group = hl_group
                            end
                        end

                        -- Strip the `pub fn` prefix from Rust functions.
                        -- Strip method & function parameters.
                        item.abbr = item.abbr:gsub("pub fn (.+)", "%1"):gsub("(.+)%(.+%)~", "%1()")

                        if entry.source ~= nil and entry.source.name ~= nil and entry.source.name ~= "nvim_lsp" then
                            item.menu = " " .. (defaults.cmp.menu[entry.source.name] or "")
                        else
                            item.menu = ""
                        end

                        for key, width in pairs(defaults.cmp.widths) do
                            if item[key] and vim.fn.strdisplaywidth(item[key]) > width then
                                item[key] = vim.fn.strcharpart(item[key], 0, width - 1) .. defaults.icons.misc.ellipsis
                            end
                        end

                        return item
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
                        cmp_rs.inherent_import_inscope,
                        cmp_rs.sort_by_label_but_underscore_last,
                        cmp_rs.sort_by_kind,
                        cmp_rs.sort_by_label_but_underscore_nil,
                        cmp_rs.sort_underscore,
                    },
                    priority_weight = 1.0,
                },
                sources = cmp.config.sources({
                    helpers.config.snippets,
                    helpers.config.lsp(),
                    helpers.config.lazydev,
                    helpers.config.path,
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

            cmp.setup(opts)

            cmp.setup.filetype({ "bash", "fish", "sh", "zsh" }, {
                sources = cmp.config.sources({
                    helpers.config.lsp(),
                    helpers.config.snippets,
                    helpers.config.buffer,
                    helpers.config.path,
                    helpers.config.env,
                }),
            })

            -- Completions for : command mode
            cmp.setup.cmdline(":", {
                mapping = cmp.mapping.preset.cmdline(),
                sources = cmp.config.sources({
                    helpers.config.path,
                    helpers.config.cmdline,
                }),
            })

            -- https://github.com/hrsh7th/cmp-cmdline/issues/94
            ev.on(ev.CmdWinEnter, cmp.close)
        end,
    },
    { "hrsh7th/cmp-buffer", event = ev.InsertEnter },
    { "hrsh7th/cmp-cmdline", event = ev.CmdlineEnter },
    { "hrsh7th/cmp-nvim-lsp" },
    { "hrsh7th/cmp-path", event = ev.InsertEnter },
    { "SergioRibera/cmp-dotenv", event = ev.InsertEnter },
    {
        "garymjr/nvim-snippets",
        opts = {
            friendly_snippets = true,
        },
    },
    { "zjp-CN/nvim-cmp-lsp-rs" },
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
            local hp = require("mini.hipatterns")

            local vtext = defaults.icons.misc.circle_filled_large
            local cache = {} ---@type table<string,table<string,string>>
            local hl_groups = {} ---@type table<string,boolean>

            local get_hl_group = function(hl)
                local group = vim.inspect(hl):gsub("%W+", "_")

                if not hl_groups[group] then
                    hl = type(hl) == "string" and { link = hl } or hl
                    hl = vim.deepcopy(hl, true)

                    hl.fg = hl.fg or defaults.colors.gray.base

                    if hl.fg == hl.bg then
                        hl.fg = nil
                    end

                    vim.api.nvim_set_hl(0, group, hl)

                    hl_groups[group] = true
                end

                return group
            end

            local extmark_opts = { priority = 2000 }

            local extmark_vtext = function(_, _, data)
                return vim.tbl_extend("force", extmark_opts, { virt_text = { { vtext, data.hl_group } }, virt_text_pos = "eol" })
            end

            return {
                highlighters = {
                    -- Match against hex colors with no leading `#`.
                    bare_hex = {
                        pattern = "[ =:'\"]()%x%x%x%x%x%x%f[%X]",
                        group = function(_, match, _)
                            return hp.compute_hex_color_group("#" .. match, "bg")
                        end,
                        extmark_opts = extmark_opts,
                    },
                    hex_color = hp.gen_highlighter.hex_color({ priority = 2000 }),
                    nvim_hl_colors = {
                        pattern = {
                            "%f[%w]()M.colors%.[%w_%.]+()%f[%W]",
                            "%f[%w]()defaults.colors%.[%w_%.]+()%f[%W]",
                        },
                        group = function(_, match)
                            local parts = vim.split(match, ".", { plain = true })

                            if (parts[1] == "M" or parts[1] == "defaults") and parts[2] == "colors" then
                                table.remove(parts, 1)
                                table.remove(parts, 1)
                            end

                            local color = vim.tbl_get(defaults.colors, unpack(parts))

                            return type(color) == "string" and get_hl_group({ fg = color })
                        end,
                        extmark_opts = extmark_vtext,
                    },
                    shorthand = {
                        pattern = "()#%x%x%x()%f[^%x%w]",
                        group = function(_, _, data)
                            ---@type string
                            local match = data.full_match
                            local r, g, b = match:sub(2, 2), match:sub(3, 3), match:sub(4, 4)
                            local hex_color = "#" .. r .. r .. g .. g .. b .. b

                            return hp.compute_hex_color_group(hex_color, "bg")
                        end,
                        extmark_opts = extmark_opts,
                    },
                    separated = {
                        pattern = "%[()%d+,%s*%d+,%s*%d+()%]",
                        group = function(_, _match, data)
                            ---@type string
                            dbg(data.full_match)
                            local r, g, b = _match:match("(%d+),%s*(%d+),%s*(%d+)")
                            local hex_color = string.format("#%02X%02X%02X", r, g, b)

                            return hp.compute_hex_color_group(hex_color, "fg")
                        end,
                        extmark_opts = extmark_vtext,
                    },
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
        event = ev.InsertEnter,
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
        opts = {},
    },
    {
        "stevearc/overseer.nvim",
        cmd = {
            "CompilerOpen",
            "CompilerToggleResults",
            "CompilerRedo",
            "OverseerRun",
            "OverseerToggle",
        },
        opts = {
            confirm = {
                border = defaults.ui.border.name,
            },
            form = {
                border = defaults.ui.border.name,
            },
            help_win = {
                border = defaults.ui.border.name,
            },
            task_list = {
                direction = "bottom",
                min_height = 25,
                max_height = 25,
                -- default_detail = 1,
                bindings = {
                    ["q"] = vim.cmd.OverseerClose,
                },
            },
            task_win = {
                border = defaults.ui.border.name,
            },
        },
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
