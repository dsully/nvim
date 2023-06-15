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
            { "gc", mode = { "n", "x" } },
            { "gcc", mode = { "n", "x" } },
        },
        opts = true,
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
        keys = { "gz" },
    },
}
