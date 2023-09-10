-- Mini collection of modules.
return {
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
                -- source: https://old.reddit.com/r/neovim/comments/163rzex/how_to_avoid_autocompleting_right_parentheses/jy4zwp8/
                -- disable if a matching character is in an adjacent position (eg. fixes
                -- markdown triple ticks) neigh_pattern: a pattern for *two* neighboring
                -- characters (before and after). Use dot `.` to allow any character.
                -- Here, we disable the functionality instead of inserting a matching quote
                -- if there is an adjacent non-space character
                ["`"] = { action = "closeopen", pair = "``", neigh_pattern = "[^%S][^%S]", register = { cr = false } },
                ['"'] = { action = "closeopen", pair = '""', neigh_pattern = "[^%S][^%S]", register = { cr = false } },
                ["'"] = { action = "closeopen", pair = "''", neigh_pattern = "[^%S][^%S]", register = { cr = false } },
                ["["] = { action = "closeopen", pair = "[]", neigh_pattern = "[^%S][^%S]", register = { cr = false } },
                ["{"] = { action = "closeopen", pair = "{}", neigh_pattern = "[^%S][^%S]", register = { cr = false } },
                ["("] = { action = "closeopen", pair = "()", neigh_pattern = "[^%S][^%S]", register = { cr = false } },
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
