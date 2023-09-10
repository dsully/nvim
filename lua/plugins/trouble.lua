return {
    "folke/trouble.nvim",
    cmd = {
        "Trouble",
        "TroubleClose",
        "TroubleRefresh",
        "TroubleToggle",
    },
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
        {
            "<leader>xx",
            function()
                require("trouble").toggle()
            end,
            desc = " Trouble",
        },
    },
    opts = {
        auto_preview = false,
        use_diagnostic_signs = true,
    },
}
