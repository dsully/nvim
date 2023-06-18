return {
    "axieax/urlview.nvim",
    cmd = "UrlView",
    dependencies = { "nvim-telescope/telescope.nvim" },
    keys = {
        {
            "<leader>fu",
            function()
                vim.cmd.UrlView()
            end,
            desc = "URLs",
        },
    },
    opts = {
        log_level_min = vim.log.levels.WARN,
    },
}
