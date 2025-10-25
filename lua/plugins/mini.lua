---@class MiniHipatterns.MatchData
---@field full_match string String with full pattern match
---@field line integer Match line number (1-indexed)
---@field from_col integer Match starting byte column (1-indexed)
---@field to_col integer Match ending byte column (1-indexed, inclusive)
---@field hl_group? string Highlight group value (available in extmark_opts function)

---@alias MiniHipatterns.Pattern string|string[]|fun(buf_id: integer): string?

---@alias MiniHipatterns.ExtmarkOpts table|fun(buf_id: integer, match: string, data: MiniHipatterns.MatchData): MiniHipatterns.MatchData?

---@class MiniHipatterns.Highlighter
---@field pattern MiniHipatterns.Pattern Lua pattern to highlight. Can be string, callable returning string, or array of those
---@field group string|fun(buf_id: integer, match: string, data: MiniHipatterns.MatchData): string?
---@field extmark_opts? MiniHipatterns.ExtmarkOpts Optional extra options for nvim_buf_set_extmark()

---@class ExtmarkOpts
---@field end_row integer?
---@field end_col integer?
---@field hl_group string?
---@field priority integer?
---@field [string] any Additional options for nvim_buf_set_extmark()
---

------@field group string|MiniHipatterns.GroupFunction Name of highlight group to use. Can be string or callable returning string

