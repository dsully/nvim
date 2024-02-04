local defaults = require("config.defaults")

---@type LazySpec[]
return {
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
