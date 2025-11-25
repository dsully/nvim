---@type LazySpec[]
return {
    { "nvim-lua/plenary.nvim" },
    { "MunifTanjim/nui.nvim" },
    { "b0o/schemastore.nvim" },

    -- Log file syntax highlighting.
    { "fei6409/log-highlight.nvim", event = "BufRead *.log", opts = {} },

    -- For adding words to typos.toml
    { "faithanalog/toml.lua", lazy = false, priority = 1000 },

    {
        "CameronDixon0/hex-reader.nvim",
        keys = {
            -- stylua: ignore
            { "<leader>hx", function() require("hex_reader").toggle() end, desc = "Toggle hex reader." },
        },
        opts = true,
    },

    {
        "dsully/ignore.nvim",
        keys = {
            -- stylua: ignore
            { "<leader>di", function() require("lib.ignore").ignore() end },
        },
        virtual = true,
    },

    -- Better vim help.
    {
        "OXY2DEV/helpview.nvim",
        ft = { "help", "vimdoc" },
        opts = {
            preview = {
                icon_provider = "mini",
            },
        },
    },

    -- Pretty screen shots.
    {
        "mistricky/codesnap.nvim",
        branch = "refactor/v2",
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
