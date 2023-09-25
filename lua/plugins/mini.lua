-- Mini collection of modules.
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

            local i = {
                [" "] = "mini.ai: whitespace",
                ['"'] = 'mini.ai: balanced "',
                ["'"] = "mini.ai: balanced '",
                ["`"] = "mini.ai: balanced `",
                ["("] = "mini.ai: balanced (",
                [")"] = "mini.ai: balanced ) including white-space",
                [">"] = "mini.ai: balanced > including white-space",
                ["<lt>"] = "mini.ai: balanced <",
                ["]"] = "mini.ai: balanced ] including white-space",
                ["["] = "mini.ai: balanced [",
                ["}"] = "mini.ai: balanced } including white-space",
                ["{"] = "mini.ai: balanced {",
                ["?"] = "mini.ai: user prompt",
                _ = "mini.ai: underscore",
                a = "mini.ai: argument",
                b = "mini.ai: balanced ), ], }",
                c = "mini.ai: class",
                f = "mini.ai: function",
                o = "mini.ai: block, conditional, loop",
                q = "mini.ai: quote `, \", '",
                t = "mini.ai: tag",
            }

            local a = vim.deepcopy(i)

            for k, v in pairs(a) do
                a[k] = v:gsub(" including.*", "")
            end

            local ic = vim.deepcopy(i)
            local ac = vim.deepcopy(a)

            for key, name in pairs({ n = "next", l = "last" }) do
                ---@diagnostic disable-next-line: assign-type-mismatch
                i[key] = vim.tbl_extend("force", { name = "mini.ai: inside " .. name .. " textobject" }, ic)
                ---@diagnostic disable-next-line: assign-type-mismatch
                a[key] = vim.tbl_extend("force", { name = "mini.ai: around " .. name .. " textobject" }, ac)
            end

            require("which-key").register({ mode = { "o", "x" }, i = i, a = a })
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
        keys = {
            { "[f", desc = "mini.ai: goto previous function" },
            { "]f", desc = "mini.ai: goto next function" },
            { "a", mode = { "x", "o" } },
            { "i", mode = { "x", "o" } },
        },
    },
    {
        "echasnovski/mini.bufremove",
        init = function()
            vim.api.nvim_create_user_command("BDelete", function(args)
                require("mini.bufremove").delete(0, args.bang)
            end, { bang = true })

            vim.api.nvim_create_user_command("BWipeout", function(args)
                require("mini.bufremove").wipeout(0, args.bang)
            end, { bang = true })

            vim.keymap.set("n", "<leader>bd", function()
                require("mini.bufremove").delete()
            end, { desc = " Delete Buffer" })
        end,
        opts = {
            silent = true,
        },
    },
    {
        "echasnovski/mini.comment",
        keys = {
            { "gc", mode = { "n", "x" }, desc = "Comment Line(s)" },
            { "gcc", mode = { "n", "x" }, desc = "Uncomment Line(s)" },
        },
        opts = true,
    },
    {
        -- Show hex colors as colors.
        "echasnovski/mini.hipatterns",
        config = function()
            require("mini.hipatterns").setup({
                highlighters = {
                    hex_color = require("mini.hipatterns").gen_highlighter.hex_color(),
                },
            })
        end,
        event = "BufReadPre",
    },
    {
        "echasnovski/mini.pairs",
        event = "InsertEnter",
        opts = {
            mappings = {
                ["("] = { action = "open", pair = "()", neigh_pattern = "[^\\][]%s)}'\"]" },
                ["["] = { action = "open", pair = "[]", neigh_pattern = "[^\\][]%s)}'\"]" },
                ["{"] = { action = "open", pair = "{}", neigh_pattern = "[^\\][]%s)}'\"]" },

                ["<"] = { action = "open", pair = "<>", neigh_pattern = "[^\\][%s]" },
                [">"] = { action = "close", pair = "<>", neigh_pattern = "[^\\]." },

                ['"'] = { action = "closeopen", pair = '""', neigh_pattern = "[^\\][]%s)}'\"]", register = { cr = false } },
                ["'"] = { action = "closeopen", pair = "''", neigh_pattern = "[^%a\\][]%s)}'\"]", register = { cr = false } },
                ["`"] = { action = "closeopen", pair = "``", neigh_pattern = "[^\\][]%s)}'\"]", register = { cr = false } },
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
                },
            })
        end,
        keys = { { "gz", desc = "+ Surround" } },
    },
}
