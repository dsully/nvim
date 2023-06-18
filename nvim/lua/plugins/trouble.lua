return {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
        {
            "<leader>xx",
            function()
                vim.cmd.TroubleToggle()
            end,
            desc = " Trouble",
        },
    },
    opts = {
        auto_preview = false,
        use_diagnostic_signs = true,
    },
}