---@type LazySpec[]
return {
    { "nvim-mini/mini.nvim" },
    {
        -- Better Around/Inside text-objects
        --
        -- Examples:
        --  - va)  - Visually select [A]round [)]parenthesis
        --  - yinq - Yank Inside [N]ext [']quote
        --  - ci'  - Change Inside [']quote
        --
        -- https://www.reddit.com/r/neovim/comments/10qmicv/help_understanding_miniai_custom_textobjects/
        "nvim-mini/mini.ai",
        -- cond = false,
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

                    ---@type wk.Spec
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
        "nvim-mini/mini.align",
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
        "nvim-mini/mini.bracketed",
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
        "nvim-mini/mini.hipatterns",
        event = ev.LazyFile,
        opts = function()
            local vtext = defaults.icons.misc.circle_filled_large
            local extmark_opts = { priority = 2000 }
            local mini_hipatterns = require("mini.hipatterns")
            local compute_hex_color_group = mini_hipatterns.compute_hex_color_group

            ---@param data MiniHipatterns.MatchData
            local extmark_vtext = function(_, _, data)
                return {
                    priority = 2000,
                    virt_text = { { vtext, data.hl_group } },
                    virt_text_pos = "eol",
                }
            end

            ---@type MiniHipatterns.Highlighter
            local hex = {
                pattern = "[ =:'\"]()#?%x%x%x%x%x%x%f[%W]",
                group = function(_buf, match, _data)
                    local color = vim.startswith(match, "#") and match or "#" .. match
                    return compute_hex_color_group(color, "bg")
                end,
                extmark_opts = extmark_opts,
            }

            ---@type MiniHipatterns.Highlighter
            local shorthand = {
                pattern = "()#%x%x%x()%f[%W]",
                group = function(_, _, data)
                    local match = data.full_match
                    local r, g, b = match:byte(2), match:byte(3), match:byte(4)
                    local hex_color = string.format("#%c%c%c%c%c%c", r, r, g, g, b, b)
                    return compute_hex_color_group(hex_color, "bg")
                end,
                extmark_opts = extmark_opts,
            }

            ---@type MiniHipatterns.Highlighter
            local separated = {
                pattern = "%f[%[]%[()%d+,%s*%d+,%s*%d+()%]%f[%]]",
                group = function(_, matched)
                    local r, g, b = matched:match("(%d+),%s*(%d+),%s*(%d+)")

                    -- Fix: Use string.format instead of matched.format
                    local hex_color = string.format("#%02X%02X%02X", r, g, b)
                    return compute_hex_color_group(hex_color, "fg")
                end,
                extmark_opts = extmark_vtext,
            }

            ---@type MiniHipatterns.Highlighter
            local nvim_hl_colors = {
                pattern = {
                    "%f[%w]()M%.colors%.[%w_%.]+()%f[%W]",
                    "%f[%w]()colors%.[%w_%.]+()%f[%W]",
                    "%f[%w]()defaults%.colors%.[%w_%.]+()%f[%W]",
                },
                group = function(_, match)
                    local parts = vim.split(match, ".", { plain = true })
                    local start_idx = 1

                    -- Optimize conditional checks
                    if parts[1] == "M" or parts[1] == "defaults" then
                        start_idx = 3
                    elseif parts[1] == "colors" then
                        start_idx = 2
                    end

                    -- Create new table instead of multiple removes
                    if start_idx > 1 then
                        local new_parts = {}
                        for i = start_idx, #parts do
                            new_parts[#new_parts + 1] = parts[i]
                        end
                        parts = new_parts
                    end

                    local color = vim.tbl_get(colors, unpack(parts))

                    if type(color) == "string" then
                        return require("lib.highlights").group({ fg = color })
                    end
                end,
                extmark_opts = extmark_vtext,
            }

            local highlighters = {
                nvim_hl_colors = nvim_hl_colors,
            }

            if not vim.lsp.document_color.is_enabled() then
                highlighters.hex = hex
                highlighters.separated = separated
                highlighters.shorthand = shorthand
            end

            return {
                highlighters = highlighters,
            }
        end,
        virtual = true,
    },
    {
        "nvim-mini/mini.icons",
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
            },
            lsp = defaults.icons.lsp,
        },
        lazy = false,
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
        "nvim-mini/mini.surround",
        -- stylua: ignore
        init = function()

            ev.on_load("mini.surround", function()
                keys.vmap('"', function() keys.feed('ma"', "t") end, "Surround Add Double Quote")
                keys.vmap("[", function() keys.feed("ma[<left>", "t") vim.schedule(function() keys.feed("%", "m") end) end, "Surround Add Square Bracket")
                keys.vmap("{", function() keys.feed("ma{<left>", "t") vim.schedule(function() keys.feed("%", "m") end) end, "Surround Add Curly Bracket")
                keys.vmap("(", function() keys.feed("ma(<left>", "t") vim.schedule(function() keys.feed("%", "m") end) end, "Surround Add Parenthesis")
                keys.vmap("`", function() keys.feed("ma`", "t") end, "Surround Add Backtick")

                -- vim.defer_fn(function() keys.xmap("<", function() keys.feed("ma<", "t") end, "Surround Add Angle Bracket") end, 2000)

                keys.map("of", function() keys.feed("<esc>m6", "n") keys.feed("daf", "m") keys.feed("`6", "n") end, "Surround Delete Function Call", "o")
            end)
        end,
        keys = function(plugin, keys)
            local opts = require("lazy.core.plugin").values(plugin, "opts", false) or { mappings = {} }

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
    {
        "nvim-mini/mini.statusline",
        init = function()
            hl.apply({
                MiniStatuslineModeNormal = { fg = colors.black.base, bg = colors.cyan.base, bold = true },
                MiniStatuslineModeVisual = { fg = colors.black.base, bg = colors.magenta.base, bold = true },
                MiniStatuslineModeInsert = { fg = colors.black.base, bg = colors.green.base, bold = true },
                MiniStatuslineModeReplace = { fg = colors.black.base, bg = colors.red.base, bold = true },
                MiniStatuslineModeCommand = { fg = colors.black.base, bg = colors.cyan.base, bold = true },
                MiniStatuslineModeOther = { fg = colors.black.base, bg = colors.cyan.base, bold = true },

                DiagnosticErrorStatus = { fg = colors.red.base, bold = true },
                DiagnosticHintStatus = { fg = colors.blue.bright, bold = true },
                DiagnosticInfoStatus = { fg = colors.blue.base, bold = true },
                DiagnosticWarnStatus = { fg = colors.yellow.base, bold = true },
                StatuslineSeparator = { fg = colors.white.base, bold = true },
            })
        end,
        opts = {
            use_icons = true,
            content = {
                active = function()
                    local mini_status = require("mini.statusline")
                    local sl = require("lib.statusline")

                    local aerial = sl.aerial()
                    local counts = sl.counts()
                    local diagnostics = sl.diagnostics()
                    local git = sl.git()
                    local schema = sl.schema()
                    local sep = hl.as_string("StatuslineSeparator", " ┃ ")

                    -- Long truncate width to show short mode.
                    local mode, mode_hl = mini_status.section_mode({ trunc_width = 256 })

                    return table.concat({
                        hl.as_string(mode_hl, " " .. mode .. " "),
                        sl.fileinfo(),
                        diagnostics ~= "" and sep or "",
                        diagnostics,
                        (diagnostics ~= "" or aerial ~= "") and sep or "",
                        aerial,
                        "%=",
                        schema,
                        schema ~= "" and sep or "",
                        git,
                        git ~= "" and sep or "",
                        counts,
                    }, "")
                end,
                use_icons = true,
                set_vim_settings = true,
            },
        },
        lazy = false,
        virtual = true,
    },
}
