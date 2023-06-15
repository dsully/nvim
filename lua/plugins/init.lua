return {
    { "nvim-lua/plenary.nvim" },

    {
        "psliwka/vim-dirtytalk",
        build = ":DirtytalkUpdate",
        config = function()
            vim.opt.rtp:append(vim.fn.stdpath("data") .. "/site")
            vim.opt.spelllang:append("programming")
        end,
        event = "VeryLazy",
    },

    -- Log file syntax highlighting.
    { "MTDL9/vim-log-highlighting", event = { "BufReadPre" } },

    -- Markdown helper.
    { "oncomouse/markdown.nvim", config = true, ft = "markdown" },

    -- Pattern replacement UI.
    { "AckslD/muren.nvim", config = true, event = "VeryLazy" },

    -- Better % matching.
    {
        "andymass/vim-matchup",
        event = "BufReadPost",
        init = function()
            vim.o.matchpairs = "(:),{:},[:],<:>"
        end,
        config = function()
            -- Don't recognize anything in comments
            vim.g.matchup_delim_noskips = 2

            vim.g.matchup_matchparen_deferred = 1
            vim.g.matchup_matchparen_offscreen = { method = "status_manual" }
        end,
    },
}
