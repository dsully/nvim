return {
    "ThePrimeagen/refactoring.nvim",
    dependencies = {
        { "nvim-lua/plenary.nvim" },
        { "nvim-treesitter/nvim-treesitter" },
    },
    keys = {
        {
            "<leader>cR",
            function()
                require("refactoring").select_refactor()
            end,
            desc = "  Refactor",
            mode = { "n", "x" },
            noremap = true,
            silent = true,
            expr = false,
        },
    },
    opts = true,
}
