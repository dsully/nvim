---@type LazySpec[]
return {
    { "nvim-lua/plenary.nvim" },
    { "MunifTanjim/nui.nvim" },

    { "b0o/schemastore.nvim", version = false },
    { "cenk1cenk2/schema-companion.nvim", opts = {} },

    -- Pretty screen shots.
    {
        "mistricky/codesnap.nvim",
        build = "make build_generator",
        cmd = {
            "CodeSnap",
            "CodeSnapSave",
        },
        enabled = function()
            return vim.env.HOSTNAME ~= "zap"
        end,
        keys = {
            { "<leader>cS", "", desc = "󰹑 Screen Shots", mode = { "v" } },
            { "<leader>cSs", "<cmd>CodeSnap<cr>", mode = "v", desc = "Save selected code snapshot into clipboard" },
            { "<leader>cSS", "<cmd>CodeSnapSave<cr>", mode = "v", desc = "Save selected code snapshot in ~/Pictures" },
        },
        opts = {
            bg_theme = "dusk",
            has_breadcrumbs = true,
            save_path = vim.env.XDG_PICTURES_DIR,
            watermark = "",
        },
    },
}
