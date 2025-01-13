---@type LazySpec[]
return {
    { "echasnovski/mini.nvim" },
    {
        -- Better Around/Inside text-objects
        --
        -- Examples:
        --  - va)  - Visually select [A]round [)]parenthesis
        --  - yinq - Yank Inside [N]ext [']quote
        --  - ci'  - Change Inside [']quote
        --
        -- https://www.reddit.com/r/neovim/comments/10qmicv/help_understanding_miniai_custom_textobjects/
        "echasnovski/mini.ai",
        config = function(_, opts)
            --
            vim.schedule(function()
                local ai = require("mini.ai")

                ai.setup({
                    custom_textobjects = {
                        -- 'vaF' to select around function definition.
                        -- 'diF' to delete inside function definition.
                        c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }),
                        f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }),
                        l = require("mini.extra").gen_ai_spec.line(),

                        o = ai.gen_spec.treesitter({ -- code block
                            a = { "@block.outer", "@conditional.outer", "@loop.outer" },
                            i = { "@block.inner", "@conditional.inner", "@loop.inner" },
                        }),
                    },
                    n_lines = 2000,
                })

                ev.on_load("which-key.nvim", function()
                    local objects = {
                        { " ", desc = "whitespace" },
                        { '"', desc = '" string' },
                        { "'", desc = "' string" },
                        { "(", desc = "() block" },
                        { ")", desc = "() block with ws" },
                        { "<", desc = "<> block" },
                        { ">", desc = "<> block with ws" },
                        { "?", desc = "user prompt" },
                        { "U", desc = "use/call without dot" },
                        { "[", desc = "[] block" },
                        { "]", desc = "[] block with ws" },
                        { "_", desc = "underscore" },
                        { "`", desc = "` string" },
                        { "a", desc = "argument" },
                        { "b", desc = ")]} block" },
                        { "c", desc = "class" },
                        { "d", desc = "digit(s)" },
                        { "e", desc = "CamelCase / snake_case" },
                        { "f", desc = "function" },
                        { "g", desc = "entire file" },
                        { "i", desc = "indent" },
                        { "o", desc = "block, conditional, loop" },
                        { "q", desc = "quote `\"'" },
                        { "t", desc = "tag" },
                        { "u", desc = "use/call" },
                        { "{", desc = "{} block" },
                        { "}", desc = "{} with ws" },
                    }

                    ---@type wk.Spec[]
                    local ret = { mode = { "o", "v" } }

                    ---@type table<string, string>
                    local mappings = vim.tbl_extend("force", {}, {
                        around = "a",
                        inside = "i",
                        around_next = "an",
                        inside_next = "in",
                        around_last = "al",
                        inside_last = "il",
                    }, opts.mappings or {})

                    mappings.goto_left = nil
                    mappings.goto_right = nil

                    for name, prefix in pairs(mappings) do
                        name = name:gsub("^around_", ""):gsub("^inside_", "")
                        ret[#ret + 1] = { prefix, group = name }

                        for _, obj in ipairs(objects) do
                            local desc = obj.desc

                            if prefix:sub(1, 1) == "i" then
                                desc = desc:gsub(" with ws", "")
                            end

                            ret[#ret + 1] = { prefix .. obj[1], desc = desc }
                        end
                    end

                    require("which-key").add(ret, { notify = false })
                end)
            end)
        end,
        event = ev.LazyFile,
        virtual = true,
    },
    {
        "echasnovski/mini.align",
        keys = {
            { "g=", desc = "mini.align: align", mode = { "n", "v" } },
            { "g+", desc = "mini.align: align with preview", mode = { "n", "" } },
        },
        opts = {
            mappings = {
                start = "g=",
                start_with_preview = "g+",
            },
        },
        virtual = true,
    },
    {
        -- Use [ and ] to move between various things.
        "echasnovski/mini.bracketed",
        keys = {
            { "[c", desc = "comment previous " },
            { "]c", desc = "comment next" },
            { "[w", desc = "window previous" },
            { "]w", desc = "window next" },
            { "[x", desc = "conflict marker previous" },
            { "]x", desc = "conflict marker next" },
        },
        opts = {
            buffer = { suffix = "" },
            file = { suffix = "" },
            diagnostic = { suffix = "" }, -- Built in.
            indent = { suffix = "" },
            jump = { suffix = "" },
            location = { suffix = "" },
            oldfile = { suffix = "" },
            quickfix = { suffix = "" },
            treesitter = { suffix = "" },
            undo = { suffix = "" },
            yank = { suffix = "" },
        },
        virtual = true,
    },
    {
        "echasnovski/mini.hipatterns",
        event = ev.LazyFile,
        opts = function()
            local vtext = defaults.icons.misc.circle_filled_large
            local extmark_opts = { priority = 2000 }

            local extmark_vtext = function(_, _, data)
                return vim.tbl_extend("force", extmark_opts, { virt_text = { { vtext, data.hl_group } }, virt_text_pos = "eol" })
            end

            return {
                highlighters = {
                    -- Match against hex colors with no leading `#` as well.
                    hex = {
                        pattern = "[ =:'\"]()#?%x%x%x%x%x%x%f[%X]",
                        group = function(_, match, _)
                            local color = vim.startswith(match, "#") and match or "#" .. match

                            return require("mini.hipatterns").compute_hex_color_group(color, "bg")
                        end,
                        extmark_opts = extmark_opts,
                    },
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

                            return type(color) == "string" and require("helpers.highlights").group({ fg = color })
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

                            return require("mini.hipatterns").compute_hex_color_group(hex_color, "bg")
                        end,
                        extmark_opts = extmark_opts,
                    },
                    separated = {
                        pattern = "%[()%d+,%s*%d+,%s*%d+()%]",
                        group = function(_, matched, _data)
                            ---@type string
                            local r, g, b = matched:match("(%d+),%s*(%d+),%s*(%d+)")
                            local hex_color = matched.format("#%02X%02X%02X", r, g, b)

                            return require("mini.hipatterns").compute_hex_color_group(hex_color, "fg")
                        end,
                        extmark_opts = extmark_vtext,
                    },
                },
            }
        end,
        virtual = true,
    },
    {
        "echasnovski/mini.icons",
        init = function()
            hl.apply({
                MiniIconsAzure = { fg = colors.blue.bright },
                MiniIconsBlue = { fg = colors.blue.base },
                MiniIconsCyan = { fg = colors.cyan.base },
                MiniIconsGreen = { fg = colors.green.base },
                MiniIconsGrey = { fg = colors.gray.bright },
                MiniIconsOrange = { fg = colors.orange.base },
                MiniIconsPurple = { fg = colors.magenta.base },
                MiniIconsRed = { fg = colors.red.base },
                MiniIconsYellow = { fg = colors.yellow.base },
            })

            package.preload["nvim-web-devicons"] = function()
                require("mini.icons").mock_nvim_web_devicons()
                return package.loaded["nvim-web-devicons"]
            end
        end,
        opts = {
            style = "glyph",
            default = {
                extension = { glyph = " " },
                file = { glyph = " ", color = "#6F839E" },
                filetype = { glyph = " " },
            },
            filetype = {
                brewfile = { glyph = "🍺" },
            },
            file = {
                ["init.lua"] = { glyph = "󰢱 ", hl = "MiniIconsAzure" },
                ["package.json"] = { glyph = " ", hl = "MiniIconsGreen" },
                ["tsconfig.build.json"] = { glyph = " ", hl = "MiniIconsAzure" },
                ["tsconfig.json"] = { glyph = " ", hl = "MiniIconsAzure" },
                [".chezmoiignore"] = { glyph = " ", hl = "MiniIconsGrey" },
                [".chezmoiremove"] = { glyph = " ", hl = "MiniIconsGrey" },
                [".chezmoiroot"] = { glyph = " ", hl = "MiniIconsGrey" },
                [".chezmoiversion"] = { glyph = " ", hl = "MiniIconsGrey" },

                [".pre-commit-config.yaml"] = { glyph = "󰜘", color = "#eda73d" },
                [".pre-commit-hooks.yaml"] = { glyph = "󰜘", color = "#eda73d" },
                [".python-version"] = { glyph = "󰌠 ", color = "#ffe873" },
                [".ruff.toml"] = { glyph = "󱐋", color = "#fbc11a" },
                [".shellcheckrc"] = { glyph = " ", color = "#7ACECE" },
                [".yamllint"] = { glyph = "", color = "#fbc02d" },
                ["cargo.toml"] = { glyph = "󰏗 ", color = "#C27E42" },
                ["changelog.md"] = { glyph = "󰄴 ", color = "#99BE77" },
                ["go.mod"] = { glyph = " ", color = "#00ADD8" },
                ["go.sum"] = { glyph = " ", color = "#ec407a" },
                ["hosts"] = { glyph = " ", color = "#bbbbbb" },
                ["post-commit"] = { glyph = " ", color = "#f56b67" },
                ["post-receive"] = { glyph = " ", color = "#f56b67" },
                ["pre-commit"] = { glyph = " ", color = "#f56b67" },
                ["pre-push"] = { glyph = " ", color = "#f56b67" },
                ["pre-receive"] = { glyph = " ", color = "#f56b67" },
                ["pyproject.toml"] = { glyph = " ", color = "#4B8DDE" },
                ["readme.md"] = { glyph = "󰍔 ", color = "#69a3df" },
                ["requirements.txt"] = { glyph = " ", color = "#3572A5" },
                ["robots.txt"] = { glyph = "󰚩 " },
                ["ruff.toml"] = { glyph = "󱐋", color = "#fbc11a" },
                ["setup.py"] = { glyph = " ", color = "#4B8DDE" },
                ["sonar-project.properties"] = { glyph = "󰼮 ", color = "#CB2029" },
                ["tox.ini"] = { glyph = " ", color = "#b5c761" },
                ["yamllint.yaml"] = { glyph = "", color = "#fbc02d" },
            },
            extension = {
                cert = { glyph = "󰄤 ", color = "#3BD9DD" },
                crt = { glyph = "󰄤 " },
                env = { glyph = "󰙪 " },
                lock = { glyph = " ", color = "#eb4034" },
                log = { glyph = "󱞎 ", color = "#afb42b" },
                makefile = { glyph = " ", color = "#F54842" },
                out = { glyph = " " },
                properties = { glyph = " ", color = "#3970B4" },
                tmpl = { glyph = "󰈙 ", color = "#3970E4" },
            },
            lsp = defaults.icons.lsp,
        },
        virtual = true,
    },
    {
        "echasnovski/mini.pairs",
        config = function(_, opts)
            local pairs = require("mini.pairs")

            require("snacks").toggle
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
                    return "`\n```" .. Snacks.util.keycode("<up>")
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
        virtual = true,
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
        -- vim.keymap.set({ "n", "v" }, "s", "<Nop>")
        "echasnovski/mini.surround",
        -- stylua: ignore
        init = function()

            ev.on_load("mini.surround", function()
                keys.xmap('"', function() keys.feed('ma"', "t") end, "Surround Add Double Quote")
                keys.xmap("[", function() keys.feed("ma[<left>", "t") vim.schedule(function() keys.feed("%", "m") end) end, "Surround Add Square Bracket")
                keys.xmap("{", function() keys.feed("ma{<left>", "t") vim.schedule(function() keys.feed("%", "m") end) end, "Surround Add Curly Bracket")
                keys.xmap("(", function() keys.feed("ma(<left>", "t") vim.schedule(function() keys.feed("%", "m") end) end, "Surround Add Parenthesis")
                keys.xmap("`", function() keys.feed("ma`", "t") end, "Surround Add Backtick")

                -- vim.defer_fn(function() keys.xmap("<", function() keys.feed("ma<", "t") end, "Surround Add Angle Bracket") end, 2000)

                keys.map("of", function() keys.feed("<esc>m6", "n") keys.feed("daf", "m") keys.feed("`6", "n") end, "Surround Delete Function Call", "o")
            end)
        end,
        keys = function(plugin, keys)
            local opts = require("lazy.core.plugin").values(plugin, "opts", false)

            local mappings = {
                { opts.mappings.add, desc = "Add surrounding", mode = { "n", "v" } },
                { opts.mappings.delete, desc = "Delete surrounding" },
                { opts.mappings.find, desc = "Find right surrounding" },
                { opts.mappings.find_left, desc = "Find left surrounding" },
                { opts.mappings.replace, desc = "Replace surrounding" },
                { opts.mappings.update_n_lines, desc = "Update `MiniSurround.config.n_lines`" },
            }

            return vim.tbl_deep_extend("keep", mappings, keys)
        end,
        opts = {
            custom_surroundings = {
                -- ["("] = { input = { "%b()", "^.().*().$" }, output = { left = "(", right = ")" } },
                ["["] = { input = { "%b[]", "^.().*().$" }, output = { left = "[", right = "]" } },
                ["{"] = { input = { "%b{}", "^.().*().$" }, output = { left = "{", right = "}" } },
                ["<"] = { input = { "%b<>", "^.().*().$" }, output = { left = "<", right = ">" } },

                -- https://www.reddit.com/r/neovim/comments/1g14g6l/minisurround_puts_space_when_adding_surrounding/
                ["("] = { output = { left = "(", right = ")" } },
                [")"] = { output = { left = "( ", right = " )" } },
            },
            mappings = {
                add = "<leader>sa", -- Add surrounding in Normal and Visual modes
                delete = "<leader>sd", -- Delete surrounding
                find = "<leader>sf", -- Find surrounding (to the right)
                find_left = "<leader>sF", -- Find surrounding (to the left)
                highlight = "<leader>sh", -- Highlight surrounding
                replace = "<leader>sr", -- Replace surrounding
                update_n_lines = "<leader>sn", -- Update `n_lines`
            },
        },
        virtual = true,
    },
}
