return {
    { "nvim-lua/plenary.nvim" },
    { "MunifTanjim/nui.nvim" },

    { "b0o/schemastore.nvim", version = false },
    { "cenk1cenk2/schema-companion.nvim", opts = {} },

    {
        "folke/lazydev.nvim",
        cmd = "LazyDev",
        ft = "lua",
        opts = {
            integrations = {
                cmp = false,
                lspconfig = false,
            },
            library = {
                { path = "${3rd}/luv/library", words = { "vim%.uv" } },
                { path = "${3rd}/busted/library", words = { "describe" } },
                { path = "${3rd}/luassert/library", words = { "assert" } },
                { path = "lazy.nvim", words = { "LazyVim", "package" } },
                { path = "snacks.nvim", words = { "Snacks" } },
            },
        },
    },

    -- Pretty screen shots.
    {
        "mistricky/codesnap.nvim",
        build = "make build_generator",
        cmd = {
            "CodeSnap",
            "CodeSnapSave",
        },
        keys = {
            { "<leader>cS", "", desc = "󰹑 Screen Shots", mode = { "x" } },
            { "<leader>cSs", "<cmd>CodeSnap<cr>", mode = "x", desc = "Save selected code snapshot into clipboard" },
            { "<leader>cSS", "<cmd>CodeSnapSave<cr>", mode = "x", desc = "Save selected code snapshot in ~/Pictures" },
        },
        opts = {
            bg_theme = "dusk",
            has_breadcrumbs = true,
            save_path = vim.env.XDG_PICTURES_DIR,
            watermark = "",
        },
    },
}
