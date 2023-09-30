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

    -- PDL
    { "hjdivad/vim-pdl", ft = "pdl" },

    -- Pattern replacement UI.
    { "AckslD/muren.nvim", event = "VeryLazy", opts = {} },
}
