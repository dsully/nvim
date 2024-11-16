return {
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
                    elseif cmp.windows.autocomplete.win:is_open() then
                        cmp.hide()
                    elseif copilot.is_visible() then
                        copilot.dismiss()
                    end
                end,
                desc = "Hide Completion",
                mode = { "i", "c" },
            },
        },
        opts = {
            accept = {
                auto_brackets = {
                    enabled = true,
                },
            },
            ghost_text = {
                enabled = false,
            },
            keymap = {
                ["<CR>"] = { "accept", "fallback" },

                ["<Tab>"] = { "select_next", "fallback" },
                ["<Down>"] = { "select_next", "fallback" },
                ["<C-j>"] = { "select_next", "fallback" },

                ["<S-Tab>"] = { "select_prev", "fallback" },
                ["<Up>"] = { "select_prev", "fallback" },
                ["<C-k>"] = { "select_prev", "fallback" },
            },
            kind_icons = defaults.icons.lsp,
            nerd_font_variant = "mono",
            sources = {
                completion = {
                    enabled_providers = { "lsp", "path", "snippets", "lazydev" },
                },
                providers = {
                    buffer = {
                        fallback_for = {},
                        max_items = 4,
                        min_keyword_length = 4,
                        score_offset = -3,
                    },
                    lazydev = {
                        name = "LazyDev",
                        module = "lazydev.integrations.blink",
                    },
                    -- Don/t show LuaLS require statements when lazydev has items
                    lsp = {
                        fallback_for = { "lazydev" },
                    },
                    path = {
                        opts = { get_cwd = vim.uv.cwd },
                    },
                    snippets = {
                        min_keyword_length = 1, -- don't show when triggered manually, useful for JSON keys
                        score_offset = -1,
                    },
                },
            },
            trigger = {
                signature_help = {
                    enabled = false,
                },
            },
            windows = {
                autocomplete = {
                    cycle = { from_top = false }, -- cycle at bottom, but not at the top
                    -- https://github.com/Saghen/blink.cmp/blob/f456c2aa0994f709f9aec991ed2b4b705f787e48/lua/blink/cmp/windows/autocomplete.lua#L227
                    ---@param ctx blink.cmp.CompletionRenderContext
                    draw = function(ctx)
                        local icon = ctx.kind_icon

                        -- Give path completions a different set of icons.
                        if ctx.item.source_name == "blink.cmp.sources.path" then
                            local fi, _ = require("mini.icons").get("file", ctx.item.label)

                            if fi ~= nil then
                                icon = fi
                            end
                        end

                        -- Strip the `pub fn` prefix from Rust functions.
                        -- Strip method & function parameters.
                        if ctx.item.detail ~= nil then
                            ctx.item.detail = ctx.item.detail:gsub("pub fn (.+)", "%1"):gsub("(.+)%(.+%)~", "%1()")
                        end

                        return {
                            {
                                " " .. ctx.item.label .. " ",
                                fill = true,
                                hl_group = ctx.deprecated and "BlinkCmpLabelDeprecated" or "BlinkCmpLabel",
                            },
                            { icon .. " ", hl_group = "BlinkCmpKind" .. ctx.kind },
                        }
                    end,
                    selection = "manual",
                },
                documentation = {
                    border = defaults.ui.border.name,
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
            -- local cache = {} ---@type table<string,table<string,string>>
            local hl_groups = {} ---@type table<string,boolean>

            local get_hl_group = function(hl)
                local group = vim.inspect(hl):gsub("%W+", "_")

                if not hl_groups[group] then
                    hl = type(hl) == "string" and { link = hl } or hl
                    hl = vim.deepcopy(hl, true)

                    hl.fg = hl.fg or colors.gray.base

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
                            "%f[%w]()colors%.[%w_%.]+()%f[%W]",
                            "%f[%w]()defaults.colors%.[%w_%.]+()%f[%W]",
                        },
                        group = function(_, match)
                            local parts = vim.split(match, ".", { plain = true })

                            if (parts[1] == "M" or parts[1] == "defaults") and parts[2] == "colors" then
                                table.remove(parts, 1)
                                table.remove(parts, 1)
                            end

                            if parts[1] == "colors" then
                                table.remove(parts, 1)
                            end

                            local color = vim.tbl_get(colors, unpack(parts))

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
                        group = function(_, _match, _data)
                            ---@type string
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

            hl.apply({
                { MiniIndentscopeSymbol = { fg = colors.blue.bright } },
                { MiniIndentscopePrefix = { nocombine = true } },
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

            Snacks.toggle
                .new({
                    name = "Mini Pairs",
                    get = function()
                        return not vim.g.minipairs_disable
                    end,
                    set = function(state)
                        vim.g.minipairs_disable = not state
                    end,
                })
                :map("<space>tp")

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
            -- https://gitspartv.github.io/lua-patterns/
            -- https://riptutorial.com/lua/example/20315/lua-pattern-matching
            mappings = {
                -- Map <cr> to false to prevent conflict with blink.cmp.
                --
                -- Prevents the action if the cursor is just before any character or next to a "\".
                ["("] = { action = "open", pair = "()", neigh_pattern = "[^\\][%s%)%]%}]", register = { cr = false } },
                ["["] = { action = "open", pair = "[]", neigh_pattern = "[^\\][%s%)%]%}]", register = { cr = false } },
                ["{"] = { action = "open", pair = "{}", neigh_pattern = "[^\\][%s%)%]%}]", register = { cr = false } },

                -- This is default (prevents the action if the cursor is just next to a "\").
                [")"] = { action = "close", pair = "()", neigh_pattern = "[^\\].", register = { cr = false } },
                ["]"] = { action = "close", pair = "[]", neigh_pattern = "[^\\].", register = { cr = false } },
                ["}"] = { action = "close", pair = "{}", neigh_pattern = "[^\\].", register = { cr = false } },

                -- Don't autocomplete quotes around letters, except f-strings
                ['"'] = {
                    action = "closeopen",
                    pair = '""',
                    neigh_pattern = '[^A-Za-eg-z0-9\\"][^%w]',
                    register = { cr = false },
                },

                -- Prevents the action if the cursor is just before or next to any character.
                ["`"] = { action = "closeopen", pair = "``", neigh_pattern = "[^%w][^%w]", register = { cr = false } },

                -- Restrict ' with < and & for Rust
                ["'"] = { neigh_pattern = "[^%a\\|'|<|&].", register = { cr = false } },

                -- Add | for Rust iterations
                ["|"] = { action = "closeopen", pair = "||", neigh_pattern = "[(][)]", register = { cr = false } },
            },

            -- Deal with markdown code blocks better.
            markdown = true,

            -- In which modes mappings from this config should be created
            modes = { insert = true, command = false, terminal = false },

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
        opts = {
            completion = {
                cmp = {
                    enabled = false,
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
                bindings = {
                    ["q"] = vim.cmd.OverseerClose,
                },
                default_detail = 1,
                direction = "bottom",
                min_height = 25,
                max_height = 25,
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
