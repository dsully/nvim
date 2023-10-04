return {
    "axieax/urlview.nvim",
    cmd = "UrlView",
    keys = {
        { "<leader>fu", vim.cmd.UrlView, desc = "URLs" },
    },
    opts = {
        default_action = "system",
        default_picker = "telescope",
        log_level_min = vim.log.levels.ERROR,
    },
}
