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

    -- Justfile, as the treesitter parser is rough.
    { "NoahTheDuke/vim-just", event = { "BufReadPre" } },

    -- Caddy
    { "isobit/vim-caddyfile", ft = "caddyfile" },

    -- Markdown helper.
    { "oncomouse/markdown.nvim", ft = "markdown", opts = {} },

    -- Pattern replacement UI.
    { "AckslD/muren.nvim", event = "VeryLazy", opts = {} },

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
